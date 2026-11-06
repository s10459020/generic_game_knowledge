# GGK 3.0.2 finite conformance results

Run date: 2026-11-06

## TLA+ environment

- Java: Microsoft OpenJDK 21.0.13.0.2
- TLC: `tla2tools.jar` from the installed VS Code TLA+ extension
- Model source: `formal/ggk-v3.0.2/`
- Invocation shape: `java -cp tla2tools.jar tlc2.TLC -nowarning -config <config> <module>.tla`

## Operation model

All nine operation configurations completed with `Model checking completed. No
error has been found.`

| Configuration | Distinct states |
| --- | ---: |
| `GGK302Operation.cfg` | 3 |
| `GGK302OperationConflicted.cfg` | 3 |
| `GGK302OperationEmpty.cfg` | 3 |
| `GGK302OperationEmptyInsufficient.cfg` | 3 |
| `GGK302OperationInvalidMembership.cfg` | 2 |
| `GGK302OperationInvalidNeed.cfg` | 2 |
| `GGK302OperationManyInsufficient.cfg` | 3 |
| `GGK302OperationRefresh.cfg` | 4 |
| `GGK302OperationResolvedMulti.cfg` | 3 |

The default `resolved-single` profile is `GGK302Operation.cfg`; the remaining
eight files provide the additional operation profiles. The result is nine
operation configurations in total, plus the independent record model below.

## Record model

`GGK302RecordRoundTrip.cfg` completed with `Model checking completed. No error
has been found.` It generated 35 states and found 5 distinct states. The model
checks tagged canonical encoding, decoding, injectivity and canonical field
tags across the finite record set.

## Interpretation

The run supports the declared finite mapping and its listed invariants:
source-basis membership, Need/Request agreement, result partition safety,
bounded-empty safety, many-complete safety, static write-back, Guide
currentness, refresh suspension and record encoding injectivity.

This result is not universal equivalence. It does not cover arbitrary record
values, unbounded source sets, all Scope values, all policies, all game
domains, or project adoption.
