import 'package:fluent_ui/fluent_ui.dart';
import 'package:tdmm/diagram/diagram_data/attribute_data.dart';
import 'package:tdmm/diagram/diagram_data/data_type_capability.dart';
import 'package:tdmm/diagram/diagram_data/data_type_picker.dart';
import 'package:tdmm/diagram/diagram_data/key_type_data.dart';
import 'package:tdmm/diagram/diagram_table/diagram_table_properties/attribute_type_limits_editor.dart';

class AttributeEditorRow extends StatefulWidget {
  final AttributeData attribute;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onChanged;
  final ValueChanged<KeyTypeData?> onKeyChanged;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onDelete;

  const AttributeEditorRow({
    super.key,
    required this.attribute,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onChanged,
    required this.onKeyChanged,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onDelete,
  });

  @override
  State<AttributeEditorRow> createState() => _AttributeEditorRowState();
}

class _AttributeEditorRowState extends State<AttributeEditorRow> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.attribute.name);
  }

  @override
  void didUpdateWidget(covariant AttributeEditorRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_nameController.text != widget.attribute.name) {
      _nameController.text = widget.attribute.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _updateAttribute(VoidCallback mutation) {
    setState(mutation);
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final attr = widget.attribute;
    final capabilities = attr.dataType.capabilities;

    final hasTypeLimits = capabilities.any(
      (c) =>
          c == DataTypeCapability.lengthFirst ||
          c == DataTypeCapability.lengthSecond ||
          c == DataTypeCapability.rangeInText,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: theme.resources.cardBackgroundFillColorDefault,
        border: Border.all(color: theme.resources.cardStrokeColorDefault),
        borderRadius: BorderRadius.circular(4),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(
              width: 150,
              child: TextBox(
                controller: _nameController,
                placeholder: 'Jméno atributu',
                onChanged: (value) => _updateAttribute(() => attr.name = value),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 125,
              child: DataTypePicker(
                value: attr.dataType,
                onChanged: (type) => _updateAttribute(() => attr.dataType = type),
              ),
            ),
            const SizedBox(width: 8),

            if (hasTypeLimits) ...[
              AttributeTypeLimitsEditor(
                attribute: attr,
                onChanged: widget.onChanged,
              ),
              const SizedBox(width: 8),
            ],

            if (attr.key == KeyTypeData.foreign)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  'FOREIGN KEY',
                  style: theme.typography.caption,
                  softWrap: false,
                ),
              )
            else
              _ConstraintCheckbox(
                label: 'PRIMARY KEY',
                value: attr.key == KeyTypeData.primary,
                onChanged: (v) => widget.onKeyChanged(
                  v ? KeyTypeData.primary : null,
                ),
              ),
            if (attr.key == null) ...[
              _ConstraintCheckbox(
                label: 'NOT NULL',
                value: attr.isNotNull,
                onChanged: (v) => _updateAttribute(() => attr.isNotNull = v),
              ),
              _ConstraintCheckbox(
                label: 'UNIQUE',
                value: attr.isUnique,
                onChanged: (v) => _updateAttribute(() => attr.isUnique = v),
              ),
            ],
            if (capabilities.contains(DataTypeCapability.autoIncrement))
              _ConstraintCheckbox(
                label: 'AUTO INCREMENT',
                value: attr.isAutoIncremental,
                onChanged: (v) =>
                    _updateAttribute(() => attr.isAutoIncremental = v),
              ),
            if (capabilities.contains(DataTypeCapability.unsigned))
              _ConstraintCheckbox(
                label: 'UNSIGNED',
                value: attr.isUnsigned,
                onChanged: (v) => _updateAttribute(() => attr.isUnsigned = v),
              ),
            if (capabilities.contains(DataTypeCapability.timezone))
              _ConstraintCheckbox(
                label: 'TIMEZONE',
                value: attr.hasTimezone,
                onChanged: (v) => _updateAttribute(() => attr.hasTimezone = v),
              ),

            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(FluentIcons.chevron_up, size: 14),
              onPressed: widget.canMoveUp ? widget.onMoveUp : null,
            ),
            IconButton(
              icon: const Icon(FluentIcons.chevron_down, size: 14),
              onPressed: widget.canMoveDown ? widget.onMoveDown : null,
            ),
            IconButton(
              icon: const Icon(FluentIcons.delete, size: 14),
              onPressed: widget.onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConstraintCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ConstraintCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            checked: value,
            onChanged: (newValue) {
              if (newValue != null) onChanged(newValue);
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