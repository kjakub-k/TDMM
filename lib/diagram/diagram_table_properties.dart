import 'package:tdmm/diagram/diagram_table.dart';
import 'package:fluent_ui/fluent_ui.dart';

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

class DiagramTablePropertiesState extends State<DiagramTableProperties> {
  void addColumn() {
    setState(() {
      widget.table.attributes.add(
        Attribute(
          name: 'attribute_${widget.table.attributes.length + 1}',
        ),
      );
    });

    widget.onTableChanged();
  }

  void deleteColumn(int index) {
    setState(() {
      widget.table.attributes.removeAt(index);
    });

    widget.onTableChanged();
  }

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

  String dataTypeLabel(DataType type) {
    switch (type) {
      case DataType.integer:
        return 'Integer';
      case DataType.varchar:
        return 'Varchar';
      case DataType.text:
        return 'Text';
      case DataType.boolean:
        return 'Boolean';
      case DataType.decimal:
        return 'Decimal';
      case DataType.dateTime:
        return 'Date / Time';
    }
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

  Widget buildAddAttributeButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Button(
        onPressed: addColumn,
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

  Widget buildHeader() {
    final theme = FluentTheme.of(context);

    return SizedBox(
      height: 42,
      child: Row(
        children: [
          const SizedBox(width: 8),

          Expanded(
            child: TextBox(
              key: ObjectKey(widget.table),
              controller: TextEditingController.fromValue(
                TextEditingValue(
                  text: widget.table.name,
                  selection: TextSelection.collapsed(
                    offset: widget.table.name.length,
                  ),
                ),
              ),
              placeholder: 'Název tabulky',
              style: theme.typography.bodyStrong,
              onChanged: (value) {
                widget.table.name = value;
                widget.onTableChanged();
              },
            ),
          ),

          IconButton(
            icon: const Icon(FluentIcons.chrome_close, size: 14),
            onPressed: widget.onClose,
          ),

          const SizedBox(width: 6),
        ],
      ),
    );
  }

  Widget buildAttribute(Attribute attribute, int index) {
    final theme = FluentTheme.of(context);

    return Container(
      key: ObjectKey(attribute),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: theme.resources.cardBackgroundFillColorDefault,
        border: Border.all(
          color: theme.resources.cardStrokeColorDefault,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(
              width: 150,
              child: TextBox(
                controller: TextEditingController.fromValue(
                  TextEditingValue(
                    text: attribute.name,
                    selection: TextSelection.collapsed(
                      offset: attribute.name.length,
                    ),
                  ),
                ),
                placeholder: 'Jméno atributu',
                onChanged: (value) {
                  setState(() {
                    attribute.name = value;
                  });
                  widget.onTableChanged();
                },
              ),
            ),

            const SizedBox(width: 8),

            SizedBox(
              width: 125,
              child: ComboBox<DataType>(
                value: attribute.dataType,
                isExpanded: true,
                items: DataType.values.map((type) {
                  return ComboBoxItem<DataType>(
                    value: type,
                    child: Text(
                      dataTypeLabel(type),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (type) {
                  if (type == null) return;

                  setState(() {
                    attribute.dataType = type;
                  });

                  widget.onTableChanged();
                },
              ),
            ),

            const SizedBox(width: 8),

            buildCheckbox(
              label: 'NOT NULL',
              value: attribute.isNotNull,
              onChanged: (value) {
                setState(() => attribute.isNotNull = value);
                widget.onTableChanged();
              },
            ),

            buildCheckbox(
              label: 'UNIQUE',
              value: attribute.isUnique,
              onChanged: (value) {
                setState(() => attribute.isUnique = value);
                widget.onTableChanged();
              },
            ),

            buildCheckbox(
              label: 'PRIMARY KEY',
              value: attribute.key == KeyType.primary,
              onChanged: (value) {
                setState(() {
                  attribute.key =
                      value ? KeyType.primary : null;
                });
                widget.onTableChanged();
              },
            ),

            buildCheckbox(
              label: 'AUTO INCREMENT',
              value: attribute.isAutoIncremental,
              onChanged: (value) {
                setState(() {
                  attribute.isAutoIncremental = value;
                });
                widget.onTableChanged();
              },
            ),

            buildCheckbox(
              label: 'UNSIGNED',
              value: attribute.isUnsigned,
              onChanged: (value) {
                setState(() => attribute.isUnsigned = value);
                widget.onTableChanged();
              },
            ),

            const SizedBox(width: 8),

            IconButton(
              icon: const Icon(FluentIcons.chevron_up, size: 14),
              onPressed: index == 0
                  ? null
                  : () => moveColumn(index, -1),
            ),

            IconButton(
              icon: const Icon(FluentIcons.chevron_down, size: 14),
              onPressed: index == widget.table.attributes.length - 1
                  ? null
                  : () => moveColumn(index, 1),
            ),

            IconButton(
              icon: const Icon(FluentIcons.delete, size: 14),
              onPressed: () => deleteColumn(index),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCheckbox({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            checked: value,
            onChanged: (newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: FluentTheme.of(context).typography.caption,
            softWrap: false,
          ),
        ],
      ),
    );
  }
}
