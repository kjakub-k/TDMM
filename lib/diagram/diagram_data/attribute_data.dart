import 'package:tdmm/diagram/diagram_data/data_type_capability.dart';
import 'package:tdmm/diagram/diagram_data/data_type_data.dart';
import 'package:tdmm/diagram/diagram_data/key_type_data.dart';

class AttributeData {
  String id;
  String name;
  DataTypeData dataType;
  bool isNotNull;
  bool isUnique;
  KeyTypeData? key;

  // dole jsou vsechny limity co ne kazdy atribut ma
  bool isUnsigned;
  bool isAutoIncremental;
  bool hasTimezone;
  int setLengthFirst;
  int setLengthSecond;
  String setRangeInString;

  // vyuzita cizimi klicy
  String? relationshipId;
  String? referencedTableId;
  String? referencedAttributeId;

  AttributeData({
    required this.id,
    required this.name,
    this.dataType = DataTypeData.integer,
    this.isNotNull = false,
    this.isUnique = false,
    this.isUnsigned = false,
    this.isAutoIncremental = false,
    this.hasTimezone = false,
    this.setLengthFirst = 0,
    this.setLengthSecond = 0,
    this.setRangeInString = "",
    this.key,
    this.relationshipId,
    this.referencedTableId,
    this.referencedAttributeId,
  });

  AttributeData clone(String newId) {
    return AttributeData(
      id: newId,
      name: name,
      dataType: dataType,
      isNotNull: isNotNull,
      isUnique: isUnique,
      isUnsigned: isUnsigned,
      isAutoIncremental: isAutoIncremental,
      hasTimezone: hasTimezone,
      setLengthFirst: setLengthFirst,
      setLengthSecond: setLengthSecond,
      setRangeInString: setRangeInString,
    );
  }

  String getDataTypeName() {
    final capabilities = dataType.capabilities;

    if (capabilities.contains(DataTypeCapability.lengthFirst)) {
      if (capabilities.contains(DataTypeCapability.lengthSecond)) {
        return '${dataType.name}($setLengthFirst, $setLengthSecond)';
      }

      return '${dataType.name}($setLengthFirst)';
    }

    if (capabilities.contains(DataTypeCapability.rangeInText)) {
      return '${dataType.name}($setRangeInString)';
    }

    return dataType.name;
  }
}