class DiagramRelationshipData {
  final String id;

  final String sourceTableId;
  final String sourceAttributeId;

  final String destinationTableId;
  final String destinationAttributeId;

  bool isOptional;

  DiagramRelationshipData({
    required this.id,
    required this.sourceTableId,
    required this.sourceAttributeId,
    required this.destinationTableId,
    required this.destinationAttributeId,
    this.isOptional = false,
  });
}