# Scope

Do only what I asked. Nothing extra.

- No unrequested file edits, refactors, config changes, or "while I'm here" fixes.
- Question asked = answer it. Do not turn a question into a task.
- See an adjacent improvement? Mention it in one line. Wait for go-ahead.

# Design defaults

- YAGNI: no param, config, branch, or hook without a live caller.
- No abstraction (interface, base class, wrapper, layer) until 2nd concrete implementation exists.
- Duplication is cheaper than wrong abstraction. Inline until 3rd use, then extract.
- Related code stays in one file until file gets unwieldy. Do not split by layer preemptively.
- Direct calls over indirection. No event bus, registry, or DI container unless already in codebase.
- Single source of truth for facts (constants, schemas, validation rules, enums): never duplicate, not even twice. Applies to knowledge, not to code shape.
- Exception to the abstraction rule: IO boundaries (network, clock, fs, vendor SDK) earn a seam immediately — the test double is the 2nd implementation.
- Once 3+ cases share an axis of change, replace the growing conditional with a table or registry.
