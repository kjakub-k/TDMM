import 'package:tdmm/diagram/diagram_data/attribute_data.dart';
import 'package:tdmm/diagram/diagram_data/data_type_limitations.dart';
import 'package:tdmm/diagram/diagram_data/table_data.dart';
import 'package:tdmm/viewer/viewer_element.dart';
import 'package:fluent_ui/fluent_ui.dart';

class DiagramTable extends ViewerElement {
  final TableData table;
  final bool selected;
  final VoidCallback onSelect;
  final ValueChanged<Offset> onMove;
  final ValueChanged<Offset> onResize;
  final VoidCallback onDoubleTap;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final void Function(Offset position) onShowContextMenu;

  const DiagramTable({
    super.key,
    required this.table,
    required this.selected,
    required this.onSelect,
    required this.onMove,
    required this.onResize,
    required this.onDoubleTap,
    required this.onDelete,
    required this.onDuplicate,
    required this.onShowContextMenu,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    final borderColor = selected
        ? theme.accentColor
        : Colors.black;

    return Positioned(
      left: table.position.dx,
      top: table.position.dy,
      child: SizedBox(
        width: table.size.width,
        height: table.size.height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onSelect,
                onPanStart: (_) => onSelect(),
                onPanUpdate: (details) => onMove(details.delta),
                onDoubleTap: onDoubleTap,
                onSecondaryTapDown: (details) {
                  onShowContextMenu(details.globalPosition);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: borderColor,
                      width: selected ? 3 : 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: theme.accentColor.withValues(
                                alpha: 0.12,
                              ),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Table header
                      Container(
                        height: 32,
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
                          style: theme.typography.bodyStrong,
                        ),
                      ),

                      // Attributes
                      Expanded(
                        child: ClipRect(
                          child: OverflowBox(
                            alignment: Alignment.topLeft,
                            minHeight: 0,
                            maxHeight: double.infinity,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                for (final attribute
                                    in table.attributes)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    child: Text(
                                      '${attribute.name} '
                                      '${getAttributeTypeName(attribute)}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.typography.caption,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Resize handle
            if (selected)
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
    );
  }

  String getAttributeTypeName(AttributeData attribute) {
    final capabilities = attribute.dataType.capabilities;

    if (capabilities.contains(DataTypeCapability.lengthFirst)) {
      if (capabilities.contains(DataTypeCapability.lengthSecond)) {
        return '${attribute.dataType.name}(${attribute.setLengthFirst}, ${attribute.setLengthSecond})';
      }

      return '${attribute.dataType.name}(${attribute.setLengthFirst})';
    }

    if (capabilities.contains(DataTypeCapability.rangeInText)) {
      return '${attribute.dataType.name}(${attribute.setRangeInString})';
    }

    return attribute.dataType.name;
  }
}