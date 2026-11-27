import 'package:fluent_ui/fluent_ui.dart';
import 'package:tdmm/diagram/diagram_controller.dart';
import 'package:tdmm/diagram/diagram_relationships/diagram_relationship_data.dart';

class RelationshipFloatingPanel extends StatelessWidget {
  final DiagramController controller;
  final String relationshipId;
  final VoidCallback onDeleted;

  const RelationshipFloatingPanel({
    super.key,
    required this.controller,
    required this.relationshipId,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final relationship = controller.findRelationshipById(relationshipId);
    if (relationship == null) {
      return const SizedBox.shrink();
    }

    final sourceName =
        controller.findTableById(relationship.sourceTableId)?.name ?? 'zdroj';
    final destinationName =
        controller.findTableById(relationship.destinationTableId)?.name ??
        'cíl';

    return FlyoutContent(
      constraints: const BoxConstraints(minWidth: 460, maxWidth: 520),
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const SizedBox(width: 32),
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 110,
                    child: ComboBox<RelationshipCardinality>(
                      value: relationship.cardinality,
                      isExpanded: true,
                      items: const [
                        ComboBoxItem(
                          value: RelationshipCardinality.oneToOne,
                          child: Text('1:1'),
                        ),
                        ComboBoxItem(
                          value: RelationshipCardinality.oneToMany,
                          child: Text('1:N'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          controller.setRelationshipCardinality(
                            relationshipId,
                            value,
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  icon: const Icon(FluentIcons.delete, size: 14),
                  onPressed: () {
                    onDeleted();
                    controller.deleteRelationship(relationshipId);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _PanelCheckbox(
                    label: 'Volitelný ($sourceName)',
                    checked: relationship.isSourceOptional,
                    onChanged: (value) => controller.setRelationshipOptionality(
                      relationshipId,
                      isSourceOptional: value,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: _PanelCheckbox(
                    label: 'Přenositelný',
                    checked: relationship.isTransferable,
                    onChanged: (value) =>
                        controller.setRelationshipTransferable(
                          relationshipId,
                          value,
                        ),
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _PanelCheckbox(
                    label: 'Volitelný ($destinationName)',
                    checked: relationship.isDestinationOptional,
                    onChanged: (value) => controller.setRelationshipOptionality(
                      relationshipId,
                      isDestinationOptional: value,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PanelCheckbox extends StatelessWidget {
  final String label;
  final bool checked;
  final ValueChanged<bool> onChanged;

  const _PanelCheckbox({
    required this.label,
    required this.checked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!checked),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            checked: checked,
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FluentTheme.of(context).typography.caption,
            ),
          ),
        ],
      ),
    );
  }
}
