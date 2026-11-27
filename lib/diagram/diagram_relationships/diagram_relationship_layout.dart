import 'dart:math' as math;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:tdmm/diagram/diagram_data/attribute_data.dart';
import 'package:tdmm/diagram/diagram_data/table_data.dart';
import 'package:tdmm/diagram/diagram_relationships/diagram_relationship_data.dart';

enum TableAttachmentSide {
  left,
  right,
}

class RelationshipGeometry {
  final DiagramRelationshipData relationship;
  final TableAttachmentSide sourceSide;
  final TableAttachmentSide destinationSide;
  final List<Offset> points;

  const RelationshipGeometry({
    required this.relationship,
    required this.sourceSide,
    required this.destinationSide,
    required this.points,
  });
}

class DiagramTableLayout {
  static const double borderWidth = 2.0;
  static const double headerHeight = 32.0;
  static const double baseRowHeight = 24.0;
  static const double extraRowHeightPerRelation = 10.0;
  static const double bottomPadding = 4.0;
  static const double minTableWidth = 120.0;
  static const double overlapChannelOffset = 28.0;
  static const double overlapChannelStep = 10.0;

  static int countRelationshipsForAttribute(
    String attributeId,
    List<DiagramRelationshipData> relationships,
  ) {
    int count = 0;
    for (final rel in relationships) {
      if (rel.sourceAttributeId == attributeId ||
          rel.destinationAttributeId == attributeId) {
        count++;
      }
    }
    return count;
  }

  static double getRowHeight(
    AttributeData attribute,
    List<DiagramRelationshipData> relationships,
  ) {
    final count = countRelationshipsForAttribute(attribute.id, relationships);
    if (count <= 1) return baseRowHeight;
    return baseRowHeight + (count - 1) * extraRowHeightPerRelation;
  }

  static double getMinTableHeight(
    TableData table,
    List<DiagramRelationshipData> relationships,
  ) {
    double rowsHeight = 0;
    for (final attr in table.attributes) {
      rowsHeight += getRowHeight(attr, relationships);
    }
    final contentMin =
        (borderWidth * 2) + headerHeight + rowsHeight + bottomPadding;
    return math.max(70.0, contentMin);
  }

  static double getRowTop(
    TableData table,
    int attributeIndex,
    List<DiagramRelationshipData> relationships,
  ) {
    double y = table.position.dy + borderWidth + headerHeight;
    for (int i = 0; i < attributeIndex && i < table.attributes.length; i++) {
      y += getRowHeight(table.attributes[i], relationships);
    }
    return y;
  }

  static ({
    TableAttachmentSide sourceSide,
    TableAttachmentSide destinationSide,
  })
  resolveAttachmentSides(TableData sourceTable, TableData destinationTable) {
    final sLeft = sourceTable.position.dx;
    final sRight = sLeft + sourceTable.size.width;
    final dLeft = destinationTable.position.dx;
    final dRight = dLeft + destinationTable.size.width;

    if (sRight < dLeft) {
      return (
        sourceSide: TableAttachmentSide.right,
        destinationSide: TableAttachmentSide.left,
      );
    }
    if (dRight < sLeft) {
      return (
        sourceSide: TableAttachmentSide.left,
        destinationSide: TableAttachmentSide.right,
      );
    }
    return (
      sourceSide: TableAttachmentSide.right,
      destinationSide: TableAttachmentSide.right,
    );
  }

