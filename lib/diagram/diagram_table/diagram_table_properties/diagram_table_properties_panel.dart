import 'package:tdmm/diagram/diagram_controller.dart';
import 'package:tdmm/diagram/diagram_data/table_data.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:tdmm/diagram/diagram_table/diagram_table_properties/attribute_editor_row.dart';

class DiagramTablePropertiesPanel extends StatefulWidget {
  final TableData table;
  final DiagramController controller;
  final ValueChanged<double> onResizeDelta;

  const DiagramTablePropertiesPanel({
    super.key,
    required this.table,
    required this.controller,
    required this.onResizeDelta,
  });

  @override
  State<DiagramTablePropertiesPanel> createState() => DiagramTablePropertiesPanelState();
}

class DiagramTablePropertiesPanelState extends State<DiagramTablePropertiesPanel> {
  late final TextEditingController _tableNameController;

  @override
  void initState() {
    super.initState();
    _tableNameController = TextEditingController(text: widget.table.name);
  }

  @override
  void didUpdateWidget(covariant DiagramTablePropertiesPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.table.id != widget.table.id) {
      _tableNameController.text = widget.table.name;
    }
  }

  @override
  void dispose() {
    _tableNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final attributes = widget.table.attributes;

    return Container(
      decoration: BoxDecoration(
        color: theme.micaBackgroundColor,
        border: const Border(top: BorderSide(color: Colors.black)),
      ),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onVerticalDragUpdate: (d) => widget.onResizeDelta(d.delta.dy),
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeUpDown,
              child: Container(
                height: 8,
                alignment: Alignment.center,
                child: Container(
                  width: 40,
                  height: 3,
                  decoration: BoxDecoration(
                    color: theme.resources.textFillColorSecondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(
            height: 42,
            child: Row(
              children: [
                const SizedBox(width: 8),
                Expanded(
                  child: TextBox(
                    controller: _tableNameController,
                    placeholder: 'Název tabulky',
                    style: theme.typography.bodyStrong,
                    onChanged: (value) {
                      widget.controller.renameTable(widget.table.id, value);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(FluentIcons.chrome_close, size: 14),
                  onPressed: widget.controller.closeTableProperties,
                ),
                const SizedBox(width: 6),
              ],
            ),
          ),

          Container(
            height: 1,
            color: theme.resources.dividerStrokeColorDefault,
          ),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: attributes.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                if (index == attributes.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Button(
                      onPressed: () =>
                          widget.controller.addAttribute(widget.table.id),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(FluentIcons.add, size: 14),
                          SizedBox(width: 6),
                          Text('Přidat atribut'),
                        ],
                      ),
                    ),
                  );
                }

                final attribute = attributes[index];
                return AttributeEditorRow(
                  key: ValueKey(attribute.id),
                  attribute: attribute,
                  canMoveUp: index > 0,
                  canMoveDown: index < attributes.length - 1,
                  onChanged: widget.controller.notifyTableEdited,
                  onMoveUp: () => widget.controller
                      .moveAttribute(widget.table.id, index, -1),
                  onMoveDown: () => widget.controller
                      .moveAttribute(widget.table.id, index, 1),
                  onDelete: () =>
                      widget.controller.deleteAttribute(widget.table.id, index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}