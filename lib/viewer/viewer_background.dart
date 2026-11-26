import 'package:fluent_ui/fluent_ui.dart';

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
}