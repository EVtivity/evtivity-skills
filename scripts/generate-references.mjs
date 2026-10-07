#!/usr/bin/env node
// Generate skills/<skill>/references/<page>.md from the EVtivity website docs (MDX).
//
// The website docs are the single source of truth. Every page under
// app/content/docs/en/<section>/ lands in the skill mapped to its section in
// scripts/sections.json, plus any extra pages listed there. Also writes
// scripts/coverage.json and scripts/references-source.json (the website commit
// of every reference). A reference file is rewritten only when its content
// changes, so a website commit that leaves a page alone leaves its reference alone.
//
// Usage: node scripts/generate-references.mjs --website <dir> [--commit <sha>]
//   --website  a checkout (or exported tree) of the website repository
//   --commit   the website commit the tree comes from (default: git HEAD of <dir>)
//
// No dependencies: the MDX on the website uses a small set of components, and
// the converter fails on any component it does not know, so a new one cannot
// slip through unconverted.

import { execFileSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

export const SITE = 'https://www.evtivity.com';
const MARKER = 'Generated from https://www.evtivity.com/docs/';

// ------------------------------------------------------------------ converter

const KNOWN_BLOCKS = new Set(['Callout', 'Steps', 'Step', 'Tabs', 'Tab', 'CodeBlock']);
const OCTT = new Set([
  'OcttSummary',
  'OcttModuleSummary',
  'OcttResults',
  'OcttNotApplicable',
  'OcttPics',
  'OcttResultsDate',
]);

/** Parse `key="value"` and `key='value'` attributes of a JSX tag. */
export function parseAttrs(text) {
  const attrs = {};
  for (const m of text.matchAll(/([A-Za-z_][\w-]*)\s*=\s*(?:"([^"]*)"|'([^']*)'|\{\s*["']([^"']*)["']\s*\})/g)) {
    attrs[m[1]] = m[2] ?? m[3] ?? m[4] ?? '';
  }
  return attrs;
}

