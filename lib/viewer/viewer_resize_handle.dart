import 'package:fluent_ui/fluent_ui.dart';

enum ResizeHandleLocation {
  bottom,
  right,
  bottomRight,
}

class PositionInfo {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double? width;
  final double? height;

  const PositionInfo({
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.width,
    this.height,
  });
}

Widget buildResizeHandle(
  PositionInfo posInfo,
  ValueChanged<Offset> onViewerResize,
  ResizeHandleLocation resizeHandleLocation,
  MouseCursor cursorIcon,
) {
  return Positioned(
    top: posInfo.top,
    left: posInfo.left,
    right: posInfo.right,
    bottom: posInfo.bottom,
    width: posInfo.width,
    height: posInfo.height,
    child: MouseRegion(
      cursor: cursorIcon,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanUpdate: (details) {
          switch (resizeHandleLocation) {
            case ResizeHandleLocation.bottom:
              onViewerResize(Offset(0, details.delta.dy));
              break;
            case ResizeHandleLocation.right:
              onViewerResize(Offset(details.delta.dx, 0));
              break;
            case ResizeHandleLocation.bottomRight:
              onViewerResize(details.delta);
              break;
          }
        },
        child: const SizedBox.expand(),
      ),
    ),
  );
}