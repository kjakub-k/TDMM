import 'package:fluent_ui/fluent_ui.dart';
import 'package:tdmm/diagram/diagram_data/key_type_data.dart';
import 'package:tdmm/diagram/diagram_data/table_data.dart';
import 'package:tdmm/diagram/diagram_mode.dart';
import 'package:tdmm/diagram/diagram_relationships/diagram_relationship_data.dart';
import 'package:tdmm/diagram/diagram_relationships/diagram_relationship_layout.dart';
import 'package:tdmm/viewer/viewer_element.dart';

const Object relationshipTapGroupId = 'relationship-mode-tap-group';

class DiagramTable extends ViewerElement {
  final TableData table;
  final List<DiagramRelationshipData> relationships;
  final DiagramMode mode;
  final String? pendingSourceTableId;
  final String? pendingSourceAttributeId;
  final bool selected;
  final VoidCallback onSelect;
  final ValueChanged<Offset> onMove;
  final ValueChanged<Offset> onResize;
  final VoidCallback onDoubleTap;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final void Function(Offset position) onShowContextMenu;
  final ValueChanged<String> onAttributeTap;
  final VoidCallback onTableTap;

  const DiagramTable({
    super.key,
    required this.table,
    required this.relationships,
    required this.mode,
    this.pendingSourceTableId,
    this.pendingSourceAttributeId,
    required this.selected,
    required this.onSelect,
    required this.onMove,
    required this.onResize,
    required this.onDoubleTap,
    required this.onDelete,
    required this.onDuplicate,
    required this.onShowContextMenu,
    required this.onAttributeTap,
    required this.onTableTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isRelationshipMode = mode.isRelationshipMode;
    final isPickingAttribute =
        isRelationshipMode &&
        (pendingSourceAttributeId == null ||
            mode == DiagramMode.placeManyToMany);
    final isPickingTargetTable =
        isRelationshipMode &&
        pendingSourceAttributeId != null &&
        mode != DiagramMode.placeManyToMany;

    final borderColor = selected || isPickingTargetTable
        ? theme.accentColor
        : Colors.black;

    return Positioned(
      left: table.position.dx,
      top: table.position.dy,
      child: TapRegion(
        groupId: relationshipTapGroupId,
        child: SizedBox(
          width: table.size.width,
          height: table.size.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: isRelationshipMode ? onTableTap : onSelect,
                  onPanStart: isRelationshipMode ? null : (_) => onSelect(),
                  onPanUpdate: isRelationshipMode
                      ? null
                      : (details) => onMove(details.delta),
                  onDoubleTap: isRelationshipMode ? null : onDoubleTap,
                  onSecondaryTapDown: isRelationshipMode
                      ? null
                      : (details) {
                          onShowContextMenu(details.globalPosition);
                        },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: borderColor,
                        width: DiagramTableLayout.borderWidth,
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: theme.accentColor.withValues(
                                  alpha: 0.22,
                                ),
                                blurRadius: 8,
                                spreadRadius: 1.5,
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Table header
                        Container(
                          height: DiagramTableLayout.headerHeight,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: borderColor,
                                width: 0.7,
                              ),
                            ),
                          ),
                          child: Text(
                            table.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.typography.bodyStrong,
                          ),
                        ),

                        // Attributes
                        Expanded(
                          child: ClipRect(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (final attribute in table.attributes)
                                  _buildAttributeRow(
                                    context: context,
                                    theme: theme,
                                    attribute: attribute,
                                    isPickingAttribute: isPickingAttribute,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Resize handle
              if (selected && !isRelationshipMode)
                Positioned(
                  right: -12,
                  bottom: -12,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: (details) {
                      onResize(details.delta);
                    },
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: Center(
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: theme.micaBackgroundColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.accentColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttributeRow({
    required BuildContext context,
    required FluentThemeData theme,
    required dynamic attribute,
    required bool isPickingAttribute,
  }) {
    final rowHeight = DiagramTableLayout.getRowHeight(attribute, relationships);
    final isPendingSource = attribute.id == pendingSourceAttributeId;
    final isPrimary = attribute.key == KeyTypeData.primary;
    final isForeign = attribute.key == KeyTypeData.foreign;
    final canPickThisRow =
        isPickingAttribute && isPrimary && table.id != pendingSourceTableId;

    final keyPrefix = isPrimary
        ? 'PK '
        : isForeign
        ? 'FK '
        : '';

    final rowContent = Container(
      height: rowHeight,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: isPendingSource
          ? BoxDecoration(
              color: theme.accentColor.withValues(alpha: 0.16),
            )
          : canPickThisRow
          ? BoxDecoration(
              color: theme.accentColor.withValues(alpha: 0.06),
            )
          : null,
      child: Text(
        '$keyPrefix${attribute.name} ${attribute.getDataTypeName()}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.typography.caption?.copyWith(
          fontWeight: isPendingSource || isPrimary ? FontWeight.w600 : null,
          color: isPendingSource ? theme.accentColor : null,
        ),
      ),
    );

    if (!isPickingAttribute) {
      return rowContent;
    }

    return MouseRegion(
      cursor: canPickThisRow
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onAttributeTap(attribute.id),
        child: rowContent,
      ),
    );
  }
}
