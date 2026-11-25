import 'package:fluent_ui/fluent_ui.dart';
import 'package:tdmm/diagram/diagram_editor.dart';

const setCanvasSize = Size(1200, 800);

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: FluentThemeData(
        brightness: Brightness.light,
        accentColor: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFE2E2E2),
      ),
      home: DiagramEditor(setSize: setCanvasSize),
    );
  }
}
