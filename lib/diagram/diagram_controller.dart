import 'dart:math' as math;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:tdmm/diagram/diagram_data/attribute_data.dart';
import 'package:tdmm/diagram/diagram_data/key_type_data.dart';
import 'package:tdmm/diagram/diagram_data/table_data.dart';
import 'package:tdmm/diagram/diagram_mode.dart';
import 'package:tdmm/diagram/diagram_relationships/diagram_relationship_data.dart';
import 'package:tdmm/diagram/diagram_relationships/diagram_relationship_layout.dart';
import 'package:tdmm/viewer/viewer_background.dart';
import 'package:uuid/uuid.dart';

class DiagramController extends ChangeNotifier {
  static const _uuid = Uuid();
  static const double minCanvasWidth = 400;
  static const double minCanvasHeight = 300;
  static const double minTableWidth = DiagramTableLayout.minTableWidth;
  static const double minTableHeight = 70;

  DiagramController({
    required Size initialCanvasSize,
  }) : _canvasSize = initialCanvasSize;

  final List<TableData> _tables = [];
  final List<DiagramRelationshipData> _relationships = [];

  ViewerBackground _background = ViewerBackground();
  DiagramMode _mode = DiagramMode.select;
  Size _canvasSize;

  String? _selectedTableId;
  String? _selectedRelationshipId;
  String? _editingTableId;
  String? _pendingSourceTableId;
  String? _pendingSourceAttributeId;

  List<TableData> get tables => List.unmodifiable(_tables);
  List<DiagramRelationshipData> get relationships =>
      List.unmodifiable(_relationships);
  ViewerBackground get background => _background;
  DiagramMode get mode => _mode;
  Size get canvasSize => _canvasSize;
  String? get selectedTableId => _selectedTableId;
  String? get selectedRelationshipId => _selectedRelationshipId;
  String? get editingTableId => _editingTableId;
  String? get pendingSourceTableId => _pendingSourceTableId;
  String? get pendingSourceAttributeId => _pendingSourceAttributeId;

  TableData? get selectedTable => findTableById(_selectedTableId);
  TableData? get editingTable => findTableById(_editingTableId);

  TableData? findTableById(String? id) {
    if (id == null) return null;
    for (final table in _tables) {
      if (table.id == id) return table;
    }
    return null;
  }

  TableData? _findTableById(String? id) => findTableById(id);

  double getRowHeight(AttributeData attribute) =>
      DiagramTableLayout.getRowHeight(attribute, _relationships);

  double getMinTableHeight(TableData table) =>
      DiagramTableLayout.getMinTableHeight(table, _relationships);

  void _ensureTableFits(TableData table) {
    final minHeight = getMinTableHeight(table);
    final nextWidth = math.max(table.size.width, minTableWidth);
    final nextHeight = math.max(table.size.height, minHeight);
    if (nextWidth != table.size.width || nextHeight != table.size.height) {
      table.size = Size(nextWidth, nextHeight);
    }
  }

  void _clearPendingRelationship() {
    _pendingSourceTableId = null;
    _pendingSourceAttributeId = null;
  }

  // --- Canvas & Mode ---

  void setMode(DiagramMode newMode) {
    if (_mode == newMode) return;
    _mode = newMode;
    _clearPendingRelationship();
    if (newMode != DiagramMode.select) {
      _selectedRelationshipId = null;
    }
    notifyListeners();
  }

  void cancelModeToSelect() {
    final hadPending =
        _pendingSourceTableId != null || _pendingSourceAttributeId != null;
    if (_mode == DiagramMode.select && !hadPending) return;
    _mode = DiagramMode.select;
    _clearPendingRelationship();
    notifyListeners();
  }

  void resizeCanvas(Offset delta) {
    _canvasSize = Size(
      (_canvasSize.width + delta.dx).clamp(minCanvasWidth, 10000.0),
      (_canvasSize.height + delta.dy).clamp(minCanvasHeight, 10000.0),
    );
    notifyListeners();
  }

  void setCanvasSize(Size newSize) {
    _canvasSize = newSize;
    notifyListeners();
  }

  void setBackground(ViewerBackground newBackground) {
    _background = ViewerBackground(
      image: newBackground.image,
      mode: newBackground.mode,
    );
    notifyListeners();
  }

