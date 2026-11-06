------------------------- MODULE GGK302RecordRoundTrip -------------------------

EXTENDS Naturals, TLC, Sequences

String(value) == [tag |-> "str", value |-> value]
Entry(key, value) == <<key, value>>
Map(entries) == [tag |-> "map", value |-> entries]
ListValue(entries) == [tag |-> "list", value |-> entries]
TupleValue(entries) == [tag |-> "tuple", value |-> entries]

TechnicalScope(sourceUnit, content) == Map(<<
  Entry("content_identity", String(content)),
  Entry("kind", String("technical")),
  Entry("source_unit_ref", String(sourceUnit))
>>)

GameScope(context) == Map(<<
  Entry("game_context", String(context)),
  Entry("kind", String("game"))
>>)

Basis(sourceUnit, route, content) == TupleValue(<<String(sourceUnit), String(route), String(content)>>)
BasisSet(entries) == TupleValue(entries)
CanonicalFields(kind, fields) == [tag |-> kind \o "_fields", value |-> fields]

Encode(record) ==
  [tag |-> "record",
   owner |-> [tag |-> "owner", value |-> record.owner],
   kind |-> [tag |-> "record_kind", value |-> record.kind],
   identity |-> [tag |-> "record_identity", value |-> record.identity],
   scope |-> [tag |-> "scope", value |-> record.scope],
   fields |-> CanonicalFields(record.kind, record.fields)]

RB == Basis("rb-structured", "architecture", "rb-v1")
Terr == Basis("terr-public", "direct_inventory", "terr-v1")

Records == {
  [owner |-> "Inference", kind |-> "semantic_need", identity |-> "need-rb-energy",
   scope |-> GameScope("rb-survival"),
   fields |-> Map(<<
     Entry("cardinality", String("one")),
     Entry("question", String("energy-rule")),
     Entry("target", Map(<<Entry("identity", String("rb-energy-rule")), Entry("kind", String("knowledge"))>>))
   >>)],

  [owner |-> "Inference", kind |-> "resolution_request", identity |-> "request-rb-energy",
   scope |-> GameScope("rb-survival"),
   fields |-> Map(<<
     Entry("need", String("need-rb-energy")),
     Entry("search_boundary", String("rb-sufficient")),
     Entry("selection_policy", String("select-one-compatible")),
     Entry("source_basis_set", BasisSet(<<RB>>))
   >>)],

  [owner |-> "Inference", kind |-> "resolution_request", identity |-> "request-multi",
   scope |-> GameScope("rb-survival"),
   fields |-> Map(<<
     Entry("need", String("need-rb-energy")),
     Entry("search_boundary", String("rb-sufficient")),
     Entry("selection_policy", String("select-one-compatible")),
     Entry("source_basis_set", BasisSet(<<RB, Terr>>))
   >>)],

  [owner |-> "Inference", kind |-> "resolution_result", identity |-> "result-resolved",
   scope |-> GameScope("rb-survival"),
   fields |-> Map(<<
     Entry("comparison_basis", String("comparison-one")),
     Entry("payload", Map(<<Entry("value", String("energy-rule"))>>)),
     Entry("search_boundary", String("rb-sufficient")),
     Entry("semantic_need", String("need-rb-energy")),
     Entry("source_basis_set_used", BasisSet(<<RB>>)),
     Entry("status", String("resolved")),
     Entry("target_identity", String("rb-energy-rule")),
     Entry("target_kind", String("knowledge"))
   >>)],

  [owner |-> "Inference", kind |-> "resolution_result", identity |-> "result-empty",
   scope |-> GameScope("rb-survival"),
   fields |-> Map(<<
     Entry("comparison_basis", String("comparison-empty")),
     Entry("payload", Map(<<>>)),
     Entry("search_boundary", String("rb-sufficient")),
     Entry("semantic_need", String("need-rb-energy")),
     Entry("source_basis_set_used", BasisSet(<<RB>>)),
     Entry("status", String("empty")),
     Entry("target_identity", String("NoneTarget")),
     Entry("target_kind", String("knowledge"))
   >>)]
}

EncodedRecords == {Encode(record) : record \in Records}
Decode(formal) == CHOOSE record \in Records : Encode(record) = formal

VARIABLES record, formal
vars == <<record, formal>>

Init == /\ record \in Records /\ formal = Encode(record)
Next == \/ UNCHANGED vars
        \/ \E nextRecord \in Records : record' = nextRecord /\ formal' = Encode(nextRecord)
Spec == Init /\ [][Next]_vars

TypeOK ==
  /\ record \in Records
  /\ formal \in EncodedRecords
  /\ formal.tag = "record"
  /\ formal.fields.tag = record.kind \o "_fields"

EncodeDecodeRecord == Decode(Encode(record)) = record
EncodeDecodeFormal == Encode(Decode(formal)) = formal
EncodingInjective == \A left, right \in Records : Encode(left) = Encode(right) => left = right
CanonicalTagsPreserved ==
  /\ formal.owner.value = record.owner
  /\ formal.kind.value = record.kind
  /\ formal.identity.value = record.identity
  /\ formal.scope.value = record.scope
  /\ formal.fields.value = record.fields

=============================================================================
