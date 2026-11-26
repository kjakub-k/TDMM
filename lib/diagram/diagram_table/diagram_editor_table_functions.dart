import 'package:fluent_ui/fluent_ui.dart';
import 'package:tdmm/diagram/diagram_data/attribute_data.dart';
import 'package:tdmm/diagram/diagram_data/table_data.dart';
import 'package:tdmm/diagram/diagram_table/diagram_table.dart';
import 'package:tdmm/diagram/diagram_table/diagram_table_properties.dart';

mixin DiagramEditorTableFunctions<T extends StatefulWidget> on State<T> {
  int? get selectedTableIndex;
  set selectedTableIndex(int? value);
  TableData? get editingTable;
  set editingTable(TableData? value);
  List<TableData> get tables;
  double get propertiesPanelHeight;
  set propertiesPanelHeight(double value);
  double get minPropertiesPanelHeight;
  double get maxPropertiesPanelHeight;


  FlyoutController get flyoutController;

  void refreshEditor();

  void selectTable(int? index) {
    setState(() {
      selectedTableIndex = index;
    });
  }

  void showTableContextMenu(
  Offset position,
  VoidCallback onEdit,
  VoidCallback onDuplicate,
  VoidCallback onDelete,
  ) {
    flyoutController.showFlyout<void>(
      position: position,
      builder: (context) {
        return MenuFlyout(
          items: [
            MenuFlyoutItem(
              leading: const Icon(FluentIcons.edit),
              text: const Text('Upravit'),
              onPressed: onEdit,
            ),
            MenuFlyoutItem(
              leading: const Icon(FluentIcons.copy),
              text: const Text('Duplikovat'),
              onPressed: onDuplicate,
            ),
            const MenuFlyoutSeparator(),
            MenuFlyoutItem(
              leading: const Icon(FluentIcons.delete),
              text: const Text('Smazat'),
              onPressed: onDelete,
            ),
          ],
        );
      },
    );
  }

   void moveTable(int index, Offset delta) {
    setState(() {
      tables[index].position += delta;
    });
  }

  void resizeTable(int index, Offset delta) {
    const minWidth = 120.0;
    const minHeight = 70.0;

    setState(() {
      final table = tables[index];

      table.size = Size(
        (table.size.width + delta.dx).clamp(minWidth, 10000.0),
        (table.size.height + delta.dy).clamp(minHeight, 10000.0),
      );
    });
  }

  void deleteTable(int index) {
    setState(() {
      tables.removeAt(index);

      if (selectedTableIndex == index) {
        selectedTableIndex = null;
      } else if (selectedTableIndex != null &&
          selectedTableIndex! > index) {
        selectedTableIndex = selectedTableIndex! - 1;
      }
    });
  }

  void duplicateTable(int index) {
    setState(() {
      final original = tables[index];

      final copy = TableData(
        position: original.position + const Offset(20, 20),
        size: original.size,
        name: original.name,
        attributes: List<AttributeData>.from(original.attributes),
      );

      tables.add(copy);
    });
  }

  void deleteSelectedTable() {
    if (selectedTableIndex == null) return;

    deleteTable(selectedTableIndex!);
  }

  void duplicateSelectedTable() {
    if (selectedTableIndex == null) return;

    setState(() {
      final original = tables[selectedTableIndex!];

      final copy = TableData(
        position: original.position + const Offset(20, 20),
        size: original.size,
        name: original.name,
        attributes: List<AttributeData>.from(original.attributes),
      );

      tables.add(copy);
      selectedTableIndex = tables.length - 1;
    });
  }

  void editTable(TableData table) {
    setState(() {
      editingTable = table;
    });
  }

  void closeTableEditor() {
    setState(() {
      editingTable = null;
    });
  }

  Widget buildPropertiesPanel(FluentThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.micaBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Colors.black,
          ),
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onVerticalDragUpdate: (details) {
              setState(() {
                propertiesPanelHeight =
                    (propertiesPanelHeight - details.delta.dy)
                        .clamp(
                          minPropertiesPanelHeight,
                          maxPropertiesPanelHeight,
                        );
              });
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeUpDown,
              child: Container(
                height: 8,
                alignment: Alignment.center,
                child: Container(
                  width: 40,
                  height: 3,
                  decoration: BoxDecoration(
                    color: theme.resources.textFillColorSecondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: DiagramTableProperties(
              key: ObjectKey(editingTable),
              table: editingTable!,
              onTableChanged: refreshEditor,
              onClose: closeTableEditor,
            ),
          ),
        ],
      ),
    );
  }

  List<DiagramTable> buildTables(List<TableData> tableData) {
    return [
      for (int i = 0; i < tableData.length; i++)
        buildTable(tableData[i], i),
    ];
  }

  DiagramTable buildTable(TableData tableData, int index) {
    return DiagramTable(
      table: tableData,
      selected: selectedTableIndex == index,
      onSelect: () => selectTable(index),
      onMove: (delta) => moveTable(index, delta),
      onResize: (delta) => resizeTable(index, delta),
      onDoubleTap: () => editTable(tableData),
      onDelete: () => deleteTable(index),
      onDuplicate: () => duplicateTable(index),
      onShowContextMenu: (position) {
        showTableContextMenu(
          position,
          () => editTable(tableData),
          () => duplicateTable(index),
          () => deleteTable(index),
        );
      },
    );
  }
}