  void handleCanvasClick(Offset clickPosition) {
    _selectedTableId = null;

    if (_mode.isRelationshipMode) {
      _selectedRelationshipId = null;
      _clearPendingRelationship();
      _mode = DiagramMode.select;
      notifyListeners();
      return;
    }

    if (_mode == DiagramMode.placeTable) {
      final newTable = TableData(
        id: _uuid.v4(),
        position: clickPosition,
      );
      _ensureTableFits(newTable);
      _tables.add(newTable);
      _selectedTableId = newTable.id;
      _selectedRelationshipId = null;
      _mode = DiagramMode.select;
      notifyListeners();
      return;
    }

    final hitRel = hitTestRelationship(clickPosition);

    if (_mode == DiagramMode.eraseTableOrRelationship) {
      if (hitRel != null) {
        deleteRelationship(hitRel.id);
        return;
      }
      _selectedRelationshipId = null;
      notifyListeners();
      return;
    }

    _selectedRelationshipId = hitRel?.id;
    notifyListeners();
  }

  DiagramRelationshipData? hitTestRelationship(Offset position) {
    return DiagramTableLayout.hitTestRelationship(
      position,
      DiagramTableLayout.computeAllGeometries(_tables, _relationships),
    )?.relationship;
  }

  DiagramRelationshipData? findRelationshipById(String? id) {
    if (id == null) return null;
    for (final rel in _relationships) {
      if (rel.id == id) return rel;
    }
    return null;
  }

  Offset? getRelationshipMidpoint(String relationshipId) {
    final geometries = DiagramTableLayout.computeAllGeometries(
      _tables,
      _relationships,
    );
    for (final geometry in geometries) {
      if (geometry.relationship.id == relationshipId &&
          geometry.points.length >= 4) {
        final p1 = geometry.points[1];
        final p2 = geometry.points[2];
        return Offset(p1.dx, (p1.dy + p2.dy) / 2);
      }
    }
    return null;
  }

  // --- Table Operations ---

  void selectTable(String? tableId) {
    if (_selectedTableId == tableId && _selectedRelationshipId == null) return;
    _selectedTableId = tableId;
    _selectedRelationshipId = null;
    notifyListeners();
  }

  void selectRelationship(String? relationshipId) {
    if (_selectedRelationshipId == relationshipId && _selectedTableId == null) {
      return;
    }
    _selectedRelationshipId = relationshipId;
    _selectedTableId = null;
    notifyListeners();
  }

  void openTableProperties(String tableId) {
    _editingTableId = tableId;
    notifyListeners();
  }

  void closeTableProperties() {
    if (_editingTableId == null) return;
    _editingTableId = null;
    notifyListeners();
  }

  void moveTable(String tableId, Offset delta) {
    final table = _findTableById(tableId);
    if (table == null) return;
    table.position += delta;
    notifyListeners();
  }

  void resizeTable(String tableId, Offset delta) {
    final table = _findTableById(tableId);
    if (table == null) return;
    final minH = getMinTableHeight(table);
    table.size = Size(
      (table.size.width + delta.dx).clamp(minTableWidth, 10000.0),
      (table.size.height + delta.dy).clamp(minH, 10000.0),
    );
    notifyListeners();
  }

  void deleteTable(String tableId) {
    final connectedIds = _relationships
        .where(
          (r) => r.sourceTableId == tableId || r.destinationTableId == tableId,
        )
        .map((r) => r.id)
        .toList();
    for (final relId in connectedIds) {
      deleteRelationship(relId, notify: false);
    }

    _tables.removeWhere((t) => t.id == tableId);

    if (_selectedTableId == tableId) _selectedTableId = null;
    if (_editingTableId == tableId) _editingTableId = null;
    if (_pendingSourceTableId == tableId) {
      _clearPendingRelationship();
    }

    notifyListeners();
  }

  void duplicateTable(String tableId, {bool selectCopy = false}) {
    final original = _findTableById(tableId);
    if (original == null) return;

    final clonedAttributes = [
      for (final attr in original.attributes)
        AttributeData(
          id: _uuid.v4(),
          name: attr.name,
          dataType: attr.dataType,
          isNotNull: attr.isNotNull,
          isUnique: attr.isUnique,
          isUnsigned: attr.isUnsigned,
          isAutoIncremental: attr.isAutoIncremental,
          hasTimezone: attr.hasTimezone,
          setLengthFirst: attr.setLengthFirst,
          setLengthSecond: attr.setLengthSecond,
          setRangeInString: attr.setRangeInString,
          key: attr.key == KeyTypeData.primary ? KeyTypeData.primary : null,
        ),
    ];

    final copy = TableData(
      id: _uuid.v4(),
      position: original.position + const Offset(20, 20),
      size: original.size,
      name: original.name,
      attributes: clonedAttributes,
    );
    _ensureTableFits(copy);

    _tables.add(copy);
    if (selectCopy) {
      _selectedTableId = copy.id;
      _selectedRelationshipId = null;
    }
    notifyListeners();
  }

