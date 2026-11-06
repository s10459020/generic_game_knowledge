---------------------------- MODULE GGK302Operation ----------------------------

(*** Fresh GGK 3.0.2 operation model.  It is a bounded semantic witness for
     source-basis sets, canonical Need ownership and result partitioning. ***)

EXTENDS Naturals, TLC, FiniteSets

CONSTANT Scenario

Scenarios == {
  "resolved-single", "resolved-multi", "conflicted-multi",
  "empty-sufficient", "empty-insufficient", "many-insufficient",
  "invalid-membership", "invalid-need", "refresh"
}

Phases == {"ready", "evaluated", "current", "reopen_ready", "rejected"}
Statuses == {"none", "resolved", "unresolved", "conflicted", "empty"}
GuideStates == {"ineligible", "current", "reopen_pending"}
Cardinalities == {"one", "many-known-member", "many-complete"}
BasisValues == {"rb-structured", "terr-public", "outside-boundary"}
AdmittedBases == {"rb-structured", "terr-public"}
NeedIds == {"need-rb-energy", "need-terr-ammo"}
Contexts == {"rb-survival", "terraria-base"}
Members == {"candidate-a", "candidate-b"}
ContentIdentities == {"v1", "v2"}

VARIABLES
  phase, needId, needContext, needCardinality, requestNeedRef,
  admittedBasis, observationBasis, candidateBasis, sourceAvailable,
  candidateIds, candidateCount, compatibleCount, boundarySettled,
  boundarySufficient, resultStatus, resultUsedBasis, resultMembers,
  targetSelected, contentIdentity, guideState

vars == <<
  phase, needId, needContext, needCardinality, requestNeedRef,
  admittedBasis, observationBasis, candidateBasis, sourceAvailable,
  candidateIds, candidateCount, compatibleCount, boundarySettled,
  boundarySufficient, resultStatus, resultUsedBasis, resultMembers,
  targetSelected, contentIdentity, guideState
>>

ScenarioNeed ==
  IF Scenario = "empty-sufficient" \/ Scenario = "empty-insufficient"
    THEN "need-terr-ammo"
    ELSE "need-rb-energy"

ScenarioContext ==
  IF Scenario = "empty-sufficient" \/ Scenario = "empty-insufficient"
    THEN "terraria-base"
    ELSE "rb-survival"

ScenarioCardinality ==
  IF Scenario = "many-insufficient" THEN "many-complete" ELSE "one"

ScenarioAdmittedBasis ==
  IF Scenario = "resolved-multi" \/ Scenario = "conflicted-multi"
    THEN {"rb-structured", "terr-public"}
    ELSE {"rb-structured"}

ScenarioObservationBasis ==
  IF Scenario = "invalid-membership" THEN {"outside-boundary"}
  ELSE ScenarioAdmittedBasis

ScenarioCandidateBasis ==
  IF Scenario = "invalid-membership" THEN {"outside-boundary"}
  ELSE IF Scenario = "resolved-multi" \/ Scenario = "conflicted-multi"
    THEN {"rb-structured", "terr-public"}
    ELSE IF Scenario = "empty-sufficient" \/ Scenario = "empty-insufficient"
      THEN {}
      ELSE {"rb-structured"}

ScenarioCandidateIds ==
  IF Scenario = "empty-sufficient" \/ Scenario = "empty-insufficient" THEN {}
  ELSE IF Scenario = "conflicted-multi" THEN {"candidate-a", "candidate-b"}
  ELSE {"candidate-a"}

ScenarioCompatibleCount ==
  IF Scenario = "conflicted-multi" THEN 2 ELSE IF Cardinality(ScenarioCandidateIds) = 0 THEN 0 ELSE 1

ScenarioBoundarySettled ==
  Scenario # "empty-insufficient" /\ Scenario # "many-insufficient"

ScenarioBoundarySufficient ==
  Scenario # "empty-insufficient" /\ Scenario # "many-insufficient"

ScenarioValidNeed == Scenario # "invalid-need"
ScenarioRequestNeed == IF Scenario = "invalid-need" THEN "need-terr-ammo" ELSE ScenarioNeed
ScenarioSourceAvailable == Scenario # "invalid-membership"

Init ==
  /\ Scenario \in Scenarios
  /\ phase = (IF Scenario = "refresh" THEN "current" ELSE "ready")
  /\ needId = ScenarioNeed
  /\ needContext = ScenarioContext
  /\ needCardinality = ScenarioCardinality
  /\ requestNeedRef = ScenarioRequestNeed
  /\ admittedBasis = ScenarioAdmittedBasis
  /\ observationBasis = ScenarioObservationBasis
  /\ candidateBasis = ScenarioCandidateBasis
  /\ sourceAvailable = ScenarioSourceAvailable
  /\ candidateIds = ScenarioCandidateIds
  /\ candidateCount = Cardinality(candidateIds)
  /\ compatibleCount = ScenarioCompatibleCount
  /\ boundarySettled = ScenarioBoundarySettled
  /\ boundarySufficient = ScenarioBoundarySufficient
  /\ resultStatus = (IF Scenario = "refresh" THEN "resolved" ELSE "none")
  /\ resultUsedBasis = (IF Scenario = "refresh" THEN {"rb-structured"} ELSE {})
  /\ resultMembers = (IF Scenario = "refresh" THEN {"candidate-a"} ELSE {})
  /\ targetSelected = (Scenario = "refresh")
  /\ contentIdentity = "v1"
  /\ guideState = (IF Scenario = "refresh" THEN "current" ELSE "ineligible")

ValidRequest ==
  /\ ScenarioValidNeed
  /\ requestNeedRef = needId
  /\ observationBasis \subseteq admittedBasis
  /\ candidateBasis \subseteq admittedBasis

