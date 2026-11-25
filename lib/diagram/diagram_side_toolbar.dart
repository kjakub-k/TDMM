import 'package:tdmm/diagram/diagram_mode.dart';
import 'package:fluent_ui/fluent_ui.dart';

class DiagramSideToolbar extends StatelessWidget {
  final ValueChanged<DiagramMode> onDiagramModeChanged;
  final DiagramMode currentDiagramMode;

  const DiagramSideToolbar({
    super.key,
    required this.onDiagramModeChanged,
    required this.currentDiagramMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 65,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: Colors.black,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),

          SideToolbarButton(
            diagramMode: DiagramMode.select,
            onDiagramModeChanged: onDiagramModeChanged,
            imagePath: 'assets/kursor_icon.png',
            currentDiagramMode: currentDiagramMode,
          ),

          const SizedBox(height: 12),

          SideToolbarButton(
            diagramMode: DiagramMode.placeTable,
            onDiagramModeChanged: onDiagramModeChanged,
            imagePath: 'assets/table_icon.png',
            currentDiagramMode: currentDiagramMode,
          ),

          const SizedBox(height: 12),

          SideToolbarButton(
            diagramMode: DiagramMode.placeOneToOne,
            onDiagramModeChanged: onDiagramModeChanged,
            imagePath: 'assets/one_to_one.png',
            currentDiagramMode: currentDiagramMode,
          ),

          const SizedBox(height: 12),

          SideToolbarButton(
            diagramMode: DiagramMode.placeOneToMany,
            onDiagramModeChanged: onDiagramModeChanged,
            imagePath: 'assets/one_to_many.png',
            currentDiagramMode: currentDiagramMode,
          ),

          const SizedBox(height: 12),

          SideToolbarButton(
            diagramMode: DiagramMode.placeManyToMany,
            onDiagramModeChanged: onDiagramModeChanged,
            imagePath: 'assets/many_to_many.png',
            currentDiagramMode: currentDiagramMode,
          )
        ],
      ),
    );
  }
}

class SideToolbarButton extends StatelessWidget {
  final DiagramMode diagramMode;
  final ValueChanged<DiagramMode> onDiagramModeChanged;
  final String imagePath;
  final DiagramMode currentDiagramMode;

  const SideToolbarButton({
    super.key,
    required this.diagramMode,
    required this.onDiagramModeChanged,
    required this.imagePath,
    required this.currentDiagramMode,
  });

  @override
  Widget build(BuildContext context) {
    final selected = currentDiagramMode == diagramMode;

    return Padding(
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: 50,
        height: 50,
        child: ToggleButton(
          checked: selected,
          onChanged: (_) {
            onDiagramModeChanged(diagramMode);
          },
          child: Image.asset(
            imagePath,
            width: 32,
            height: 32,
          ),
        ),
      ),
    );
  }
}