  void deleteSelectedTable() {
    if (_selectedTableId != null) {
      deleteTable(_selectedTableId!);
    }
  }

  void deleteSelected() {
    if (_selectedTableId != null) {
      deleteTable(_selectedTableId!);
    } else if (_selectedRelationshipId != null) {
      deleteRelationship(_selectedRelationshipId!);
    }
  }

  void duplicateSelectedTable() {
    if (_selectedTableId != null) {
      duplicateTable(_selectedTableId!, selectCopy: true);
    }
  }

  // --- Table Attribute Mutations (called by Properties Panel) ---

  void renameTable(String tableId, String newName) {
    final table = _findTableById(tableId);
    if (table == null) return;
    table.name = newName;
    notifyListeners();
  }

  void addAttribute(String tableId) {
    final table = _findTableById(tableId);
    if (table == null) return;
    table.attributes.add(
      AttributeData(
        id: _uuid.v4(),
        name: 'attribute_${table.attributes.length + 1}',
      ),
    );
    _ensureTableFits(table);
    notifyListeners();
  }

  void deleteAttribute(String tableId, int index) {
    final table = _findTableById(tableId);
    if (table == null || index < 0 || index >= table.attributes.length) return;
    final removed = table.attributes.removeAt(index);

    if (removed.relationshipId != null) {
      if (_selectedRelationshipId == removed.relationshipId) {
        _selectedRelationshipId = null;
      }
      _relationships.removeWhere((r) => r.id == removed.relationshipId);
    }

    final outgoingIds = _relationships
        .where((r) => r.sourceAttributeId == removed.id)
        .map((r) => r.id)
        .toList();
    for (final relId in outgoingIds) {
      deleteRelationship(relId, notify: false);
    }

    if (_pendingSourceAttributeId == removed.id) {
      _clearPendingRelationship();
    }

    notifyListeners();
  }

  void setAttributeKey(
    String tableId,
    String attributeId,
    KeyTypeData? newKey,
  ) {
    final table = _findTableById(tableId);
    if (table == null) return;
    final attribute = table.attributes
        .where((a) => a.id == attributeId)
        .firstOrNull;
    if (attribute == null || attribute.key == KeyTypeData.foreign) return;
    if (attribute.key == newKey) return;

    if (attribute.key == KeyTypeData.primary && newKey != KeyTypeData.primary) {
      final outgoingIds = _relationships
          .where((r) => r.sourceAttributeId == attribute.id)
          .map((r) => r.id)
          .toList();
      for (final relId in outgoingIds) {
        deleteRelationship(relId, notify: false);
      }
      if (_pendingSourceAttributeId == attribute.id) {
        _clearPendingRelationship();
      }
    }

    attribute.key = newKey;
    notifyListeners();
  }

  void moveAttribute(String tableId, int index, int direction) {
    final table = _findTableById(tableId);
    if (table == null) return;
    final newIndex = index + direction;
    if (newIndex < 0 || newIndex >= table.attributes.length) return;

    final attr = table.attributes.removeAt(index);
    table.attributes.insert(newIndex, attr);
    notifyListeners();
  }

  void notifyTableEdited() => notifyListeners();

  // --- Relationships ---

  void handleRelationshipAttributeTap(String tableId, String attributeId) {
    if (!_mode.isRelationshipMode) return;

    final table = _findTableById(tableId);
    final attribute = table?.attributes
        .where((a) => a.id == attributeId)
        .firstOrNull;

    if (table == null ||
        attribute == null ||
        attribute.key != KeyTypeData.primary) {
      cancelModeToSelect();
      return;
    }

    if (_pendingSourceAttributeId == null) {
      beginRelationship(tableId, attributeId);
      return;
    }

    if (_mode == DiagramMode.placeManyToMany) {
      if (tableId == _pendingSourceTableId) {
        cancelModeToSelect();
        return;
      }
      _completeManyToMany(tableId, attributeId);
    }
  }

  void handleRelationshipTableTap(String tableId) {
    if (!_mode.isRelationshipMode) return;

    if (_pendingSourceAttributeId == null ||
        _mode == DiagramMode.placeManyToMany) {
      cancelModeToSelect();
      return;
    }

    completeRelationship(tableId);
  }

