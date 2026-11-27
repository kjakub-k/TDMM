import 'package:tdmm/diagram/diagram_relationships/diagram_relationship_data.dart';

enum DiagramMode {
  select,
  placeTable,
  placeTables,
  eraseTableOrRelationship,
  placeOneToOne,
  placeOneToMany,
  placeManyToMany;

  bool get isRelationshipMode =>
      this == placeOneToOne ||
      this == placeOneToMany ||
      this == placeManyToMany;

  RelationshipCardinality? get targetCardinality {
    switch (this) {
      case DiagramMode.placeOneToOne:
        return RelationshipCardinality.oneToOne;
      case DiagramMode.placeOneToMany:
      case DiagramMode.placeManyToMany:
        return RelationshipCardinality.oneToMany;
      default:
        return null;
    }
  }
}
