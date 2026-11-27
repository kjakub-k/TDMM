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

    Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'dataType': dataType.name,
    'isNotNull': isNotNull,
    'isUnique': isUnique,
    'key': key?.name,
    'isUnsigned': isUnsigned,
    'isAutoIncremental': isAutoIncremental,
    'hasTimezone': hasTimezone,
    'setLengthFirst': setLengthFirst,
    'setLengthSecond': setLengthSecond,
    'setRangeInString': setRangeInString,
    'relationshipId': relationshipId,
    'referencedTableId': referencedTableId,
    'referencedAttributeId': referencedAttributeId,
  };

  factory AttributeData.fromJson(Map<String, dynamic> json) {
    final keyName = json['key'] as String?;
    return AttributeData(
      id: json['id'] as String,
      name: json['name'] as String,
      dataType: DataTypeData.fromName(json['dataType'] as String?),
      isNotNull: json['isNotNull'] as bool? ?? false,
      isUnique: json['isUnique'] as bool? ?? false,
      key: keyName == null ? null : KeyTypeData.values.byName(keyName),
      isUnsigned: json['isUnsigned'] as bool? ?? false,
      isAutoIncremental: json['isAutoIncremental'] as bool? ?? false,
      hasTimezone: json['hasTimezone'] as bool? ?? false,
      setLengthFirst: json['setLengthFirst'] as int? ?? 0,
      setLengthSecond: json['setLengthSecond'] as int? ?? 0,
      setRangeInString: json['setRangeInString'] as String? ?? '',
      relationshipId: json['relationshipId'] as String?,
      referencedTableId: json['referencedTableId'] as String?,
      referencedAttributeId: json['referencedAttributeId'] as String?,
    );
  }
}