  void beginRelationship(String tableId, String attributeId) {
    final table = _findTableById(tableId);
    if (table == null) return;

    final attribute = table.attributes
        .where((a) => a.id == attributeId)
        .firstOrNull;
    if (attribute == null || attribute.key != KeyTypeData.primary) return;

    _pendingSourceTableId = tableId;
    _pendingSourceAttributeId = attributeId;
    _selectedTableId = null;
    _selectedRelationshipId = null;
    notifyListeners();
  }

  String _uniqueForeignKeyName(TableData destinationTable, String baseName) {
    final existingNames = destinationTable.attributes.map((a) => a.name).toSet();
    if (!existingNames.contains(baseName)) return baseName;
    int suffix = 2;
    while (existingNames.contains('${baseName}_$suffix')) {
      suffix++;
    }
    return '${baseName}_$suffix';
  }

  AttributeData _buildForeignKeyAttribute({
    required TableData sourceTable,
    required AttributeData sourceAttribute,
    required TableData destinationTable,
    required String relationshipId,
    required bool isUnique,
  }) {
    final baseName = '${sourceTable.name}_${sourceAttribute.name}';
    return AttributeData(
      id: _uuid.v4(),
      name: _uniqueForeignKeyName(destinationTable, baseName),
      dataType: sourceAttribute.dataType,
      isNotNull: sourceAttribute.isNotNull,
      isUnique: isUnique,
      isUnsigned: sourceAttribute.isUnsigned,
      hasTimezone: sourceAttribute.hasTimezone,
      setLengthFirst: sourceAttribute.setLengthFirst,
      setLengthSecond: sourceAttribute.setLengthSecond,
      setRangeInString: sourceAttribute.setRangeInString,
      key: KeyTypeData.foreign,
      relationshipId: relationshipId,
      referencedTableId: sourceTable.id,
      referencedAttributeId: sourceAttribute.id,
    );
  }

  void completeRelationship(String destinationTableId) {
    if (_pendingSourceTableId == null || _pendingSourceAttributeId == null) {
      return;
    }

    final sourceTable = _findTableById(_pendingSourceTableId);
    final destinationTable = _findTableById(destinationTableId);
    if (sourceTable == null || destinationTable == null) return;

    final sourceAttribute = sourceTable.attributes
        .where((a) => a.id == _pendingSourceAttributeId)
        .firstOrNull;
    if (sourceAttribute == null || sourceAttribute.key != KeyTypeData.primary) {
      return;
    }

    final cardinality =
        _mode.targetCardinality ?? RelationshipCardinality.oneToMany;
    final relationshipId = _uuid.v4();
    final foreignKey = _buildForeignKeyAttribute(
      sourceTable: sourceTable,
      sourceAttribute: sourceAttribute,
      destinationTable: destinationTable,
      relationshipId: relationshipId,
      isUnique: cardinality == RelationshipCardinality.oneToOne,
    );

    destinationTable.attributes.add(foreignKey);
    _relationships.add(
      DiagramRelationshipData(
        id: relationshipId,
        sourceTableId: sourceTable.id,
        sourceAttributeId: sourceAttribute.id,
        destinationTableId: destinationTable.id,
        destinationAttributeId: foreignKey.id,
        cardinality: cardinality,
      ),
    );

    _ensureTableFits(sourceTable);
    _ensureTableFits(destinationTable);
    _clearPendingRelationship();
    _mode = DiagramMode.select;
    notifyListeners();
  }

