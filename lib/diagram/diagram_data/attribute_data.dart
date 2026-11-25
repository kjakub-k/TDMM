import 'package:tdmm/diagram/diagram_data/data_type_data.dart';
import 'package:tdmm/diagram/diagram_data/key_type_data.dart';

class AttributeData {
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

  AttributeData({
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
  });
}