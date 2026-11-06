# GGK Project

Codex leads this repository through Matt Pocock's engineering workflow. GGK
is maintained as a formal, versioned semantic framework.

## Authority

The current task, its declared source snapshot, and checked formal artifacts
are authoritative for the change in progress. The initial baseline is
`formal/ggk-v3.0.2/`.

Keep bounded evidence separate from broad claims. A finite TLA+ conformance
run supports only the scenarios and invariants that it actually checked; it
does not establish universal equivalence, product adoption, or game-specific
truth.

## Read first

1. `README.md`
2. `docs/agents/issue-tracker.md` and `docs/agents/domain.md`
3. The relevant formal model and conformance result under
   `formal/ggk-v3.0.2/`
4. The active `.scratch/<feature>/spec.md` and ready ticket, when present

## Matt workflow

Use the smallest loop that fits the work:

1. `/grill-with-docs` for unresolved terminology, scope, or design decisions.
2. `/to-spec` for an actionable specification.
3. `/to-tickets` for small dependency-aware tracer bullets.
4. `/implement` or `/implement-spec` for ready work.
5. `/tdd` at an agreed seam and `/code-review` before handoff or commit.
6. `/retro` after a meaningful delivery.

Keep modules deep: a small interface should hide substantial behaviour. Add a
seam only when a real variation or test boundary exists.

## Repository rules

- Keep formal models and their checked configurations under `formal/`.
- Keep specifications and local tickets under `.scratch/`.
- Keep agent workflow references under `docs/agents/`.
- Preserve the provenance and scope of formal results.
- Do not add secrets, credentials, game binaries, unlicensed dumps, or
  generated previews to the public repository.
- Public GitHub publication and pushes are performed only as part of the
  user's explicit repository request.

## Agent skills

### Issue tracker

GitHub Issues are the intended issue tracker once `origin` points to the new
repository. See `docs/agents/issue-tracker.md`.

### Domain docs

This is a single-context repository using the root domain vocabulary and
formal baseline, with decisions under `docs/adr/` when needed. See
`docs/agents/domain.md`.
