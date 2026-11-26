import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:tdmm/diagram/diagram_data/attribute_data.dart';
import 'package:tdmm/diagram/diagram_data/data_type_capability.dart';

class AttributeTypeLimitsEditor extends StatefulWidget {
  final AttributeData attribute;
  final VoidCallback onChanged;

  const AttributeTypeLimitsEditor({
    super.key,
    required this.attribute,
    required this.onChanged,
  });

  @override
  State<AttributeTypeLimitsEditor> createState() =>
      _AttributeTypeLimitsEditorState();
}

class _AttributeTypeLimitsEditorState extends State<AttributeTypeLimitsEditor> {
  late final TextEditingController _lengthFirstController;
  late final TextEditingController _lengthSecondController;
  late final TextEditingController _rangeController;

  @override
  void initState() {
    super.initState();
    final attr = widget.attribute;
    _lengthFirstController = TextEditingController(
      text: attr.setLengthFirst == 0 ? '' : attr.setLengthFirst.toString(),
    );
    _lengthSecondController = TextEditingController(
      text: attr.setLengthSecond == 0 ? '' : attr.setLengthSecond.toString(),
    );
    _rangeController = TextEditingController(text: attr.setRangeInString);
  }

  @override
  void dispose() {
    _lengthFirstController.dispose();
    _lengthSecondController.dispose();
    _rangeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final attr = widget.attribute;
    final capabilities = attr.dataType.capabilities;
    final hasLengthFirst =
        capabilities.contains(DataTypeCapability.lengthFirst);
    final hasLengthSecond =
        capabilities.contains(DataTypeCapability.lengthSecond);

    if (hasLengthFirst || hasLengthSecond) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('('),
          if (hasLengthFirst)
            SizedBox(
              width: 65,
              child: TextBox(
                controller: _lengthFirstController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  attr.setLengthFirst = int.tryParse(value) ?? 0;
                  widget.onChanged();
                },
              ),
            ),
          if (hasLengthSecond) ...[
            const SizedBox(width: 6),
            const Text(','),
            const SizedBox(width: 6),
            SizedBox(
              width: 65,
              child: TextBox(
                controller: _lengthSecondController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  attr.setLengthSecond = int.tryParse(value) ?? 0;
                  widget.onChanged();
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
              controller: _rangeController,
              onChanged: (value) {
                attr.setRangeInString = value;
                widget.onChanged();
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