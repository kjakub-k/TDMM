import 'package:tdmm/diagram/diagram_data/table_data.dart';
import 'package:tdmm/diagram/diagram_table/diagram_editor_table_functions.dart';
import 'package:tdmm/viewer/viewer_background.dart';
import 'package:tdmm/viewer/dmm_viewer.dart';
import 'package:tdmm/diagram/diagram_mode.dart';
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

class DiagramEditorState extends State<DiagramEditor> with DiagramEditorTableFunctions {
  ViewerBackground background = ViewerBackground();
  DiagramMode mode = DiagramMode.select;
  late Size canvasSize;
  double minCanvasWidth = 400;
  double minCanvasHeight = 300;

  @override
  int? selectedTableIndex;
  @override
  TableData? editingTable;
  @override
  final List<TableData> tables = [];
  @override
  double propertiesPanelHeight = 300;
  @override
  double minPropertiesPanelHeight = 150;
  @override
  double maxPropertiesPanelHeight = 600;

  @override
  late final FlyoutController flyoutController;

  @override
  void dispose() {
    flyoutController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    canvasSize = widget.setSize;
    flyoutController = FlyoutController();
  }

  @override
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
                            child: FlyoutTarget(
                              controller: flyoutController,
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
}
