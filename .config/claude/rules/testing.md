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
