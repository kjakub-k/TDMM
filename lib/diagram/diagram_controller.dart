import 'package:fluent_ui/fluent_ui.dart';
import 'package:tdmm/diagram/diagram_data/attribute_data.dart';
import 'package:tdmm/diagram/diagram_data/key_type_data.dart';
import 'package:tdmm/diagram/diagram_data/table_data.dart';
import 'package:tdmm/diagram/diagram_mode.dart';
import 'package:tdmm/diagram/diagram_relationships/diagram_relationship_data.dart';
import 'package:tdmm/viewer/viewer_background.dart';
import 'package:uuid/uuid.dart';

class DiagramController extends ChangeNotifier {
  static const _uuid = Uuid();
  static const double minCanvasWidth = 400;
  static const double minCanvasHeight = 300;
  static const double minTableWidth = 120;
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
  String? get editingTableId => _editingTableId;
  String? get pendingSourceTableId => _pendingSourceTableId;
  String? get pendingSourceAttributeId => _pendingSourceAttributeId;

  TableData? get selectedTable => _findTableById(_selectedTableId);
  TableData? get editingTable => _findTableById(_editingTableId);

  TableData? _findTableById(String? id) {
    if (id == null) return null;
    for (final table in _tables) {
      if (table.id == id) return table;
    }
    return null;
  }

  // --- Canvas & Mode ---

  void setMode(DiagramMode newMode) {
    if (_mode == newMode) return;
    _mode = newMode;
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

    if (_mode == DiagramMode.placeTable) {
      final newTable = TableData(
        id: _uuid.v4(),
        position: clickPosition,
      );
      _tables.add(newTable);
      _selectedTableId = newTable.id;
      _mode = DiagramMode.select;
    }

    notifyListeners();
  }

  // --- Table Operations ---

  void selectTable(String? tableId) {
    if (_selectedTableId == tableId) return;
    _selectedTableId = tableId;
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
    table.size = Size(
      (table.size.width + delta.dx).clamp(minTableWidth, 10000.0),
      (table.size.height + delta.dy).clamp(minTableHeight, 10000.0),
    );
    notifyListeners();
  }

  void deleteTable(String tableId) {
    final connectedIds = _relationships
        .where((r) => r.sourceTableId == tableId || r.destinationTableId == tableId)
        .map((r) => r.id)
        .toList();
    for (final relId in connectedIds) {
      deleteRelationship(relId, notify: false);
    }

    _tables.removeWhere((t) => t.id == tableId);

    if (_selectedTableId == tableId) _selectedTableId = null;
    if (_editingTableId == tableId) _editingTableId = null;
    if (_pendingSourceTableId == tableId) {
      _pendingSourceTableId = null;
      _pendingSourceAttributeId = null;
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

    _tables.add(copy);
    if (selectCopy) {
      _selectedTableId = copy.id;
    }
    notifyListeners();
  }

  void deleteSelectedTable() {
    if (_selectedTableId != null) {
      deleteTable(_selectedTableId!);
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
    notifyListeners();
  }

  void deleteAttribute(String tableId, int index) {
    final table = _findTableById(tableId);
    if (table == null || index < 0 || index >= table.attributes.length) return;
    final removed = table.attributes.removeAt(index);
    if (removed.relationshipId != null) {
      _relationships.removeWhere((r) => r.id == removed.relationshipId);
    }
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

  void beginRelationship(String tableId, String attributeId) {
    final table = _findTableById(tableId);
    if (table == null) return;

    final attribute = table.attributes.where((a) => a.id == attributeId).firstOrNull;
    if (attribute == null || attribute.key != KeyTypeData.primary) return;

    _pendingSourceTableId = tableId;
    _pendingSourceAttributeId = attributeId;
    notifyListeners();
  }

  void completeRelationship(String destinationTableId) {
    if (_pendingSourceTableId == null || _pendingSourceAttributeId == null) {
      return;
    }
    if (_pendingSourceTableId == destinationTableId) return;

    final sourceTable = _findTableById(_pendingSourceTableId);
    final destinationTable = _findTableById(destinationTableId);
    if (sourceTable == null || destinationTable == null) return;

    final sourceAttribute = sourceTable.attributes
        .where((a) => a.id == _pendingSourceAttributeId)
        .firstOrNull;
    if (sourceAttribute == null) return;

    final relationshipId = _uuid.v4();
    final foreignKey = AttributeData(
      id: _uuid.v4(),
      name: '${sourceTable.name}_${sourceAttribute.name}',
      dataType: sourceAttribute.dataType,
      key: KeyTypeData.foreign,
      relationshipId: relationshipId,
      referencedTableId: sourceTable.id,
      referencedAttributeId: sourceAttribute.id,
    );

    destinationTable.attributes.add(foreignKey);
    _relationships.add(
      DiagramRelationshipData(
        id: relationshipId,
        sourceTableId: sourceTable.id,
        sourceAttributeId: sourceAttribute.id,
        destinationTableId: destinationTable.id,
        destinationAttributeId: foreignKey.id,
      ),
    );

    _pendingSourceTableId = null;
    _pendingSourceAttributeId = null;
    notifyListeners();
  }

  void deleteRelationship(String relationshipId, {bool notify = true}) {
    final relationship =
        _relationships.where((r) => r.id == relationshipId).firstOrNull;
    if (relationship == null) return;

    final destinationTable = _findTableById(relationship.destinationTableId);
    destinationTable?.attributes.removeWhere(
      (a) => a.id == relationship.destinationAttributeId,
    );
    _relationships.removeWhere((r) => r.id == relationshipId);

    if (notify) notifyListeners();
  }
}