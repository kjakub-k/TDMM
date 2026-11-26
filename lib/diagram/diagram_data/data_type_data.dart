import 'package:tdmm/diagram/diagram_data/data_type_limitations.dart';

class DataTypeData {
  final String name;
  final List<DataTypeCapability> capabilities;
  final String? category;

  const DataTypeData({
    required this.name,
    required this.capabilities,
    this.category,
  });

  static Map<String, List<DataTypeData>> get groupedValues {
    final groups = <String, List<DataTypeData>>{};

    for (final type in values) {
      final category = type.category ?? 'Other';
      groups.putIfAbsent(category, () => []).add(type);
    }

    return groups;
  }

  static const List<DataTypeData> values = [
    // Numeric
    smallint,
    integer,
    bigint,
    numeric,
    real,
    doublePrecision,
    money,

    // Character
    char,
    varchar,
    text,

    // Boolean
    boolean,

    // Identifier
    uuid,
    serial,
    bigserial,

    // Date & Time
    date,
    time,
    timetz,
    timestamp,
    timestamptz,
    interval,

    // Network
    cidr,
    inet,
    macaddr,
    macaddr8,

    // Special
    json,
    jsonb,
    bytea,
    xml,
    bit,
    bitvarying,
  ];

  // Numeric
  static const smallint = DataTypeData(
    name: "SMALLINT",
    capabilities: [
      DataTypeCapability.autoIncrement
    ],
    category: "Numeric"
  );
  static const integer = DataTypeData(
    name: "INTEGER",
    capabilities: [
      DataTypeCapability.autoIncrement
    ],
    category: "Numeric"
  );
  static const bigint = DataTypeData(
    name: "BIGINT",
    capabilities: [
      DataTypeCapability.autoIncrement
    ],
    category: "Numeric"
  );
  static const numeric = DataTypeData(
    name: "NUMERIC",
    capabilities: [
      DataTypeCapability.lengthFirst,
      DataTypeCapability.lengthSecond
    ],
    category: "Numeric"
  );
  static const real = DataTypeData(
    name: "REAL",
    capabilities: [],
    category: "Numeric"
  );
  static const doublePrecision = DataTypeData(
    name: "DOUBLE PRECISION",
    capabilities: [],
    category: "Numeric"
  );
  static const money = DataTypeData(
    name: "MONEY",
    capabilities: [],
    category: "Numeric"
  );
  // Character 
  static const char = DataTypeData(
    name: "CHAR",
    capabilities: [
      DataTypeCapability.lengthFirst
    ],
    category: "Character"
  );
  static const varchar = DataTypeData(
    name: "VARCHAR",
    capabilities: [
      DataTypeCapability.lengthFirst
    ],
    category: "Character"
  );
  static const text = DataTypeData(
    name: "TEXT",
    capabilities: [],
    category: "Character"
  );
  // Boolean
  static const boolean = DataTypeData(
    name: "BOOLEAN",
    capabilities: [],
    category: "Boolean"
  );
  // Identifier
  static const uuid = DataTypeData(
    name: "UUID",
    capabilities: [
      DataTypeCapability.autoIncrement
    ],
    category: "Identifier"
  );
    static const serial = DataTypeData(
    name: "SERIAL",
    capabilities: [],
    category: "Identifier"
  );
  static const bigserial = DataTypeData(
    name: "BIGSERIAL",
    capabilities: [],
    category: "Identifier"
  );
  // Date & Time
  static const date = DataTypeData(
    name: "DATE",
    capabilities: [],
    category: "Date & Time"
  );
  static const time = DataTypeData(
    name: "TIME",
    capabilities: [
      DataTypeCapability.lengthFirst,
      DataTypeCapability.timezone
    ],
    category: "Date & Time"
  );
  static const timetz = DataTypeData(
    name: "TIMETZ",
    capabilities: [
      DataTypeCapability.lengthFirst
    ],
    category: "Date & Time"
  );
  static const timestamp = DataTypeData(
    name: "TIMESTAMP",
    capabilities: [
      DataTypeCapability.lengthFirst,
      DataTypeCapability.timezone
    ],
    category: "Date & Time"
  );
  static const timestamptz = DataTypeData(
    name: "TIMESTAMPTZ",
    capabilities: [
      DataTypeCapability.lengthFirst
    ],
    category: "Date & Time"
  );
  static const interval = DataTypeData(
    name: "INTERVAL",
    capabilities: [
      DataTypeCapability.rangeInText
    ],
    category: "Date & Time"
  );
  // Network
  static const cidr = DataTypeData(
    name: "CIDR",
    capabilities: [],
    category: "Network"
  );
  static const inet = DataTypeData(
    name: "INET",
    capabilities: [],
    category: "Network"
  );
  static const macaddr = DataTypeData(
    name: "MACADDR",
    capabilities: [],
    category: "Network"
  );
  static const macaddr8 = DataTypeData(
    name: "MACADDR8",
    capabilities: [],
    category: "Network"
  );
  // Special
  static const json = DataTypeData(
    name: "JSON",
    capabilities: [],
    category: "Special"
  );
  static const jsonb = DataTypeData(
    name: "JSONB",
    capabilities: [],
    category: "Special"
  );
  static const bytea = DataTypeData(
    name: "BYTEA",
    capabilities: [],
    category: "Special"
  );
  static const xml = DataTypeData(
    name: "XML",
    capabilities: [],
    category: "Special"
  );
  static const bit = DataTypeData(
    name: "BIT",
    capabilities: [
      DataTypeCapability.lengthFirst
    ],
    category: "Special"
  );
  static const bitvarying = DataTypeData(
    name: "BITVARYING",
    capabilities: [
      DataTypeCapability.lengthFirst
    ],
    category: "Special"
  );
}