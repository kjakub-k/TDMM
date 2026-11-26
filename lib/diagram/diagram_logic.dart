import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:tdmm/viewer/viewer_background.dart';

Future<ViewerBackground?> chooseBackground({
  required BackgroundMode backgroundMode,
}) async {
  final file = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: ['png', 'jpg', 'jpeg', 'webp', 'bmp'],
  );

  if (file == null) {
    return null;
  }

  final bytes = await file.readAsBytes();

  if (bytes.isEmpty) {
    return null;
  }

  return ViewerBackground(
    image: MemoryImage(bytes),
    mode: backgroundMode,
  );
}