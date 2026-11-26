import 'package:fluent_ui/fluent_ui.dart';
import 'package:tdmm/diagram/diagram_data/attribute_data.dart';
import 'package:tdmm/diagram/diagram_data/key_type_data.dart';
import 'package:tdmm/diagram/diagram_data/table_data.dart';
import 'package:tdmm/diagram/diagram_relationships/diagram_relationship_data.dart';
import 'package:uuid/uuid.dart';

mixin DiagramRelationshipFunctions<T extends StatefulWidget> on State<T> {
  List<TableData> get tables;
  List<DiagramRelationshipData> get relationships;
  String? get pendingSourceTableId;
  set pendingSourceTableId(String? value);
  String? get pendingSourceAttributeId;
  set pendingSourceAttributeId(String? value);

  void beginRelationship(
    String tableId,
    String attributeId,
  ) {
    final table = tables.firstWhere((t) => t.id == tableId);

    final attribute = table.attributes.firstWhere(
      (a) => a.id == attributeId,
    );

    if (attribute.key != KeyTypeData.primary) return;

    setState(() {
      pendingSourceTableId = tableId;
      pendingSourceAttributeId = attributeId;
    });
  }

  void completeRelationship(String destinationTableId) {
    if (pendingSourceTableId == null ||
        pendingSourceAttributeId == null) {
      return;
    }

    if (pendingSourceTableId == destinationTableId) return;

    final sourceTable = tables.firstWhere(
      (t) => t.id == pendingSourceTableId,
    );

    final sourceAttribute = sourceTable.attributes.firstWhere(
      (a) => a.id == pendingSourceAttributeId,
    );

    final destinationTable = tables.firstWhere(
      (t) => t.id == destinationTableId,
    );

    setState(() {
      final relationshipId = const Uuid().v4();

      final foreignKey = AttributeData(
        id: Uuid().v4(),
        name: '${sourceTable.name}_${sourceAttribute.name}',
        dataType: sourceAttribute.dataType,
        key: KeyTypeData.foreign,
        relationshipId: relationshipId,
        referencedTableId: sourceTable.id,
        referencedAttributeId: sourceAttribute.id,
      );

      destinationTable.attributes.add(foreignKey);

      relationships.add(
        DiagramRelationshipData(
          id: relationshipId,
          sourceTableId: sourceTable.id,
          sourceAttributeId: sourceAttribute.id,
          destinationTableId: destinationTable.id,
          destinationAttributeId: foreignKey.id,
        ),
      );

      pendingSourceTableId = null;
      pendingSourceAttributeId = null;
    });
  }

  void deleteRelationship(String relationshipId) {
    setState(() {
      final relationship = relationships.firstWhere(
        (r) => r.id == relationshipId,
      );

      final destinationTable = tables.firstWhere(
        (t) => t.id == relationship.destinationTableId,
      );

      destinationTable.attributes.removeWhere(
        (attribute) => attribute.id == relationship.destinationAttributeId,
      );

      relationships.removeWhere(
        (r) => r.id == relationshipId,
      );
    });
  }
}