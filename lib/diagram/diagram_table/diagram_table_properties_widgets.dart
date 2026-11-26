import 'package:fluent_ui/fluent_ui.dart';
import 'package:tdmm/diagram/diagram_data/attribute_data.dart';
import 'package:tdmm/diagram/diagram_data/data_type_limitations.dart';
import 'package:tdmm/diagram/diagram_data/data_type_picker.dart';
import 'package:tdmm/diagram/diagram_data/key_type_data.dart';
import 'package:tdmm/diagram/diagram_data/table_data.dart';
import 'package:flutter/services.dart';

mixin DiagramTablePropertiesWidgets<T extends StatefulWidget> on State<T> {
  final Map<AttributeData, TextEditingController> _lengthFirstControllers = {};
  final Map<AttributeData, TextEditingController> _lengthSecondControllers = {};
  final Map<AttributeData, TextEditingController> _rangeControllers = {};
  TableData get table;
  void onTableChanged();
  void onClose();
  void addColumn();
  void moveColumn(int index, int direction);
  void deleteColumn(int index);

  @override
  void dispose() {
    for (final controller in _lengthFirstControllers.values) {
      controller.dispose();
    }

    for (final controller in _lengthSecondControllers.values) {
      controller.dispose();
    }

    for (final controller in _rangeControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  TextEditingController getController(
    Map<AttributeData, TextEditingController> controllers,
    AttributeData attribute,
    String initialValue,
  ) {
    return controllers.putIfAbsent(
      attribute,
      () => TextEditingController(text: initialValue),
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
              key: ObjectKey(table),
              controller: TextEditingController.fromValue(
                TextEditingValue(
                  text: table.name,
                  selection: TextSelection.collapsed(
                    offset: table.name.length,
                  ),
                ),
              ),
              placeholder: 'Název tabulky',
              style: theme.typography.bodyStrong,
              onChanged: (value) {
                table.name = value;
                onTableChanged();
              },
            ),
          ),

          IconButton(
            icon: const Icon(FluentIcons.chrome_close, size: 14),
            onPressed: onClose,
          ),

          const SizedBox(width: 6),
        ],
      ),
    );
  }

  Widget buildAttribute(AttributeData attribute, int index) {
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
                  onTableChanged();
                },
              ),
            ),

            const SizedBox(width: 8),

            SizedBox(
              width: 125,
              child: DataTypePicker(
                value: attribute.dataType,
                onChanged: (type) {
                  setState(() {
                    attribute.dataType = type;
                  });

                  onTableChanged();
                },
              ),
            ),

            const SizedBox(width: 8),

            if (attribute.dataType.capabilities.any(
              (capability) =>
                  capability == DataTypeCapability.lengthFirst ||
                  capability == DataTypeCapability.lengthSecond ||
                  capability == DataTypeCapability.rangeInText,
            ))
              buildTypeLimits(attribute),

            const SizedBox(width: 8),

            buildCheckbox(
              label: 'PRIMARY KEY',
              value: attribute.key == KeyTypeData.primary,
              onChanged: (value) {
                setState(() {
                  attribute.key =
                      value ? KeyTypeData.primary : null;
                });
                onTableChanged();
              },
            ),

            if (attribute.key == null) ...[
                buildCheckbox(
                label: 'NOT NULL',
                value: attribute.isNotNull,
                onChanged: (value) {
                  setState(() => attribute.isNotNull = value);
                  onTableChanged();
                },
              ),

              buildCheckbox(
                label: 'UNIQUE',
                value: attribute.isUnique,
                onChanged: (value) {
                  setState(() => attribute.isUnique = value);
                  onTableChanged();
                },
              ),
            ],

            if (attribute.dataType.capabilities.contains(DataTypeCapability.autoIncrement))
              buildCheckbox(
                label: 'AUTO INCREMENT',
                value: attribute.isAutoIncremental,
                onChanged: (value) {
                  setState(() {
                    attribute.isAutoIncremental = value;
                  });
                  onTableChanged();
                },
              ),

            if (attribute.dataType.capabilities.contains(DataTypeCapability.unsigned))
              buildCheckbox(
                label: 'UNSIGNED',
                value: attribute.isUnsigned,
                onChanged: (value) {
                  setState(() => attribute.isUnsigned = value);
                  onTableChanged();
                },
              ),

            if (attribute.dataType.capabilities.contains(DataTypeCapability.timezone))
              buildCheckbox(
                label: 'TIMEZONE',
                value: attribute.hasTimezone,
                onChanged: (value) {
                  setState(() => attribute.hasTimezone = value);
                  onTableChanged();
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
              onPressed: index == table.attributes.length - 1
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

  Widget buildTypeLimits(AttributeData attribute) {
    final capabilities = attribute.dataType.capabilities;

    if (capabilities.contains(DataTypeCapability.lengthFirst) ||
        capabilities.contains(DataTypeCapability.lengthSecond)) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (capabilities.contains(DataTypeCapability.lengthFirst))
            const Text('('),
            SizedBox(
              width: 65,
              child: TextBox(
                controller: getController(
                  _lengthFirstControllers,
                  attribute,
                  attribute.setLengthFirst == 0
                      ? ''
                      : attribute.setLengthFirst.toString(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {
                  setState(() {
                    attribute.setLengthFirst =
                        int.tryParse(value) ?? 0;
                  });
                  onTableChanged();
                },
              ),
            ),

          if (capabilities.contains(DataTypeCapability.lengthSecond)) ...[
            const SizedBox(width: 6),
            const Text(','),
            const SizedBox(width: 6),
            SizedBox(
              width: 65,
              child: TextBox(
                controller: getController(
                  _lengthSecondControllers,
                  attribute,
                  attribute.setLengthSecond == 0
                      ? ''
                      : attribute.setLengthSecond.toString(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {
                  setState(() {
                    attribute.setLengthSecond =
                        int.tryParse(value) ?? 0;
                  });
                  onTableChanged();
                },
              ),
            ),
          ],
          const Text(')'),
        ],
      );
    }

    if (capabilities.contains(DataTypeCapability.rangeInText)) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('('),
          SizedBox(
            width: 130,
            child: TextBox(
              controller: getController(
                _rangeControllers,
                attribute,
                attribute.setRangeInString,
              ),
              onChanged: (value) {
                setState(() {
                  attribute.setRangeInString = value;
                });
                onTableChanged();
              },
            ),
          ),
          const Text(')'),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}