/** Split frontmatter from the body. Supports `key: value` lines with optional quotes. */
export function splitFrontmatter(source) {
  const text = source.replace(/\r\n/g, '\n');
  if (!text.startsWith('---\n')) return { meta: {}, body: text };
  const end = text.indexOf('\n---', 4);
  if (end === -1) throw new Error('unterminated frontmatter');
  const meta = {};
  for (const line of text.slice(4, end).split('\n')) {
    const m = line.match(/^([A-Za-z_][\w-]*):\s*(.*)$/);
    if (!m) continue;
    let value = m[2].trim();
    if (/^(["']).*\1$/.test(value)) value = value.slice(1, -1);
    meta[m[1]] = value;
  }
  const rest = text.slice(end + 4).replace(/^[^\n]*\n/, '');
  return { meta, body: rest };
}

/** Rewrite root-relative links and images to absolute website URLs. */
export function absolutizeLinks(line) {
  return line
    .replace(/(\]\()\/(?!\/)/g, `$1${SITE}/`)
    .replace(/(\bsrc=")\/(?!\/)/g, `$1${SITE}/`)
    .replace(/(\bhref=")\/(?!\/)/g, `$1${SITE}/`);
}

/** Decode the HTML entities the MDX uses for quotes. Leaves &lt; &gt; &amp; alone. */
export function decodeEntities(line) {
  return line.replace(/&#39;|&apos;/g, "'").replace(/&#34;|&quot;/g, '"');
}

/** Apply inline rewrites outside inline code spans. */
function rewriteInline(line) {
  return line
    .split(/(`+[^`]*`+)/)
    .map((part, i) => (i % 2 === 1 ? part : decodeEntities(absolutizeLinks(part))))
    .join('');
}

function indent(lines, prefix) {
  return lines.map((l) => (l.trim() === '' ? prefix.trimEnd() : prefix + l));
}

/**
 * Convert MDX body text to Markdown. `octt` renders the OCTT result components
 * (pass null when a page uses none). Throws on an unknown component.
 */
export function convertMdx(body, { page = '', octt = null } = {}) {
  const lines = body.split('\n');
  const out = [];
  // Stack of open block components: { name, attrs, lines }
  const stack = [];
  let fence = null;

  const emit = (line) => {
    if (stack.length > 0) stack[stack.length - 1].lines.push(line);
    else out.push(line);
  };

  const closeBlock = (name) => {
    const block = stack.pop();
    if (!block || block.name !== name) {
      throw new Error(`${page}: </${name}> without a matching <${name}>`);
    }
    const inner = trimBlank(block.lines);
    let rendered;
    switch (name) {
      case 'Callout': {
        const type = block.attrs.type ?? 'note';
        const label = block.attrs.title ?? type.charAt(0).toUpperCase() + type.slice(1);
        rendered = ['', `> **${label}:**`, '>', ...indent(inner, '> '), ''];
        break;
      }
      case 'CodeBlock': {
        const lang = block.attrs.language ?? '';
        rendered = ['', '```' + lang, ...inner, '```', ''];
        break;
      }
      case 'Step': {
        if (stack.length === 0 || stack[stack.length - 1].name !== 'Steps') {
          throw new Error(`${page}: <Step> outside <Steps>`);
        }
        rendered = [{ step: inner, title: block.attrs.title ?? null }];
        break;
      }
      case 'Steps': {
        let n = 0;
        rendered = [''];
        for (const item of block.lines) {
          if (typeof item === 'object' && item !== null && 'step' in item) {
            n += 1;
            const content = [...item.step];
            let title = item.title;
            if (!title && content.length > 0 && /^#{2,6}\s+/.test(content[0])) {
              title = content.shift().replace(/^#{2,6}\s+/, '');
            }
            const rest = trimBlank(content);
            const head = `${n}. ${title ? `**${title}**` : (rest.shift() ?? '')}`;
            rendered.push(head);
            if (rest.length > 0) rendered.push('', ...indent(rest, '   '));
            rendered.push('');
          } else if (typeof item === 'string' && item.trim() !== '') {
            rendered.push(item);
          }
        }
        break;
      }
      case 'Tab': {
        const title = block.attrs.title ?? block.attrs.label ?? block.attrs.value ?? 'Tab';
        rendered = ['', `#### ${title}`, '', ...inner, ''];
        break;
      }
      case 'Tabs': {
        rendered = ['', ...inner, ''];
        break;
      }
      default:
        throw new Error(`${page}: unknown block <${name}>`);
    }
    for (const r of rendered) emit(r);
  };

  for (let i = 0; i < lines.length; i++) {
    const raw = lines[i];
    const trimmed = raw.trim();

    // Code fences pass through untouched.
    const fenceMatch = trimmed.match(/^(`{3,}|~{3,})/);
    if (fence) {
      emit(raw);
      if (fenceMatch && trimmed.startsWith(fence) && trimmed.replace(/[`~]/g, '') === '') fence = null;
      continue;
    }
    if (fenceMatch) {
      fence = fenceMatch[1];
      emit(raw);
      continue;
    }

    // MDX imports and exports at the top level.
    if (/^(import|export)\s/.test(trimmed) && stack.length === 0) continue;
    // JSX comments.
    if (/^\{\/\*.*\*\/\}$/.test(trimmed)) continue;
    // Empty HTML anchors such as <a id="x"></a>.
    if (/^<a\s+(id|name)="[^"]*"\s*>\s*<\/a>$/.test(trimmed)) continue;

    // Closing tag of a block component.
    const close = trimmed.match(/^<\/([A-Z][A-Za-z]*)>$/);
    if (close) {
      closeBlock(close[1]);
      continue;
    }

    // Opening tag on its own line, or a self-closing component.
    const open = trimmed.match(/^<([A-Z][A-Za-z]*)\b([^>]*?)(\/?)>(.*)$/);
    if (open) {
      const [, name, attrText, selfClose, after] = open;
      const attrs = parseAttrs(attrText);
      if (OCTT.has(name)) {
        if (!selfClose) throw new Error(`${page}: <${name}> must be self-closing`);
        if (!octt) throw new Error(`${page}: <${name}> needs the OCTT results data`);
        for (const l of renderOctt(name, attrs, octt)) emit(l);
        continue;
      }
      if (!KNOWN_BLOCKS.has(name)) throw new Error(`${page}: unknown component <${name}>`);
      if (selfClose) continue;
      stack.push({ name, attrs, lines: [] });
      // Content on the same line as the opening tag, and possibly its closing tag.
      const sameLineClose = after.match(/^(.*)<\/([A-Z][A-Za-z]*)>\s*$/);
      if (sameLineClose) {
        if (sameLineClose[1].trim()) emit(rewriteInline(sameLineClose[1].trim()));
        closeBlock(sameLineClose[2]);
      } else if (after.trim()) {
        emit(rewriteInline(after.trim()));
      }
      continue;
    }

    // Any other capitalized JSX tag at the start of a line is unknown.
    if (/^<[A-Z]/.test(trimmed)) throw new Error(`${page}: unknown component in "${trimmed}"`);

    emit(rewriteInline(raw));
  }
  if (fence) throw new Error(`${page}: unterminated code fence`);
  if (stack.length > 0) throw new Error(`${page}: <${stack[stack.length - 1].name}> is not closed`);
  return collapseBlank(out).join('\n').trim() + '\n';
}

function trimBlank(lines) {
  const copy = lines.filter((l) => typeof l === 'string');
  while (copy.length > 0 && copy[0].trim() === '') copy.shift();
  while (copy.length > 0 && copy[copy.length - 1].trim() === '') copy.pop();
  return copy;
}

function collapseBlank(lines) {
  const out = [];
  for (const l of lines) {
    if (l.trim() === '' && out.length > 0 && out[out.length - 1].trim() === '') continue;
    out.push(l.trim() === '' ? '' : l.replace(/\s+$/, ''));
  }
  return out;
}

// ------------------------------------------------------------------ OCTT components

const STATUS_ORDER = ['passed', 'notApplicable', 'pending', 'failed', 'error', 'skipped'];
const SUITE_PAGES = {
  'csms-ocpp2.1': '/docs/conformance/csms-ocpp21',
  'csms-ocpp1.6': '/docs/conformance/csms-ocpp16',
  'cs-ocpp2.1': '/docs/conformance/charging-station-ocpp21',
  'cs-ocpp1.6': '/docs/conformance/charging-station-ocpp16',
};

function cell(text) {
  return String(text ?? '').replace(/\|/g, '\\|').replace(/\n/g, ' ');
}

function table(head, rows) {
  return [
    '',
    `| ${head.map(cell).join(' | ')} |`,
    `|${head.map(() => '---').join('|')}|`,
    ...rows.map((r) => `| ${r.map(cell).join(' | ')} |`),
    '',
  ];
}

function counts(tests) {
  const c = { passed: 0, failed: 0, skipped: 0, error: 0, notApplicable: 0, pending: 0 };
  for (const t of tests) c[t.status] = (c[t.status] ?? 0) + 1;
  return c;
}

/** Render one OCTT component as Markdown, mirroring the website component. */
export function renderOctt(name, attrs, { data, labels }) {
  const L = labels;
  const status = (s) => L.status[s] ?? s;
  const suite = (version, sut) => data.suites.find((s) => s.version === version && s.sut === sut);
  const modules = (version, sut) => suite(version, sut)?.modules ?? [];
  const tests = (version, sut) => modules(version, sut).flatMap((m) => m.tests);
  const { version, sut } = attrs;
  switch (name) {
    case 'OcttSummary':
      return table(
        [L.sut, L.version, L.total, status('passed'), status('notApplicable'), status('pending')],
        data.suites.map((s) => {
          const c = counts(tests(s.version, s.sut));
          const total = Object.values(c).reduce((a, b) => a + b, 0);
          const label = s.sut === 'csms' ? L.sutCsms : L.sutCs;
          return [
            `[${label}](${SITE}${SUITE_PAGES[`${s.sut}-${s.version}`]})`,
            s.version === 'ocpp2.1' ? 'OCPP 2.1' : 'OCPP 1.6',
            total,
            c.passed,
            c.notApplicable,
            c.pending + c.failed + c.error + c.skipped,
          ];
        }),
      );
    case 'OcttModuleSummary': {
      const mods = modules(version, sut);
      const all = mods.flatMap((m) => m.tests);
      const totals = counts(all);
      const shown = STATUS_ORDER.filter((s) => totals[s] > 0);
      return table(
        [L.module, L.total, ...shown.map(status)],
        [
          ...mods.map((m) => {
            const c = counts(m.tests);
            return [m.label, m.tests.length, ...shown.map((s) => c[s])];
          }),
          [`**${L.total}**`, `**${all.length}**`, ...shown.map((s) => `**${totals[s]}**`)],
        ],
      );
    }
    case 'OcttResults': {
      const out = [];
      for (const m of modules(version, sut)) {
        const count = m.tests.length;
        const countText = (count === 1 ? L.testCount_one : L.testCount_other).replace('{{count}}', count);
        out.push('', `### ${m.label}`, '', countText);
        out.push(
          ...table(
            [L.testId, L.name, L.statusLabel],
            m.tests.map((t) => [
              t.id,
              t.notApplicable ? `${t.name} (${t.notApplicable.reason})` : t.name,
              status(t.status),
            ]),
          ),
        );
      }
      return out;
    }
    case 'OcttNotApplicable': {
      const na = tests(version, sut).filter((t) => t.status === 'notApplicable');
      if (na.length === 0) return ['', L.noneNotApplicable, ''];
      return table(
        [L.testId, L.name, L.reason],
        na.map((t) => [t.id, t.name, t.notApplicable?.reason ?? '']),
      );
    }
    case 'OcttPics':
      return table(
        [L.picsItem, L.supported, L.description],
        (data.pics[version] ?? []).map((p) => [
          p.id,
          p.supported ? L.yes : L.no,
          p.reason ? `${p.description} (${L.reason}: ${p.reason})` : p.description,
        ]),
      );
    case 'OcttResultsDate': {
      const date = suite(version, sut)?.runDate;
      return date ? ['', L.resultsAsOf.replace('{{date}}', date), ''] : [];
    }
    default:
      throw new Error(`unknown OCTT component ${name}`);
  }
}

// ------------------------------------------------------------------ page rendering

/** Reference file name for a page id: csms/stations -> stations.md, mobile-app/guide/x -> guide-x.md */
export function referenceName(pageId) {
  return pageId.split('/').slice(1).join('-') + '.md';
}

// The header names the page, not the website commit: a reference changes only when its page
// content changes. scripts/references-source.json records the commit for every reference.
export function renderPage(pageId, source, { octt }) {
  const { meta, body } = splitFrontmatter(source);
  const url = `${SITE}/docs/${pageId}`;
  const lines = [`Generated from ${url}. Do not edit.`, ''];
  if (meta.title) lines.push(`# ${decodeEntities(meta.title)}`, '');
  if (meta.description) lines.push(decodeEntities(meta.description), '');
  lines.push(convertMdx(body, { page: pageId, octt }));
  return collapseBlank(lines.join('\n').split('\n')).join('\n').trim() + '\n';
}

// ------------------------------------------------------------------ main

function listPages(docsRoot) {
  const pages = [];
  const walk = (dir) => {
    for (const entry of fs.readdirSync(dir, { withFileTypes: true }).sort((a, b) => a.name.localeCompare(b.name))) {
      const full = path.join(dir, entry.name);
      if (entry.isDirectory()) walk(full);
      else if (entry.name.endsWith('.mdx')) {
        pages.push(path.relative(docsRoot, full).replace(/\\/g, '/').replace(/\.mdx$/, ''));
      }
    }
  };
  walk(docsRoot);
  return pages;
}

function parseArgs(argv) {
  const args = {};
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--website' || a === '--commit') args[a.slice(2)] = argv[++i];
    else if (a === '-h' || a === '--help') args.help = true;
    else throw new Error(`unknown argument ${a}`);
  }
  return args;
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help || !args.website) {
    console.log('Usage: node scripts/generate-references.mjs --website <dir> [--commit <sha>]');
    process.exit(args.help ? 0 : 2);
  }
  const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
  const website = path.resolve(args.website);
  const docsRoot = path.join(website, 'app/content/docs/en');
  if (!fs.existsSync(docsRoot)) throw new Error(`${docsRoot} not found`);
  const commit =
    args.commit ?? execFileSync('git', ['-C', website, 'rev-parse', 'HEAD'], { encoding: 'utf8' }).trim();
  if (!/^[0-9a-f]{40}$/.test(commit)) throw new Error(`--commit must be a full sha, got ${commit}`);
  const shortSha = commit.slice(0, 7);

  const config = JSON.parse(fs.readFileSync(path.join(repoRoot, 'scripts/sections.json'), 'utf8'));
  const pages = listPages(docsRoot);

  const sectionsSeen = [...new Set(pages.map((p) => p.split('/')[0]))];
  const unmapped = sectionsSeen.filter((s) => !(s in config.sections));
  if (unmapped.length > 0) {
    throw new Error(`website sections without a skill in scripts/sections.json: ${unmapped.join(', ')}`);
  }

  let octt = null;
  const octtPath = path.join(website, 'app/data/octt-results.json');
  const i18nPath = path.join(website, 'app/i18n/en.json');
  if (fs.existsSync(octtPath) && fs.existsSync(i18nPath)) {
    octt = {
      data: JSON.parse(fs.readFileSync(octtPath, 'utf8')),
      labels: JSON.parse(fs.readFileSync(i18nPath, 'utf8')).octt,
    };
  }

  const coverage = {};
  const add = (skill, pageId) => {
    coverage[skill] ??= [];
    if (!coverage[skill].includes(pageId)) coverage[skill].push(pageId);
  };
  for (const pageId of pages) add(config.sections[pageId.split('/')[0]], pageId);
  for (const [skill, extra] of Object.entries(config.extraPages ?? {})) {
    for (const pageId of extra) {
      if (!pages.includes(pageId)) throw new Error(`scripts/sections.json: ${skill} lists missing page ${pageId}`);
      add(skill, pageId);
    }
  }

  let written = 0;
  let changed = 0;
  for (const [skill, skillPages] of Object.entries(coverage)) {
    const skillDir = path.join(repoRoot, 'skills', skill);
    if (!fs.existsSync(path.join(skillDir, 'SKILL.md'))) throw new Error(`skills/${skill}/SKILL.md not found`);
    const refDir = path.join(skillDir, 'references');
    fs.mkdirSync(refDir, { recursive: true });
    const keep = new Set();
    for (const pageId of skillPages) {
      const name = referenceName(pageId);
      if (keep.has(name)) throw new Error(`${skill}: two pages map to references/${name}`);
      keep.add(name);
      const source = fs.readFileSync(path.join(docsRoot, `${pageId}.mdx`), 'utf8');
      const file = path.join(refDir, name);
      const rendered = renderPage(pageId, source, { octt });
      if (!fs.existsSync(file) || fs.readFileSync(file, 'utf8') !== rendered) {
        fs.writeFileSync(file, rendered);
        changed += 1;
      }
      written += 1;
    }
    // Remove generated files of pages that no longer exist.
    for (const file of fs.readdirSync(refDir)) {
      if (keep.has(file) || !file.endsWith('.md')) continue;
      const first = fs.readFileSync(path.join(refDir, file), 'utf8').split('\n', 1)[0];
      if (first.startsWith(MARKER)) fs.rmSync(path.join(refDir, file));
    }
  }

  const sorted = Object.fromEntries(
    Object.keys(coverage)
      .sort()
      .map((k) => [k, coverage[k]]),
  );
  fs.writeFileSync(path.join(repoRoot, 'scripts/coverage.json'), JSON.stringify(sorted, null, 2) + '\n');
  fs.writeFileSync(
    path.join(repoRoot, 'scripts/references-source.json'),
    JSON.stringify({ website: 'github.com/EVtivity/evtivity.com', commit }, null, 2) + '\n',
  );
  console.log(
    `${written} references (${changed} changed) from ${pages.length} pages at website commit ${shortSha}`,
  );
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  try {
    main();
  } catch (err) {
    console.error(`generate-references: ${err.message}`);
    process.exit(1);
  }
}
