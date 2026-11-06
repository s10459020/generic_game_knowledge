# GGK

GGK is maintained as a formal, versioned semantic framework. The initial
repository baseline is GGK 3.0.2.

## Current baseline

The first committed slice lives under `formal/ggk-v3.0.2/` and contains:

- the bounded GGK 3.0.2 operation model;
- the record round-trip model;
- nine operation configurations and one record configuration;
- the finite conformance results recorded on 2026-11-06.

The conformance result is a bounded model-checking witness. It is not a claim
of universal equivalence or project-wide adoption.

## Development workflow

This repository is initialized for Matt Pocock's engineering workflow. The
agent-facing repository rules and issue/domain conventions will live under
`AGENTS.md` and `docs/agents/` once the repository entry file is selected.

## Scope boundary

This repository starts from the GGK 3.0.2 formal baseline. Product adoption,
game-specific truth, source captures, and implementation code remain separate
work items and must be introduced with an explicit specification.
