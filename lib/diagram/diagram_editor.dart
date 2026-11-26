import 'package:tdmm/diagram/diagram_controller.dart';
import 'package:tdmm/diagram/diagram_data/table_data.dart';
import 'package:tdmm/diagram/diagram_table/diagram_table.dart';
import 'package:tdmm/diagram/diagram_table/diagram_table_properties/diagram_table_properties_panel.dart';
import 'package:tdmm/viewer/dmm_viewer.dart';
import 'package:tdmm/diagram/diagram_side_toolbar.dart';
import 'package:tdmm/diagram/diagram_top_toolbar.dart';
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
  double propertiesPanelHeight = 300;
  double minPropertiesPanelHeight = 150;
  double maxPropertiesPanelHeight = 600;

  late final DiagramController diagramController;
  late final FlyoutController flyoutController;
  late final FocusNode editorFocusNode;

  @override
  void initState() {
    super.initState();
    editorFocusNode = FocusNode();
    diagramController = DiagramController(initialCanvasSize: widget.setSize);
    flyoutController = FlyoutController();
  }
  @override
  void dispose() {
    editorFocusNode.dispose();
    diagramController.dispose();
    flyoutController.dispose();
    super.dispose();
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
      diagramController.deleteSelectedTable();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.keyD) {
      diagramController.duplicateSelectedTable();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void showTableContextMenu(
  Offset position,
  TableData table,
  ) {
    flyoutController.showFlyout<void>(
      position: position,
      builder: (context) {
        return MenuFlyout(
          items: [
            MenuFlyoutItem(
              leading: const Icon(FluentIcons.edit),
              text: const Text('Upravit'),
              onPressed: () => diagramController.openTableProperties(table.id),
            ),
            MenuFlyoutItem(
              leading: const Icon(FluentIcons.copy),
              text: const Text('Duplikovat'),
              onPressed: () => diagramController.duplicateTable(table.id),
            ),
            const MenuFlyoutSeparator(),
            MenuFlyoutItem(
              leading: const Icon(FluentIcons.delete),
              text: const Text('Smazat'),
              onPressed: () => diagramController.deleteTable(table.id),
            ),
          ],
        );
      },
    );
  }

  List<DiagramTable> buildTables() {
    return [
      for (final table in diagramController.tables)
        DiagramTable(
          key: ValueKey(table.id),
          table: table,
          selected: diagramController.selectedTableId == table.id,
          onSelect: () {
            editorFocusNode.requestFocus();
            diagramController.selectTable(table.id);
          },
          onMove: (delta) => diagramController.moveTable(table.id, delta),
          onResize: (delta) => diagramController.resizeTable(table.id, delta),
          onDoubleTap: () => diagramController.openTableProperties(table.id),
          onDelete: () => diagramController.deleteTable(table.id),
          onDuplicate: () => diagramController.duplicateTable(table.id),
          onShowContextMenu: (position) => showTableContextMenu(position, table),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: editorFocusNode,
      autofocus: true,
      onKeyEvent: handleKeyEvent,
      child: ListenableBuilder(
        listenable: diagramController,
        builder: (context, _) {
          final editingTable = diagramController.editingTable;

          return NavigationView(
            content: ScaffoldPage(
              padding: EdgeInsets.zero,
              content: Focus(
                autofocus: true,
                onKeyEvent: handleKeyEvent,
                child: Row(
                  children: [
                    DiagramSideToolbar(
                      currentDiagramMode: diagramController.mode,
                      onDiagramModeChanged: diagramController.setMode,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          DiagramTopToolbar(
                            viewerBackground: diagramController.background,
                            onBackgroundChanged: diagramController.setBackground,
                            viewerSize: diagramController.canvasSize,
                            onViewerSizeChanged: diagramController.setCanvasSize,
                          ),
                          Expanded(
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: FlyoutTarget(
                                    controller: flyoutController,
                                    child: DMMViewer(
                                      viewerSize: diagramController.canvasSize,
                                      background: diagramController.background,
                                      elements: buildTables(),
                                      onViewerClick: (pos) {
                                        editorFocusNode.requestFocus();
                                        diagramController.handleCanvasClick(pos);
                                      },
                                      onViewerResize: diagramController.resizeCanvas,
                                    ),
                                  ),
                                ),
                                if (editingTable != null)
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    height: propertiesPanelHeight,
                                    child: DiagramTablePropertiesPanel(
                                      table: editingTable,
                                      controller: diagramController,
                                      onResizeDelta: (delta) {
                                        setState(() {
                                          propertiesPanelHeight =
                                              (propertiesPanelHeight - delta)
                                                  .clamp(
                                                    minPropertiesPanelHeight,
                                                    maxPropertiesPanelHeight,
                                                  );
                                        });
                                      },
                                    ),
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
                                  '${diagramController.canvasSize.width.toInt()} × ${diagramController.canvasSize.height.toInt()}',
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
        },
      ),
    );
  }
}
