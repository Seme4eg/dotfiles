# Scope

Do only what I asked. Nothing extra.

- No unrequested file edits, refactors, config changes, or "while I'm here" fixes.
- Question asked = answer it. Do not turn a question into a task.
- See an adjacent improvement? Mention it in one line. Wait for go-ahead.
# Subagents

- Default inline. Spawn only when work splits into non-overlapping files and tests or compiler can judge the result.
- Reads fan out, writes don't. Never two agents on one file.
- Max 3 parallel, read-only. Writing subagent or 4+ → ask first, name the count.
- Subagents don't spawn subagents.
- Step 2 needs step 1's output → inline.
- Cross-agent handoff is a file, diff, or failing test. Never a prose summary.
- Duplicate agents on one task only when a test picks the winner.
- No Workflow, orchestration, or deep-research unless I name it.
- Relay conclusions, not transcripts. Agent output is a claim — verify anything that changes code.

# Design defaults

- YAGNI: no param, config, branch, or hook without a live caller.
- No abstraction (interface, base class, wrapper, layer) until 2nd concrete implementation exists.
- Duplication is cheaper than wrong abstraction. Inline until 3rd use, then extract.
- Related code stays in one file until file gets unwieldy. Do not split by layer preemptively.
- Direct calls over indirection. No event bus, registry, or DI container unless already in codebase.
- Single source of truth for facts (constants, schemas, validation rules, enums): never duplicate, not even twice. Applies to knowledge, not to code shape.
- Exception to the abstraction rule: IO boundaries (network, clock, fs, vendor SDK) earn a seam immediately — the test double is the 2nd implementation.
- Once 3+ cases share an axis of change, replace the growing conditional with a table or registry.

# Secrets

- Never commit secrets, keys, or credentials.
- Never log sensitive data (passwords, tokens, PII).
- Never print a secret's value to explain or verify it.

# Libraries and Dependencies

- Install dependencies in project environments, not globally
- Add or update dependencies in project config files, not as one-off manual installs
- If a dependency is installed locally, read its source code when needed instead of guessing, even if it is gitignored
