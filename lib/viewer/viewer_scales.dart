import 'package:flutter/material.dart';
import 'package:tdmm/helper.dart';

Widget buildRightScale(
  PositionInfo posInfo,
  ValueChanged<Offset> onViewerResize,
) {
  return Positioned(
    top: posInfo.top,
    right: posInfo.right,
    width: posInfo.width,
    height: posInfo.height,
    child: MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanUpdate: (details) {
          onViewerResize(Offset(details.delta.dx, 0));
        },
        child: const SizedBox.expand(),
      ),
    ),
  );
}

Widget buildBottomScale(
  PositionInfo posInfo,
  ValueChanged<Offset> onViewerResize,
) {
  return Positioned(
    left: posInfo.left,
    bottom: posInfo.bottom,
    width: posInfo.width,
    height: posInfo.height,
    child: MouseRegion(
      cursor: SystemMouseCursors.resizeUpDown,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanUpdate: (details) {
          onViewerResize(Offset(0, details.delta.dy));
        },
        child: const SizedBox.expand(),
      ),
    ),
  );
}

Widget buildBottomRightScale(
  PositionInfo posInfo,
  ValueChanged<Offset> onViewerResize,
) {
  return Positioned(
    right: posInfo.right,
    bottom: posInfo.bottom,
    width: posInfo.width,
    height: posInfo.height,
    child: MouseRegion(
      cursor: SystemMouseCursors.resizeDownRight,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanUpdate: (details) {
          onViewerResize(details.delta);
        },
        child: const SizedBox.expand(),
      ),
    ),
  );
}