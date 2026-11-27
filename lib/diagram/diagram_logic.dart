import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:tdmm/viewer/viewer_background.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'dart:convert';
import 'dart:io';

Future<ViewerBackground?> chooseBackground({
  required BackgroundMode backgroundMode,
}) async {
  final file = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: ['png', 'jpg', 'jpeg', 'webp', 'bmp'],
    windowsOptions: const WindowsOptions(lockParentWindow: true),
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

enum DiagramExportFormat {
  png(extension: 'png', mimeType: 'image/png', dialogTitle: 'Exportovat jako PNG'),
  jpeg(extension: 'jpg', mimeType: 'image/jpeg', dialogTitle: 'Exportovat jako JPEG');

  final String extension;
  final String mimeType;
  final String dialogTitle;

  const DiagramExportFormat({
    required this.extension,
    required this.mimeType,
    required this.dialogTitle,
  });
}

Future<Uri?> exportDiagramImage(
  ui.Image image, {
  required DiagramExportFormat format,
}) async {
  final Uint8List bytes;

  switch (format) {
    case DiagramExportFormat.png:
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) return null;
      bytes = data.buffer.asUint8List();

    case DiagramExportFormat.jpeg:
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (data == null) return null;
      final decoded = img.Image.fromBytes(
        width: image.width,
        height: image.height,
        bytes: data.buffer,
        numChannels: 4,
        order: img.ChannelOrder.rgba,
      );
      bytes = Uint8List.fromList(img.encodeJpg(decoded, quality: 95));
  }

  return FilePicker.saveFile(
    dialogTitle: format.dialogTitle,
    fileName: 'diagram.${format.extension}',
    bytes: bytes,
    mimeType: format.mimeType,
    type: FileType.custom,
    allowedExtensions: [format.extension],
    windowsOptions: const WindowsOptions(lockParentWindow: true),
  );
}



/// Saves JSON to [existingPath] if given; otherwise opens a Save As dialog.
/// Returns the saved file path, or null if canceled.
Future<String?> saveDiagramTdmm(
  Map<String, dynamic> data, {
  String? existingPath,
}) async {
  final jsonString = const JsonEncoder.withIndent('  ').convert(data);
  final bytes = Uint8List.fromList(utf8.encode(jsonString));

  if (existingPath != null) {
    await File(existingPath).writeAsBytes(bytes, flush: true);
    return existingPath;
  }

  final uri = await FilePicker.saveFile(
    dialogTitle: 'Uložit diagram',
    fileName: 'diagram.tdmm',
    bytes: bytes,
    mimeType: 'application/json',
    type: FileType.custom,
    allowedExtensions: ['tdmm'],
    windowsOptions: const WindowsOptions(lockParentWindow: true),
  );

  if (uri == null) return null;
  return uri.scheme == 'file' ? uri.toFilePath() : uri.toString();
}

Future<({String? path, Map<String, dynamic> data})?> loadDiagramTdmm() async {
  final file = await FilePicker.pickFile(
    dialogTitle: 'Načíst diagram',
    type: FileType.custom,
    allowedExtensions: ['tdmm'],
    windowsOptions: const WindowsOptions(lockParentWindow: true),
  );
  if (file == null) return null;

  final bytes = await file.readAsBytes();
  final decoded = jsonDecode(utf8.decode(bytes));
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Neplatná struktura JSON.');
  }

  return (path: file.path, data: decoded);
}