import 'package:fluent_ui/fluent_ui.dart';
import 'package:tdmm/diagram/diagram_data/attribute_data.dart';
import 'package:tdmm/diagram/diagram_data/data_type_data.dart';
import 'package:tdmm/diagram/diagram_data/key_type_data.dart';

class TableData {
  Offset position;
  Size size;
  String name;
  List<AttributeData> attributes;

  TableData({
    required this.position,
    this.size = const Size(200, 100),
    this.name = 'Table',
    List<AttributeData>? attributes,
  }) : attributes = attributes ?? [
      AttributeData(
        name: "id",
        isNotNull: true,
        key: KeyTypeData.primary
      ),
      AttributeData(
        name: "name",
        dataType: DataTypeData.varchar
      ),
    ];
}