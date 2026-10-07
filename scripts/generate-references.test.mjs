// Tests for scripts/generate-references.mjs. Run: node --test scripts/
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';

import {
  absolutizeLinks,
  convertMdx,
  parseAttrs,
  referenceName,
  renderPage,
  splitFrontmatter,
} from './generate-references.mjs';

const here = path.dirname(fileURLToPath(import.meta.url));
const fixtures = path.join(here, 'fixtures', 'references');

const octt = {
  labels: {
    sut: 'System under test',
    sutCsms: 'CSMS',
    sutCs: 'Charging Station Simulator',
    version: 'Version',
    total: 'Total',
    module: 'Module',
    testId: 'Test ID',
    name: 'Name',
    statusLabel: 'Status',
    picsItem: 'PICS item',
    description: 'Description',
    supported: 'Supported',
    reason: 'Reason',
    yes: 'Yes',
    no: 'No',
    testCount_one: '{{count}} test',
    testCount_other: '{{count}} tests',
    noneNotApplicable: 'Every test case in this suite applies.',
    resultsAsOf: 'Results as of {{date}}.',
    status: {
      passed: 'Passed',
      failed: 'Failed',
      skipped: 'Skipped',
      error: 'Error',
      notApplicable: 'Not applicable',
      pending: 'Pending',
    },
  },
  data: {
    pics: { 'ocpp1.6': [], 'ocpp2.1': [] },
    suites: [
      {
        sut: 'csms',
        version: 'ocpp2.1',
        runDate: '2026-10-05',
        modules: [
          {
            id: 'A',
            label: 'A - Security',
            tests: [
              { id: 'TC_A_01_CSMS', name: 'Basic auth', status: 'passed' },
              { id: 'TC_A_02_CSMS', name: 'TLS', status: 'notApplicable', notApplicable: { item: 'X', reason: 'No TLS' } },
            ],
          },
        ],
      },
      { sut: 'cs', version: 'ocpp1.6', runDate: null, modules: [] },
    ],
  },
};

test('converts every component the website uses', () => {
  const source = fs.readFileSync(path.join(fixtures, 'components.mdx'), 'utf8');
  const expected = fs.readFileSync(path.join(fixtures, 'components.expected.md'), 'utf8');
  const actual = renderPage('csms/sample', source, { octt });
  assert.equal(actual, expected);
});

test('fails on an unknown component', () => {
  assert.throws(() => convertMdx('<Accordion>\ntext\n</Accordion>\n', { page: 'x/y' }), /unknown component <Accordion>/);
  assert.throws(() => convertMdx('<Widget foo="1" />\n', { page: 'x/y' }), /unknown component <Widget>/);
});

test('fails on unbalanced blocks and fences', () => {
  assert.throws(() => convertMdx('<Callout>\ntext\n', { page: 'x/y' }), /not closed/);
  assert.throws(() => convertMdx('</Callout>\n', { page: 'x/y' }), /without a matching/);
  assert.throws(() => convertMdx('```bash\necho\n', { page: 'x/y' }), /unterminated code fence/);
  assert.throws(() => convertMdx('<Step>\nx\n</Step>\n', { page: 'x/y' }), /outside <Steps>/);
});

test('OCTT components need the results data', () => {
  assert.throws(() => convertMdx('<OcttSummary />\n', { page: 'x/y' }), /needs the OCTT results data/);
});

test('helpers', () => {
  assert.deepEqual(parseAttrs(' type="warning" title=\'Hi\' n={"x"}'), { type: 'warning', title: 'Hi', n: 'x' });
  assert.equal(
    absolutizeLinks('[a](/docs/x) ![b](/images/y.png) [c](https://example.com/z)'),
    '[a](https://www.evtivity.com/docs/x) ![b](https://www.evtivity.com/images/y.png) [c](https://example.com/z)',
  );
  assert.equal(referenceName('csms/stations'), 'stations.md');
  assert.equal(referenceName('mobile-app/guide/payments'), 'guide-payments.md');
  assert.deepEqual(splitFrontmatter('---\ntitle: "T"\n---\nbody\n'), { meta: { title: 'T' }, body: 'body\n' });
});
