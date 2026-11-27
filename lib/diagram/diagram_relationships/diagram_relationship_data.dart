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

    Map<String, dynamic> toJson() => {
    'id': id,
    'sourceTableId': sourceTableId,
    'sourceAttributeId': sourceAttributeId,
    'destinationTableId': destinationTableId,
    'destinationAttributeId': destinationAttributeId,
    'cardinality': cardinality.name,
    'isSourceOptional': isSourceOptional,
    'isDestinationOptional': isDestinationOptional,
    'isTransferable': isTransferable,
  };

  factory DiagramRelationshipData.fromJson(Map<String, dynamic> json) {
    return DiagramRelationshipData(
      id: json['id'] as String,
      sourceTableId: json['sourceTableId'] as String,
      sourceAttributeId: json['sourceAttributeId'] as String,
      destinationTableId: json['destinationTableId'] as String,
      destinationAttributeId: json['destinationAttributeId'] as String,
      cardinality: RelationshipCardinality.values.byName(
        json['cardinality'] as String? ?? 'oneToMany',
      ),
      isSourceOptional: json['isSourceOptional'] as bool? ?? false,
      isDestinationOptional: json['isDestinationOptional'] as bool? ?? false,
      isTransferable: json['isTransferable'] as bool? ?? true,
    );
  }
}