  void _completeManyToMany(String secondTableId, String secondAttributeId) {
    if (_pendingSourceTableId == null || _pendingSourceAttributeId == null) {
      return;
    }
    if (_pendingSourceTableId == secondTableId) return;

    final firstTable = _findTableById(_pendingSourceTableId);
    final secondTable = _findTableById(secondTableId);
    if (firstTable == null || secondTable == null) return;

    final firstAttribute = firstTable.attributes
        .where((a) => a.id == _pendingSourceAttributeId)
        .firstOrNull;
    final secondAttribute = secondTable.attributes
        .where((a) => a.id == secondAttributeId)
        .firstOrNull;

    if (firstAttribute == null ||
        secondAttribute == null ||
        firstAttribute.key != KeyTypeData.primary ||
        secondAttribute.key != KeyTypeData.primary) {
      cancelModeToSelect();
      return;
    }

    final rel1Id = _uuid.v4();
    final rel2Id = _uuid.v4();

    final junctionTable = TableData(
      id: _uuid.v4(),
      position: Offset.zero,
      name: '${firstTable.name}_${secondTable.name}',
      attributes: [],
    );

    final fk1 = _buildForeignKeyAttribute(
      sourceTable: firstTable,
      sourceAttribute: firstAttribute,
      destinationTable: junctionTable,
      relationshipId: rel1Id,
      isUnique: false,
    );
    junctionTable.attributes.add(fk1);

    final fk2 = _buildForeignKeyAttribute(
      sourceTable: secondTable,
      sourceAttribute: secondAttribute,
      destinationTable: junctionTable,
      relationshipId: rel2Id,
      isUnique: false,
    );
    junctionTable.attributes.add(fk2);

    _tables.add(junctionTable);

    _relationships.addAll([
      DiagramRelationshipData(
        id: rel1Id,
        sourceTableId: firstTable.id,
        sourceAttributeId: firstAttribute.id,
        destinationTableId: junctionTable.id,
        destinationAttributeId: fk1.id,
        cardinality: RelationshipCardinality.oneToMany,
      ),
      DiagramRelationshipData(
        id: rel2Id,
        sourceTableId: secondTable.id,
        sourceAttributeId: secondAttribute.id,
        destinationTableId: junctionTable.id,
        destinationAttributeId: fk2.id,
        cardinality: RelationshipCardinality.oneToMany,
      ),
    ]);

    _ensureTableFits(firstTable);
    _ensureTableFits(secondTable);
    _ensureTableFits(junctionTable);

    final centerA =
        firstTable.position +
        Offset(firstTable.size.width / 2, firstTable.size.height / 2);
    final centerB =
        secondTable.position +
        Offset(secondTable.size.width / 2, secondTable.size.height / 2);
    final midCenter = (centerA + centerB) / 2;
    junctionTable.position = Offset(
      math.max(0.0, midCenter.dx - junctionTable.size.width / 2),
      math.max(0.0, midCenter.dy - junctionTable.size.height / 2),
    );

    _selectedTableId = junctionTable.id;
    _selectedRelationshipId = null;
    _clearPendingRelationship();
    _mode = DiagramMode.select;
    notifyListeners();
  }

  void setRelationshipCardinality(
    String relationshipId,
    RelationshipCardinality cardinality,
  ) {
    final relationship = findRelationshipById(relationshipId);
    if (relationship == null) return;
    if (relationship.cardinality == cardinality) return;

    relationship.cardinality = cardinality;
    final destinationTable = _findTableById(relationship.destinationTableId);
    final fk = destinationTable?.attributes
        .where((a) => a.id == relationship.destinationAttributeId)
        .firstOrNull;
    if (fk != null) {
      fk.isUnique = cardinality == RelationshipCardinality.oneToOne;
    }
    notifyListeners();
  }

  void setRelationshipOptionality(
    String relationshipId, {
    bool? isSourceOptional,
    bool? isDestinationOptional,
  }) {
    final relationship = findRelationshipById(relationshipId);
    if (relationship == null) return;

    bool changed = false;
    if (isSourceOptional != null &&
        relationship.isSourceOptional != isSourceOptional) {
      relationship.isSourceOptional = isSourceOptional;
      final destinationTable = _findTableById(relationship.destinationTableId);
      final fk = destinationTable?.attributes
          .where((a) => a.id == relationship.destinationAttributeId)
          .firstOrNull;
      if (fk != null) {
        fk.isNotNull = !isSourceOptional;
      }
      changed = true;
    }

    if (isDestinationOptional != null &&
        relationship.isDestinationOptional != isDestinationOptional) {
      relationship.isDestinationOptional = isDestinationOptional;
      changed = true;
    }

    if (changed) notifyListeners();
  }

  void setRelationshipTransferable(
    String relationshipId,
    bool isTransferable,
  ) {
    final relationship = findRelationshipById(relationshipId);
    if (relationship == null) return;
    if (relationship.isTransferable == isTransferable) return;

    relationship.isTransferable = isTransferable;
    notifyListeners();
  }

  void deleteRelationship(String relationshipId, {bool notify = true}) {
    final relationship = _relationships
        .where((r) => r.id == relationshipId)
        .firstOrNull;
    if (relationship == null) return;

    final destinationTable = _findTableById(relationship.destinationTableId);
    destinationTable?.attributes.removeWhere(
      (a) => a.id == relationship.destinationAttributeId,
    );
    _relationships.removeWhere((r) => r.id == relationshipId);

    if (_selectedRelationshipId == relationshipId) {
      _selectedRelationshipId = null;
    }

    if (notify) notifyListeners();
  }
}
