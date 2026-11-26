import 'package:fluent_ui/fluent_ui.dart';
import 'package:tdmm/diagram/diagram_data/attribute_data.dart';
import 'package:tdmm/diagram/diagram_data/data_type_data.dart';
import 'package:tdmm/diagram/diagram_data/key_type_data.dart';
import 'package:uuid/uuid.dart';

class TableData {
  String id;
  Offset position;
  Size size;
  String name;
  List<AttributeData> attributes;

  TableData({
    required this.id,
    required this.position,
    this.size = const Size(200, 100),
    this.name = 'Tabulka',
    List<AttributeData>? attributes,
  }) : attributes = attributes ?? [
      AttributeData(
        id: Uuid().v4(),
        name: "id",
        isNotNull: true,
        key: KeyTypeData.primary
      ),
      AttributeData(
        id: Uuid().v4(),
        name: "nazev",
        dataType: DataTypeData.varchar
      ),
    ];
  
  TableData clone(String newId) {
    List<AttributeData> clonedAttributes = [];

    for (final attribute in attributes) {
      if (attribute.key == null) {
        clonedAttributes.add(attribute.clone(Uuid().v4()));
      }
    }

    return TableData(
      id: newId,
      position: position + const Offset(20, 20),
      size: size,
      name: name,
      attributes: clonedAttributes,
    );
  } 
}
