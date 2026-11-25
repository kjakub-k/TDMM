
import 'package:fluent_ui/fluent_ui.dart';
import 'package:tdmm/diagram/diagram_data/data_type_data.dart';

class DataTypePicker extends StatefulWidget {
  final DataTypeData value;
  final ValueChanged<DataTypeData> onChanged;

  const DataTypePicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<DataTypePicker> createState() => _DataTypePickerState();
}

class _DataTypePickerState extends State<DataTypePicker> {
  late final FlyoutController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FlyoutController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openFlyout() {
    _controller.showFlyout<void>(
      builder: (context) {
        return FlyoutContent(
          child: SizedBox(
            width: 220,
            height: 350,
            child: ListView(
              padding: const EdgeInsets.all(4),
              children: [
                for (final entry
                    in DataTypeData.groupedValues.entries) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 12, 8, 6),
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  for (final type in entry.value)
                    ListTile(
                      title: Text(type.name),
                      onPressed: () {
                        widget.onChanged(type);
                        _controller.close();
                      },
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlyoutTarget(
      controller: _controller,
      child: Button(
        onPressed: _openFlyout,
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.value.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(FluentIcons.chevron_down),
          ],
        ),
      ),
    );
  }
}
