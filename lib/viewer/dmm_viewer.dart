import 'package:tdmm/viewer/viewer_background.dart';
import 'package:tdmm/viewer/viewer_background_layer.dart';
import 'package:tdmm/viewer/viewer_element.dart';
import 'package:tdmm/viewer/viewer_resize_handle.dart';
import 'package:fluent_ui/fluent_ui.dart';

class DMMViewer extends StatefulWidget {
  final Size viewerSize;
  final ViewerBackground background;
  final List<ViewerElement> elements;
  final ValueChanged<Offset> onViewerClick;
  final ValueChanged<Offset> onViewerResize;

  const DMMViewer({
    super.key,
    required this.viewerSize,
    required this.background,
    required this.elements,
    required this.onViewerClick,
    required this.onViewerResize,
  });

  @override
  State<DMMViewer> createState() => DiagramViewerState();
}

class DiagramViewerState extends State<DMMViewer> {
  final TransformationController transformationController =
      TransformationController();

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
        child: SizedBox(
          width: widget.viewerSize.width,
          height: widget.viewerSize.height,
          child: Stack(
            children: [
              Positioned.fill(
                child: Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerDown: (details) {
                    widget.onViewerClick(details.localPosition);
                  },
                  child: ViewerBackgroundLayer(viewerBackground: widget.background,),
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
                SystemMouseCursors.resizeDownRight
              ),
            ],
          ),
        ),
      );
  }
}
