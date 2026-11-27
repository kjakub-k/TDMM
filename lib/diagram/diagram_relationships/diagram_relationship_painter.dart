import 'package:fluent_ui/fluent_ui.dart';
import 'package:tdmm/diagram/diagram_data/table_data.dart';
import 'package:tdmm/diagram/diagram_relationships/diagram_relationship_data.dart';
import 'package:tdmm/diagram/diagram_relationships/diagram_relationship_layout.dart';

class DiagramRelationshipPainter extends CustomPainter {
  final List<TableData> tables;
  final List<DiagramRelationshipData> relationships;
  final String? selectedRelationshipId;
  final Color accentColor;

  DiagramRelationshipPainter({
    required this.tables,
    required this.relationships,
    this.selectedRelationshipId,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final geometries = DiagramTableLayout.computeAllGeometries(
      tables,
      relationships,
    );

    for (final geometry in geometries) {
      final rel = geometry.relationship;
      final isSelected = rel.id == selectedRelationshipId;
      final color = isSelected ? accentColor : Colors.black;
      final paint = Paint()
        ..color = color
        ..strokeWidth = isSelected ? 2.6 : 1.8
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.miter
        ..strokeCap = StrokeCap.square;

      final pts = geometry.points;
      if (pts.length < 2) continue;

      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (int i = 1; i < pts.length; i++) {
        path.lineTo(pts[i].dx, pts[i].dy);
      }
      canvas.drawPath(path, paint);

      if (!rel.isTransferable && pts.length >= 4) {
        final midPoint = Offset(pts[1].dx, (pts[1].dy + pts[2].dy) / 2);
        _drawTransferabilityDiamond(
          canvas: canvas,
          center: midPoint,
          strokePaint: paint,
        );
      }

      _drawSourceMarkers(
        canvas: canvas,
        anchor: pts.first,
        side: geometry.sourceSide,
        isOptional: rel.isSourceOptional,
        strokePaint: paint,
      );

      _drawDestinationMarkers(
        canvas: canvas,
        anchor: pts.last,
        side: geometry.destinationSide,
        cardinality: rel.cardinality,
        isOptional: rel.isDestinationOptional,
        strokePaint: paint,
      );
    }
  }

  void _drawSourceMarkers({
    required Canvas canvas,
    required Offset anchor,
    required TableAttachmentSide side,
    required bool isOptional,
    required Paint strokePaint,
  }) {
    final dir = side == TableAttachmentSide.right ? 1.0 : -1.0;
    _drawPerpendicularLine(canvas, anchor.dx + dir * 6.0, anchor.dy, strokePaint);
    _drawOptionalityMarker(
      canvas: canvas,
      lineX: anchor.dx + dir * 11.0,
      circleX: anchor.dx + dir * 13.5,
      y: anchor.dy,
      isOptional: isOptional,
      strokePaint: strokePaint,
    );
  }

  void _drawDestinationMarkers({
    required Canvas canvas,
    required Offset anchor,
    required TableAttachmentSide side,
    required RelationshipCardinality cardinality,
    required bool isOptional,
    required Paint strokePaint,
  }) {
    final dir = side == TableAttachmentSide.right ? 1.0 : -1.0;

    if (cardinality == RelationshipCardinality.oneToOne) {
      _drawPerpendicularLine(
        canvas,
        anchor.dx + dir * 6.0,
        anchor.dy,
        strokePaint,
      );
      _drawOptionalityMarker(
        canvas: canvas,
        lineX: anchor.dx + dir * 11.0,
        circleX: anchor.dx + dir * 13.5,
        y: anchor.dy,
        isOptional: isOptional,
        strokePaint: strokePaint,
      );
      return;
    }

    const double footSpread = 6.0;
    const double footLength = 10.0;
    final branchX = anchor.dx + dir * footLength;
    final branchPoint = Offset(branchX, anchor.dy);

    canvas.drawLine(
      branchPoint,
      Offset(anchor.dx, anchor.dy - footSpread),
      strokePaint,
    );
    canvas.drawLine(
      branchPoint,
      Offset(anchor.dx, anchor.dy + footSpread),
      strokePaint,
    );

    _drawOptionalityMarker(
      canvas: canvas,
      lineX: branchX,
      circleX: anchor.dx + dir * 14.5,
      y: anchor.dy,
      isOptional: isOptional,
      strokePaint: strokePaint,
    );
  }

  void _drawPerpendicularLine(
    Canvas canvas,
    double x,
    double y,
    Paint strokePaint,
  ) {
    const double tickHalfHeight = 6.0;
    canvas.drawLine(
      Offset(x, y - tickHalfHeight),
      Offset(x, y + tickHalfHeight),
      strokePaint,
    );
  }

  void _drawOptionalityMarker({
    required Canvas canvas,
    required double lineX,
    required double circleX,
    required double y,
    required bool isOptional,
    required Paint strokePaint,
  }) {
    if (!isOptional) {
      _drawPerpendicularLine(canvas, lineX, y, strokePaint);
      return;
    }

    const double radius = 3.8;
    final center = Offset(circleX, y);
    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, fillPaint);
    canvas.drawCircle(center, radius, strokePaint);
  }

  void _drawTransferabilityDiamond({
    required Canvas canvas,
    required Offset center,
    required Paint strokePaint,
  }) {
    const double halfWidth = 10.0;
    const double halfHeight = 5.0;

    final diamondPath = Path()
      ..moveTo(center.dx - halfWidth, center.dy)
      ..lineTo(center.dx, center.dy - halfHeight)
      ..lineTo(center.dx + halfWidth, center.dy)
      ..lineTo(center.dx, center.dy + halfHeight)
      ..close();

    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(diamondPath, fillPaint);
    canvas.drawPath(diamondPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant DiagramRelationshipPainter oldDelegate) {
    return true;
  }
}
