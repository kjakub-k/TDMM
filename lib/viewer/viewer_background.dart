import 'package:fluent_ui/fluent_ui.dart';
import 'dart:convert';
import 'dart:typed_data';

enum BackgroundMode {
  repeating,
  stretched,
}

class ViewerBackground {
  BackgroundMode mode;
  ImageProvider image;

  ViewerBackground({
    this.mode = BackgroundMode.repeating,
    this.image = const AssetImage('assets/default_background.png'),
  });

  Map<String, dynamic> toJson() => {
    'mode': mode.name,
    'imageBase64': image is MemoryImage
        ? base64Encode((image as MemoryImage).bytes)
        : null,
  };

  factory ViewerBackground.fromJson(Map<String, dynamic> json) {
    final mode = BackgroundMode.values.byName(
      json['mode'] as String? ?? 'repeating',
    );
    final imageBase64 = json['imageBase64'] as String?;
    return ViewerBackground(
      mode: mode,
      image: imageBase64 != null
          ? MemoryImage(Uint8List.fromList(base64Decode(imageBase64)))
          : const AssetImage('assets/default_background.png'),
    );
  }
}