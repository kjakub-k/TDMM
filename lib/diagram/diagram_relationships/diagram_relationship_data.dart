enum RelationshipCardinality {
  oneToOne,
  oneToMany,
}

class DiagramRelationshipData {
  final String id;

  final String sourceTableId;
  final String sourceAttributeId;

  final String destinationTableId;
  final String destinationAttributeId;

  RelationshipCardinality cardinality;
  bool isSourceOptional;
  bool isDestinationOptional;
  bool isTransferable;

  bool get isOptional => isSourceOptional || isDestinationOptional;

  DiagramRelationshipData({
    required this.id,
    required this.sourceTableId,
    required this.sourceAttributeId,
    required this.destinationTableId,
    required this.destinationAttributeId,
    this.cardinality = RelationshipCardinality.oneToMany,
    this.isSourceOptional = false,
    this.isDestinationOptional = false,
    this.isTransferable = true,
  });
}
