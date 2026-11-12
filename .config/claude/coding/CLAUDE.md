# Subagents

- Default inline. Spawn only when work splits into non-overlapping files and tests or compiler can judge the result.
- Reads fan out, writes don't. Never two agents on one file.
- Read-only by default. Writing subagent or 4+ → ask first, name the count.
- Cross-agent handoff is a file, diff, or failing test. Never a prose summary.
- Duplicate agents on one task only when a test picks the winner.
- Agent output is a claim — verify anything that changes code.

# Design defaults

- YAGNI: never to add features or code until you actually need them right now.
- Abstraction (interface, base class, wrapper, layer) needs a 2nd *behavior variant*, not a 2nd caller. One caller with two real backends qualifies; two callers of one thing does not.
  - Exception to the abstraction rule: IO boundaries (network, clock, fs, vendor SDK) earn a seam immediately — the test double is the 2nd implementation.
- Duplication is cheaper than wrong abstraction. Inline until 3rd use, then extract.
- Related code stays in one file. Past ~400 lines, say so in one line; split only if asked or if the file is already the thing being changed. Never split by layer preemptively.
- Direct calls over indirection. No event bus, registry, or DI container unless already in the codebase or mandated by its framework.
  - Once 3+ cases share an axis of change, replace the growing conditional with a table or registry.
- Single source of truth for facts — constants, schemas, validation rules, enums, wire formats. Never duplicate, not even twice. A timeout value is a fact; two handlers with the same shape are not.

# Libraries and Dependencies

- If a dependency is installed locally, read its source code when needed instead of guessing, even if it is gitignored

# Testing

**Goal: Test real behavior, not mocks**

- Don't test mocked behavior - test real integration
- Test output must be pristine (zero warnings/errors)
- Respect the repository test strategy and add only the minimum useful tests for the requested change
- Prefer smoke, integration, and end-to-end tests over narrow unit or regression tests; do not test static text, prompts, or config unless behavior depends on them
- UI tests and automations must use stable IDs, test IDs, or accessibility IDs instead of visible text, and fail fast without fallback clicks

**Tests are the oracle, not the workspace**

- Never edit, delete, skip, or weaken a test to make it pass. Test looks wrong → stop, say why, ask.
- Show failing output before the fix, passing output after. Assertion-free test = no test.
- Spec and test conflict → surface the conflict, don't pick a side silently.

# Git

- Extreme concision in commits. Sacrifice grammar for brevity.
- Subject only, unless the "why" is non-obvious from the diff.
- prefer `git rebase` over merge

# Security

Applies to TS/JS files (`**/*.{ts,tsx,js,jsx}`).

## Always Do

- Validate all external input at system boundaries
- Parameterize database queries (no string concatenation)
- Encode output (HTML, URL, JS contexts)
- Use HTTPS for all external communication
- Hash passwords with bcrypt or argon2 (never SHA/MD5)
- Set security headers: CSP, HSTS, X-Frame-Options, X-Content-Type-Options

## Ask First

- Authentication or authorization changes
- Storing sensitive/personal data
- Adding external service integrations
- Modifying CORS configuration
- Changing session or token handling

## Never Do

- Trust client-side validation alone
- Use `eval()`, `Function()`, or `innerHTML` with user data
- Disable security headers or linters
- Expose stack traces or internal errors to users
