Generated from https://www.evtivity.com/docs/csms/ai-usage. Do not edit.

# AI Usage and Budgets

See how many AI tokens your company, sites, and users use, and set daily and monthly token budgets.

## Overview

EVtivity records the tokens of every AI request: assistant answers, support drafts, automatic answers to drivers, automatic insights, their translations, and background workers. Token budgets per company, per site, per user, and per driver stop AI requests once a budget is used up.

Budgets count tokens, not money, so they work the same with every provider. A request's tokens are its input tokens plus its output tokens.

## Budgets

Set the budgets in the **AI Limits** card of **Settings > AI > Usage and Limits**, and the driver budget in **Settings > AI > Driver Support**. 0 means no limit.

| Budget | Setting | Default | Counts |
|--------|---------|---------|--------|
| **Company tokens per month** | `ai.budget.companyMonthlyTokens` | 0 | Every AI request |
| **Tokens per site per month** | `ai.budget.siteMonthlyTokens` | 0 | Requests charged to the site |
| **Tokens per site per day (insights and workers)** | `ai.budget.siteDailyTokens` | 300,000 | Automatic insights and background workers of the site |
| **Tokens per user per day** | `ai.budget.userDailyTokens` | 2,000,000 | The user's assistant and support draft requests |
| **Tokens per driver per day** | `ai.budget.driverDailyTokens` | 40,000 | The [driver AI support](https://www.evtivity.com/docs/csms/support-cases#driver-ai-support) requests of one driver |
| **Warn at (% of a budget)** | `ai.budget.warnPercent` | 80 | When to warn about the company and site monthly budgets |

- Daily budgets run from midnight to midnight UTC.
- Monthly budgets run for the calendar month in the system timezone.
- A site can have its own monthly budget. See [Site Budget](#site-budget).

EVtivity checks the budgets before each AI request. A request that is already running finishes, so usage can go slightly over a budget.

### Which Requests Count Where

| Request | Charged to |
|---------|-----------|
| Assistant and [Explain](https://www.evtivity.com/docs/csms/ai-assistant#explain) | The company and the user, no site |
| Support case AI draft | The company, the user, and the site of the case's station |
| [Driver AI support](https://www.evtivity.com/docs/csms/support-cases#driver-ai-support) | The company, the site of the case's station, and the driver |
| Automatic insights and their translations | The company and the site |
| Background workers | The company and the site |
| MCP server | Nothing. MCP clients bring their own AI model |

### When a Budget Is Used Up

- The assistant and support drafts show an error: `AI_BUDGET_EXCEEDED` for the user's daily budget, `AI_MONTHLY_BUDGET_EXCEEDED` for a company or site monthly budget.
- A driver support case goes to the support team without an automatic answer. Its AI state reason is **AI budget reached**.
- Automatic insights are stored with their rule-based fields only, without an AI-written summary.
- Background workers store their findings and suggested actions without the AI-written text.

Users with the `settings.ai:write` permission and access to every site get an email and SMS when the company or a site reaches the warning percent of its monthly budget (**AI Budget Warning**) and when it uses the budget up (**AI Budget Used Up**), once per budget and month. A company budget at or past the warning percent also shows a banner at the top of every CSMS page. See [AI Alerts](https://www.evtivity.com/docs/csms/settings#ai-alerts).

## Usage and Limits Tab

Open **Settings > AI** and select the **Usage and Limits** tab. It starts with the **AI Limits** card. The usage below it needs the `aiUsage:read` permission and access to every site.

![AI usage tab](https://www.evtivity.com/screenshots/csms/settings-ai-usage.png)

- **Month**: a dropdown of the last 24 months. The **Period** shows the start and end of the month you pick.
- **Company**: the company's tokens this month against its budget.
- **Sites**: tokens per site against each site's budget, 10 sites per page.
- **Assistant (not site-specific)**: the last row of the **Sites** list, tokens that belong to no site, such as assistant and Explain tokens.
- **By surface**: tokens per surface (Assistant, Support drafts, Driver support, Insights, Insight translations, Background workers), split into input, cached input, cache writes, output, and reasoning tokens.
- **Top users**: the users with the most tokens this month. Driver support tokens count in the company, site, and surface totals, but drivers are never listed or named here.

The tab shows a banner for each monthly budget at or past the warning percent. When the company or a site passes the warning percent or uses up its monthly budget, the assistant panel also shows a notice, once per budget and month.

### Cost

The tab shows the cost of the tokens only when the company currency is US dollars, because AI providers price in US dollars. In any other currency it shows tokens only.

## Site Budget

The **AI Usage** tab of a site shows the **AI Usage** card: the site's tokens this month against its budget. The tab shows for users with the `aiUsage:read` permission, and for users with access to every site and the `sites:write` permission.

![Site AI tab](https://www.evtivity.com/screenshots/csms/site-ai-tab.png)

Users with access to every site and the `sites:write` permission can also change:

- **Monthly token budget**: leave it empty to use **Tokens per site per month**. 0 means no limit.

Which sites automatic insights analyze is set in the **AI Insights Scope** card of **Settings > AI > Automatic Insights** (see [Settings](https://www.evtivity.com/docs/csms/settings#automatic-insights)).

## Your Own Usage

The footer of the assistant panel shows your tokens today against your daily budget, for example "Today: 12,400 of 2,000,000 tokens".

## Permissions

| Permission | Allows |
|------------|--------|
| `aiUsage:read` | See company and site usage. A user limited to some sites sees only those sites, with no company totals, no assistant row, and no top users. |
| `aiAssistant:read` | See your own usage in the panel footer |

By default, operators have `aiUsage:read`.

## Notes

- The API returns usage at `GET /v1/ai/usage`, `GET /v1/ai/usage/sites/{siteId}`, and `GET /v1/users/me/ai-usage`.
- See the [error codes](https://www.evtivity.com/api-reference/error-codes) for every budget error.