  static List<RelationshipGeometry> computeAllGeometries(
    List<TableData> tables,
    List<DiagramRelationshipData> relationships,
  ) {
    final tableById = <String, TableData>{
      for (final table in tables) table.id: table,
    };

    final resolved = <({
      DiagramRelationshipData rel,
      TableData srcTable,
      int srcIndex,
      TableData dstTable,
      int dstIndex,
      TableAttachmentSide srcSide,
      TableAttachmentSide dstSide,
    })>[];

    final slotGroups = <String, List<({String relId, double oppositeY})>>{};

    String slotKey(String tableId, String attrId, TableAttachmentSide side) =>
        '$tableId::$attrId::${side.name}';

    for (final rel in relationships) {
      final srcTable = tableById[rel.sourceTableId];
      final dstTable = tableById[rel.destinationTableId];
      if (srcTable == null || dstTable == null) continue;

      final srcIndex = srcTable.attributes.indexWhere(
        (a) => a.id == rel.sourceAttributeId,
      );
      final dstIndex = dstTable.attributes.indexWhere(
        (a) => a.id == rel.destinationAttributeId,
      );
      if (srcIndex == -1 || dstIndex == -1) continue;

      final sides = srcTable.id == dstTable.id
          ? (
              sourceSide: TableAttachmentSide.right,
              destinationSide: TableAttachmentSide.right,
            )
          : resolveAttachmentSides(srcTable, dstTable);
      resolved.add((
        rel: rel,
        srcTable: srcTable,
        srcIndex: srcIndex,
        dstTable: dstTable,
        dstIndex: dstIndex,
        srcSide: sides.sourceSide,
        dstSide: sides.destinationSide,
      ));

      final srcApproxY =
          getRowTop(srcTable, srcIndex, relationships) +
          getRowHeight(srcTable.attributes[srcIndex], relationships) / 2;
      final dstApproxY =
          getRowTop(dstTable, dstIndex, relationships) +
          getRowHeight(dstTable.attributes[dstIndex], relationships) / 2;

      slotGroups
          .putIfAbsent(
            slotKey(srcTable.id, rel.sourceAttributeId, sides.sourceSide),
            () => [],
          )
          .add((relId: rel.id, oppositeY: dstApproxY));

      slotGroups
          .putIfAbsent(
            slotKey(dstTable.id, rel.destinationAttributeId, sides.destinationSide),
            () => [],
          )
          .add((relId: rel.id, oppositeY: srcApproxY));
    }

    for (final group in slotGroups.values) {
      group.sort((a, b) {
        final cmp = a.oppositeY.compareTo(b.oppositeY);
        return cmp != 0 ? cmp : a.relId.compareTo(b.relId);
      });
    }

    double resolveAnchorY(
      TableData table,
      int attrIndex,
      TableAttachmentSide side,
      String relId,
    ) {
      final attr = table.attributes[attrIndex];
      final rowTop = getRowTop(table, attrIndex, relationships);
      final rowHeight = getRowHeight(attr, relationships);
      final group = slotGroups[slotKey(table.id, attr.id, side)]!;
      final slotIndex = group.indexWhere((entry) => entry.relId == relId);
      return rowTop + ((slotIndex + 1) * rowHeight) / (group.length + 1);
    }

    int overlapLane = 0;
    final geometries = <RelationshipGeometry>[];

    for (final item in resolved) {
      final srcX = item.srcSide == TableAttachmentSide.right
          ? item.srcTable.position.dx + item.srcTable.size.width
          : item.srcTable.position.dx;
      final dstX = item.dstSide == TableAttachmentSide.right
          ? item.dstTable.position.dx + item.dstTable.size.width
          : item.dstTable.position.dx;

      final srcY = resolveAnchorY(
        item.srcTable,
        item.srcIndex,
        item.srcSide,
        item.rel.id,
      );
      final dstY = resolveAnchorY(
        item.dstTable,
        item.dstIndex,
        item.dstSide,
        item.rel.id,
      );

      final start = Offset(srcX, srcY);
      final end = Offset(dstX, dstY);

      final double turnX;
      if (item.srcSide != item.dstSide) {
        turnX = (start.dx + end.dx) / 2;
      } else {
        final sRight = item.srcTable.position.dx + item.srcTable.size.width;
        final dRight = item.dstTable.position.dx + item.dstTable.size.width;
        turnX =
            math.max(sRight, dRight) +
            overlapChannelOffset +
            (overlapLane * overlapChannelStep);
        overlapLane++;
      }

      final points = <Offset>[
        start,
        Offset(turnX, start.dy),
        Offset(turnX, end.dy),
        end,
      ];

      geometries.add(
        RelationshipGeometry(
          relationship: item.rel,
          sourceSide: item.srcSide,
          destinationSide: item.dstSide,
          points: points,
        ),
      );
    }

    return geometries;
  }

  static RelationshipGeometry? hitTestRelationship(
    Offset point,
    List<RelationshipGeometry> geometries, {
    double tolerance = 7.0,
  }) {
    for (int i = geometries.length - 1; i >= 0; i--) {
      final geometry = geometries[i];
      final pts = geometry.points;
      for (int j = 0; j < pts.length - 1; j++) {
        if (_distanceToOrthoSegment(point, pts[j], pts[j + 1]) <= tolerance) {
          return geometry;
        }
      }
    }
    return null;
  }

  static double _distanceToOrthoSegment(Offset p, Offset a, Offset b) {
    final minX = math.min(a.dx, b.dx);
    final maxX = math.max(a.dx, b.dx);
    final minY = math.min(a.dy, b.dy);
    final maxY = math.max(a.dy, b.dy);

    final clampedX = p.dx.clamp(minX, maxX);
    final clampedY = p.dy.clamp(minY, maxY);
    final dx = p.dx - clampedX;
    final dy = p.dy - clampedY;
    return math.sqrt(dx * dx + dy * dy);
  }
}
