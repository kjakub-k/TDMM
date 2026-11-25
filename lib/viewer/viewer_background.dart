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

Widget buildBackground(
  BuildContext context,
  ViewerBackground viewerBackground,
) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(
        color: Colors.black,
        width: 1,
      ),
    ),
    child: Image(
      image: viewerBackground.image,
      fit: viewerBackground.mode == BackgroundMode.stretched
          ? BoxFit.fill
          : BoxFit.none,
      repeat: viewerBackground.mode == BackgroundMode.repeating
          ? ImageRepeat.repeat
          : ImageRepeat.noRepeat,
      alignment: Alignment.topLeft,
    ),
  );
}