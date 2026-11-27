import 'dart:async';

import 'package:tdmm/diagram/diagram_controller.dart';
import 'package:tdmm/diagram/diagram_data/table_data.dart';
import 'package:tdmm/diagram/diagram_logic.dart';
import 'package:tdmm/diagram/diagram_mode.dart';
import 'package:tdmm/diagram/diagram_relationships/diagram_relationship_painter.dart';
import 'package:tdmm/diagram/diagram_relationships/relationship_floating_panel.dart';
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
  late final GlobalKey<DiagramViewerState> viewerKey;
  Timer? _autoSaveTimer;

  @override
  void initState() {
    super.initState();
    editorFocusNode = FocusNode();
    diagramController = DiagramController(initialCanvasSize: widget.setSize);
    flyoutController = FlyoutController();
    viewerKey = GlobalKey<DiagramViewerState>();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    editorFocusNode.dispose();
    diagramController.dispose();
    flyoutController.dispose();
    super.dispose();
  }

  String? _currentFilePath;

  Future<void> _saveDiagram({bool saveAs = false}) async {
    final savedPath = await saveDiagramTdmm(
      diagramController.toJson(),
      existingPath: saveAs ? null : _currentFilePath,
    );
    if (savedPath != null && mounted) {
      setState(() => _currentFilePath = savedPath);
    }
  }

  Future<void> _loadDiagram() async {
    try {
      final result = await loadDiagramTdmm();
      if (result == null) return;

      diagramController.loadFromJson(result.data);
      if (mounted) {
        setState(() => _currentFilePath = result.path);
      }
    } catch (e) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => ContentDialog(
          title: const Text('Chyba při načítání'),
          content: Text('Soubor se nepodařilo načíst: $e'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _exportDiagram(DiagramExportFormat format) async {
    if (diagramController.selectedTableId != null ||
        diagramController.selectedRelationshipId != null) {
      diagramController.selectTable(null);
      await WidgetsBinding.instance.endOfFrame;
    }

    final image = await viewerKey.currentState?.captureImage();
    if (image == null) return;

    try {
      await exportDiagramImage(image, format: format);
    } finally {
      image.dispose();
    }
  }

  KeyEventResult handleKeyEvent(
    FocusNode node,
    KeyEvent event,
  ) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (diagramController.mode != DiagramMode.select ||
          diagramController.pendingSourceAttributeId != null) {
        diagramController.cancelModeToSelect();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    final primaryWidget = FocusManager.instance.primaryFocus?.context?.widget;
    final isEditingText = primaryWidget is EditableText;

    if (!isEditingText && event.logicalKey == LogicalKeyboardKey.delete) {
      if (diagramController.selectedTableId != null ||
          diagramController.selectedRelationshipId != null) {
        diagramController.deleteSelected();
        return KeyEventResult.handled;
      }
    }

    if (!HardwareKeyboard.instance.isControlPressed) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.keyX) {
      diagramController.deleteSelected();
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

  Future<void> showRelationshipContextMenu(
    Offset fallbackPosition,
    String relationshipId,
  ) async {
    final midCanvas = diagramController.getRelationshipMidpoint(relationshipId);
    final midGlobal = midCanvas != null
        ? viewerKey.currentState?.canvasToGlobal(midCanvas)
        : null;
    final anchorPosition = (midGlobal ?? fallbackPosition) - const Offset(0, 14);

    await flyoutController.showFlyout<void>(
      position: anchorPosition,
      placementMode: FlyoutPlacementMode.topCenter,
      builder: (flyoutContext) {
        return ListenableBuilder(
          listenable: diagramController,
          builder: (context, _) {
            return RelationshipFloatingPanel(
              controller: diagramController,
              relationshipId: relationshipId,
              onDeleted: () => Navigator.of(flyoutContext).maybePop(),
            );
          },
        );
      },
    );

    if (diagramController.selectedRelationshipId == relationshipId) {
      diagramController.selectRelationship(null);
    }
  }

  List<DiagramTable> buildTables() {
    final relationships = diagramController.relationships;
    return [
      for (final table in diagramController.tables)
        DiagramTable(
          key: ValueKey(table.id),
          table: table,
          relationships: relationships,
          mode: diagramController.mode,
          pendingSourceTableId: diagramController.pendingSourceTableId,
          pendingSourceAttributeId: diagramController.pendingSourceAttributeId,
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
          onAttributeTap: (attributeId) {
            editorFocusNode.requestFocus();
            diagramController.handleRelationshipAttributeTap(
              table.id,
              attributeId,
            );
          },
          onTableTap: () {
            editorFocusNode.requestFocus();
            diagramController.handleRelationshipTableTap(table.id);
          },
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

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
              content: Row(
                children: [
                  DiagramSideToolbar(
                    currentDiagramMode: diagramController.mode,
                    onDiagramModeChanged: (newMode) {
                      editorFocusNode.requestFocus();
                      diagramController.setMode(newMode);
                    },
                    onCancelRelationshipMode:
                        diagramController.cancelModeToSelect,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        DiagramTopToolbar(
                          viewerBackground: diagramController.background,
                          onBackgroundChanged: diagramController.setBackground,
                          viewerSize: diagramController.canvasSize,
                          onViewerSizeChanged: diagramController.setCanvasSize,
                          onSave: () => _saveDiagram(),
                          onSaveAs: () => _saveDiagram(saveAs: true),
                          onLoad: _loadDiagram,
                          onExportJpeg: () => _exportDiagram(DiagramExportFormat.jpeg),
                          onExportPng: () => _exportDiagram(DiagramExportFormat.png),
                        ),
                        Expanded(
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: FlyoutTarget(
                                  controller: flyoutController,
                                  child: DMMViewer(
                                    key: viewerKey,
                                    viewerSize: diagramController.canvasSize,
                                    background: diagramController.background,
                                    relationshipLayer: CustomPaint(
                                      painter: DiagramRelationshipPainter(
                                        tables: diagramController.tables,
                                        relationships:
                                            diagramController.relationships,
                                        selectedRelationshipId:
                                            diagramController
                                                .selectedRelationshipId,
                                        accentColor: theme.accentColor,
                                      ),
                                    ),
                                    elements: buildTables(),
                                    onViewerClick: (pos) {
                                      editorFocusNode.requestFocus();
                                      diagramController.handleCanvasClick(pos);
                                    },
                                    onViewerTap: (localPos, globalPos) {
                                      if (diagramController.mode !=
                                          DiagramMode.select) {
                                        return;
                                      }
                                      final hitRel = diagramController
                                          .hitTestRelationship(localPos);
                                      if (hitRel != null) {
                                        showRelationshipContextMenu(
                                          globalPos,
                                          hitRel.id,
                                        );
                                      }
                                    },
                                    onViewerResize:
                                        diagramController.resizeCanvas,
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
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