ExpectedStatus ==
  IF ~ValidRequest THEN "validation_failed"
  ELSE IF ~sourceAvailable THEN "unresolved"
  ELSE IF candidateCount = 0
    THEN IF boundarySettled /\ boundarySufficient THEN "empty" ELSE "unresolved"
  ELSE IF needCardinality = "many-complete" /\ ~boundarySufficient THEN "unresolved"
  ELSE IF compatibleCount = 0 THEN "conflicted"
  ELSE IF needCardinality = "one" /\ compatibleCount # 1 THEN "conflicted"
  ELSE "resolved"

ValidateAndResolve ==
  /\ phase \in {"ready", "reopen_ready"}
  /\ resultStatus' = (IF ExpectedStatus = "validation_failed" THEN "none" ELSE ExpectedStatus)
  /\ resultUsedBasis' = (IF ExpectedStatus = "validation_failed" THEN {} ELSE IF candidateCount = 0 THEN admittedBasis ELSE candidateBasis)
  /\ resultMembers' = (IF ExpectedStatus = "resolved" THEN candidateIds ELSE {})
  /\ targetSelected' = (ExpectedStatus = "resolved")
  /\ phase' = (IF ExpectedStatus = "validation_failed" THEN "rejected" ELSE "evaluated")
  /\ guideState' = "ineligible"
  /\ UNCHANGED <<needId, needContext, needCardinality, requestNeedRef,
                 admittedBasis, observationBasis, candidateBasis, sourceAvailable,
                 candidateIds, candidateCount, compatibleCount, boundarySettled,
                 boundarySufficient, contentIdentity>>

WriteBack ==
  /\ phase = "evaluated"
  /\ resultStatus \in {"resolved", "empty"}
  /\ phase' = "current"
  /\ guideState' = "current"
  /\ UNCHANGED <<needId, needContext, needCardinality, requestNeedRef,
                 admittedBasis, observationBasis, candidateBasis, sourceAvailable,
                 candidateIds, candidateCount, compatibleCount, boundarySettled,
                 boundarySufficient, resultStatus, resultUsedBasis, resultMembers,
                 targetSelected, contentIdentity>>

RecordOpen ==
  /\ phase = "evaluated"
  /\ resultStatus \in {"unresolved", "conflicted"}
  /\ phase' = "current"
  /\ guideState' = "ineligible"
  /\ UNCHANGED <<needId, needContext, needCardinality, requestNeedRef,
                 admittedBasis, observationBasis, candidateBasis, sourceAvailable,
                 candidateIds, candidateCount, compatibleCount, boundarySettled,
                 boundarySufficient, resultStatus, resultUsedBasis, resultMembers,
                 targetSelected, contentIdentity>>

RefreshBasis ==
  /\ Scenario = "refresh"
  /\ phase = "current"
  /\ guideState = "current"
  /\ contentIdentity = "v1"
  /\ phase' = "reopen_ready"
  /\ contentIdentity' = "v2"
  /\ resultStatus' = "none"
  /\ resultUsedBasis' = {}
  /\ resultMembers' = {}
  /\ targetSelected' = FALSE
  /\ guideState' = "reopen_pending"
  /\ UNCHANGED <<needId, needContext, needCardinality, requestNeedRef,
                 admittedBasis, observationBasis, candidateBasis, sourceAvailable,
                 candidateIds, candidateCount, compatibleCount, boundarySettled,
                 boundarySufficient>>

Next == ValidateAndResolve \/ WriteBack \/ RecordOpen \/ RefreshBasis \/ UNCHANGED vars
Spec == Init /\ [][Next]_vars

TypeOK ==
  /\ phase \in Phases
  /\ needId \in NeedIds
  /\ needContext \in Contexts
  /\ needCardinality \in Cardinalities
  /\ requestNeedRef \in NeedIds
  /\ admittedBasis \subseteq AdmittedBases
  /\ observationBasis \subseteq BasisValues
  /\ candidateBasis \subseteq BasisValues
  /\ sourceAvailable \in BOOLEAN
  /\ candidateIds \subseteq Members
  /\ candidateCount \in 0..2
  /\ compatibleCount \in 0..2
  /\ boundarySettled \in BOOLEAN
  /\ boundarySufficient \in BOOLEAN
  /\ resultStatus \in Statuses
  /\ resultUsedBasis \subseteq BasisValues
  /\ resultMembers \subseteq Members
  /\ targetSelected \in BOOLEAN
  /\ contentIdentity \in ContentIdentities
  /\ guideState \in GuideStates

NeedRequestAgreement == requestNeedRef = needId => needContext \in Contexts
CandidateCountMatches == candidateCount = Cardinality(candidateIds)
InvalidInputHasNoResult == phase = "rejected" => resultStatus = "none" /\ ~targetSelected
ResultStatusPartition == resultStatus = "none" \/ resultStatus \in {"validation_failed", "resolved", "unresolved", "conflicted", "empty"}
ResultSourceSubset == resultUsedBasis \subseteq admittedBasis
ResolvedPreservesMembers == resultStatus = "resolved" => resultMembers = candidateIds
OpenResultsHaveNoTarget == resultStatus \in {"unresolved", "conflicted", "empty"} => ~targetSelected
EmptyBoundarySafety == resultStatus = "empty" => candidateCount = 0 /\ boundarySettled /\ boundarySufficient
ManyCompleteSafety == needCardinality = "many-complete" /\ resultStatus = "resolved" => boundarySettled /\ boundarySufficient
GuideCurrentness == guideState = "current" => resultStatus \in {"resolved", "empty"} /\ targetSelected = (resultStatus = "resolved")
RefreshSuspendsCurrent == phase = "reopen_ready" => guideState = "reopen_pending" /\ resultStatus = "none" /\ ~targetSelected

=============================================================================
