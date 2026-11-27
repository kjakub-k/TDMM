import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:tdmm/viewer/viewer_background.dart';
import 'package:tdmm/viewer/viewer_background_layer.dart';
import 'package:tdmm/viewer/viewer_element.dart';
import 'package:tdmm/viewer/viewer_resize_handle.dart';
import 'package:fluent_ui/fluent_ui.dart';

class DMMViewer extends StatefulWidget {
  final Size viewerSize;
  final ViewerBackground background;
  final List<ViewerElement> elements;
  final Widget? relationshipLayer;
  final ValueChanged<Offset> onViewerClick;
  final void Function(Offset localPosition, Offset globalPosition)? onViewerTap;
  final ValueChanged<Offset> onViewerResize;

  const DMMViewer({
    super.key,
    required this.viewerSize,
    required this.background,
    required this.elements,
    this.relationshipLayer,
    required this.onViewerClick,
    this.onViewerTap,
    required this.onViewerResize,
  });

  @override
  State<DMMViewer> createState() => DiagramViewerState();
}

class DiagramViewerState extends State<DMMViewer> {
  final TransformationController transformationController =
      TransformationController();
  final GlobalKey _canvasKey = GlobalKey();
  final GlobalKey _repaintKey = GlobalKey();
  Offset? _pointerDownLocal;

  Future<ui.Image?> captureImage({double pixelRatio = 1.0}) async {
    final boundary =
        _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    return boundary.toImage(pixelRatio: pixelRatio);
  }

  Offset? canvasToGlobal(Offset canvasPoint) {
    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null;
    return box.localToGlobal(canvasPoint);
  }

  @override
  void dispose() {
    transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: transformationController,
      constrained: false,
      minScale: 0.5,
      maxScale: 5,
      boundaryMargin: const EdgeInsets.all(1000),
      child: RepaintBoundary(
        key: _repaintKey,
        child: SizedBox(
        key: _canvasKey,
        width: widget.viewerSize.width,
        height: widget.viewerSize.height,
        child: Stack(
          children: [
            Positioned.fill(
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (details) {
                  _pointerDownLocal = details.localPosition;
                  widget.onViewerClick(details.localPosition);
                },
                onPointerUp: (details) {
                  final downLocal = _pointerDownLocal;
                  _pointerDownLocal = null;
                  if (downLocal != null &&
                      (details.localPosition - downLocal).distance < 6.0) {
                    widget.onViewerTap?.call(
                      details.localPosition,
                      details.position,
                    );
                  }
                },
                onPointerCancel: (_) {
                  _pointerDownLocal = null;
                },
                child: ViewerBackgroundLayer(
                  viewerBackground: widget.background,
                ),
              ),
            ),

            if (widget.relationshipLayer != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: widget.relationshipLayer,
                ),
              ),

            for (int i = 0; i < widget.elements.length; i++)
              widget.elements[i],

            buildResizeHandle(
              PositionInfo(
                top: 0,
                right: -5,
                width: 10,
                height: widget.viewerSize.height,
              ),
              widget.onViewerResize,
              ResizeHandleLocation.right,
              SystemMouseCursors.resizeRight,
            ),

            buildResizeHandle(
              PositionInfo(
                left: 0,
                bottom: -5,
                width: widget.viewerSize.width,
                height: 10,
              ),
              widget.onViewerResize,
              ResizeHandleLocation.bottom,
              SystemMouseCursors.resizeDown,
            ),

            buildResizeHandle(
              PositionInfo(
                right: -6,
                bottom: -6,
                width: 14,
                height: 14,
              ),
              widget.onViewerResize,
              ResizeHandleLocation.bottomRight,
              SystemMouseCursors.resizeDownRight,
            ),
          ],
        ),
        ),
      ),
    );
  }
}
