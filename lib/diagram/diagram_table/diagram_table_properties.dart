import 'package:tdmm/diagram/diagram_data/attribute_data.dart';
import 'package:tdmm/diagram/diagram_data/table_data.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:tdmm/diagram/diagram_table/diagram_table_properties_widgets.dart';

class DiagramTableProperties extends StatefulWidget {
  final TableData table;
  final VoidCallback onTableChanged;
  final VoidCallback onClose;

  const DiagramTableProperties({
    super.key,
    required this.table,
    required this.onTableChanged,
    required this.onClose,
  });

  @override
  State<DiagramTableProperties> createState() =>
      DiagramTablePropertiesState();
}

class DiagramTablePropertiesState extends State<DiagramTableProperties> with DiagramTablePropertiesWidgets {
  @override
  TableData get table => widget.table;
  
  @override
  void onTableChanged() => widget.onTableChanged();

  @override
  void onClose() => widget.onClose();

  @override
  void addColumn() {
    setState(() {
      widget.table.attributes.add(
        AttributeData(
          name: 'attribute_${widget.table.attributes.length + 1}',
        ),
      );
    });

    widget.onTableChanged();
  }

  @override
  void deleteColumn(int index) {
    setState(() {
      widget.table.attributes.removeAt(index);
    });

    widget.onTableChanged();
  }

  @override
  void moveColumn(int index, int direction) {
    final newIndex = index + direction;

    if (newIndex < 0 || newIndex >= widget.table.attributes.length) {
      return;
    }

    setState(() {
      final attribute = widget.table.attributes.removeAt(index);
      widget.table.attributes.insert(newIndex, attribute);
    });

    widget.onTableChanged();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.micaBackgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.resources.dividerStrokeColorDefault,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          buildHeader(),

          Container(
            height: 1,
            color: theme.resources.dividerStrokeColorDefault,
          ),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: widget.table.attributes.length + 1,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: 6),
              itemBuilder: (context, index) {
                if (index == widget.table.attributes.length) {
                  return buildAddAttributeButton();
                }

                final attribute = widget.table.attributes[index];

                return buildAttribute(attribute, index);
              },
            ),
          ),
        ],
      ),
    );
  }
}