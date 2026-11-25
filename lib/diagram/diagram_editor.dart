import 'package:tdmm/diagram/diagram_data/attribute_data.dart';
import 'package:tdmm/diagram/diagram_data/table_data.dart';
import 'package:tdmm/viewer/viewer_background.dart';
import 'package:tdmm/viewer/dmm_viewer.dart';
import 'package:tdmm/diagram/diagram_mode.dart';
import 'package:tdmm/diagram/diagram_side_toolbar.dart';
import 'package:tdmm/diagram/diagram_table.dart';
import 'package:tdmm/diagram/diagram_top_toolbar.dart';
import 'package:tdmm/diagram/diagram_table_properties.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';

class DiagramEditor extends StatefulWidget {
  final Size setSize;

  const DiagramEditor({
    super.key,
    required this.setSize,
  });

  @override
  State<DiagramEditor> createState() => DiagramEditorState();
}

class DiagramEditorState extends State<DiagramEditor> {
  int? selectedTableIndex;
  TableData? editingTable;

  ViewerBackground background = ViewerBackground();
  DiagramMode mode = DiagramMode.select;

  final List<TableData> tables = [];

  late Size canvasSize;

  double propertiesPanelHeight = 300;
  double minPropertiesPanelHeight = 150;
  double maxPropertiesPanelHeight = 600;

  double minCanvasWidth = 400;
  double minCanvasHeight = 300;

  @override
  void initState() {
    super.initState();
    canvasSize = widget.setSize;
  }

  void refreshEditor() {
    setState(() {});
  }

  void resizeCanvas(Offset delta) {
    setState(() {
      canvasSize = Size(
        (canvasSize.width + delta.dx)
            .clamp(minCanvasWidth, 10000.0),
        (canvasSize.height + delta.dy)
            .clamp(minCanvasHeight, 10000.0),
      );
    });
  }

  void setViewerSize(Size newSize) {
    setState(() {
      canvasSize = newSize;
    });
  }

  void selectTable(int? index) {
    setState(() {
      selectedTableIndex = index;
    });
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

  void duplicatetable(int index) {
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

  void handleOnViewerClick(Offset clickPosition) {
    selectTable(null);

    if (mode != DiagramMode.placeTable) {
      return;
    }

    setState(() {
      tables.add(TableData(position: clickPosition));
      selectedTableIndex = tables.length - 1;
      mode = DiagramMode.select;
    });
  }

  void setBackgroundImage(ViewerBackground newBackground) {
    setState(() {
      background.image = newBackground.image;
      background.mode = newBackground.mode;
    });
  }

  void setDiagramMode(DiagramMode newMode) {
    setState(() {
      mode = newMode;
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

  KeyEventResult handleKeyEvent(
    FocusNode node,
    KeyEvent event,
  ) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (!HardwareKeyboard.instance.isControlPressed) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.keyX) {
      deleteSelectedTable();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.keyD) {
      duplicateSelectedTable();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

@override
Widget build(BuildContext context) {
  final theme = FluentTheme.of(context);

  return NavigationView(
    content: ScaffoldPage(
      padding: EdgeInsets.zero,
      content: Focus(
        autofocus: true,
        onKeyEvent: handleKeyEvent,
        child: Row(
          children: [
            DiagramSideToolbar(
                onDiagramModeChanged: setDiagramMode,
                currentDiagramMode: mode,
            ),
            Expanded(
              child: Column(
                children: [
                  DiagramTopToolbar(
                    viewerBackground: background,
                    onBackgroundChanged: setBackgroundImage,
                    viewerSize: canvasSize,
                    onViewerSizeChanged: setViewerSize,
                  ),

                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Padding(
                            padding: EdgeInsets.zero,
                            child: DMMViewer(
                              viewerSize: canvasSize,
                              background: background,
                              elements: buildTables(tables),
                              onViewerClick: handleOnViewerClick,
                              onViewerResize: resizeCanvas,
                            ),
                          ),
                        ),

                        if (editingTable != null)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            height: propertiesPanelHeight,
                            child: buildPropertiesPanel(theme),
                          ),
                      ],
                    ),
                  ),

                  Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Spacer(),
                        Text(
                          '${canvasSize.width.toInt()} × ${canvasSize.height.toInt()}',
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
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
      onDuplicate: () => duplicatetable(index),
    );
  }
}
