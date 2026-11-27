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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'position': {'dx': position.dx, 'dy': position.dy},
    'size': {'width': size.width, 'height': size.height},
    'attributes': attributes.map((a) => a.toJson()).toList(),
  };

  factory TableData.fromJson(Map<String, dynamic> json) {
    final pos = json['position'] as Map<String, dynamic>;
    final sz = json['size'] as Map<String, dynamic>;
    final attrs = (json['attributes'] as List<dynamic>? ?? const [])
        .map((a) => AttributeData.fromJson(a as Map<String, dynamic>))
        .toList();

    return TableData(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Tabulka',
      position: Offset(
        (pos['dx'] as num).toDouble(),
        (pos['dy'] as num).toDouble(),
      ),
      size: Size(
        (sz['width'] as num).toDouble(),
        (sz['height'] as num).toDouble(),
      ),
      attributes: attrs,
    );
  }
}
