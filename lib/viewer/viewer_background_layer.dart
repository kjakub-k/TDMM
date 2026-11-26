import 'package:fluent_ui/fluent_ui.dart';
import 'package:tdmm/viewer/viewer_background.dart';

class ViewerBackgroundLayer extends StatelessWidget {
  final ViewerBackground viewerBackground;

  const ViewerBackgroundLayer({
    super.key,
    required this.viewerBackground,
  });

  @override
  Widget build(BuildContext context) {
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
}