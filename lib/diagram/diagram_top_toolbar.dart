import 'package:tdmm/viewer/viewer_background.dart';
import 'package:tdmm/diagram/diagram_logic.dart';
import 'package:fluent_ui/fluent_ui.dart';

class DiagramTopToolbar extends StatelessWidget {
  final ViewerBackground viewerBackground;
  final ValueChanged<ViewerBackground> onBackgroundChanged;
  final Size viewerSize;
  final ValueChanged<Size> onViewerSizeChanged;
  final VoidCallback? onSave;
  final VoidCallback? onSaveAs;
  final VoidCallback? onLoad;
  final VoidCallback? onExport;

  const DiagramTopToolbar({
    super.key,
    required this.viewerBackground,
    required this.onBackgroundChanged,
    required this.viewerSize,
    required this.onViewerSizeChanged,
    this.onSave,
    this.onSaveAs,
    this.onLoad,
    this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.black,
          ),
        ),
      ),
      child: Row(
        children: [
          DropDownButton(
            title: const Text('Soubor'),
            items: [
              MenuFlyoutItem(
                text: const Text('Uložit'),
                onPressed: onSave != null ? () => onSave!() : null,
              ),
              MenuFlyoutItem(
                text: const Text('Uložit jako...'),
                onPressed: onSaveAs != null ? () => onSaveAs!() : null,
              ),
              MenuFlyoutItem(
                text: const Text('Načíst'),
                onPressed: onLoad != null ? () => onLoad!() : null,
              ),
              const MenuFlyoutSeparator(),
              MenuFlyoutItem(
                text: const Text('Exportovat'),
                onPressed: onExport != null ? () => onExport!() : null,
              ),
            ]
          ),

          SizedBox(width: 8,),
          
          DropDownButton(
            title: const Text('Diagram'),
            items: [
              MenuFlyoutItem(
                text: const Text('Změnit velikost'),
                onPressed: () async {
                  final newSize = await showDiagramSizeDialog(
                    context,
                    currentSize: viewerSize,
                  );

                  if (newSize != null) {
                    onViewerSizeChanged(newSize);
                  }
                },
              ),

              const MenuFlyoutSeparator(),

              MenuFlyoutItem(
                text: const Text('Vybrat pozadí (Opakovaný)'),
                onPressed: () async {
                  final newBackground = await chooseBackground(
                    backgroundMode: BackgroundMode.repeating,
                  );

                  if (newBackground != null) {
                    onBackgroundChanged(newBackground);
                  }
                },
              ),

              MenuFlyoutItem(
                text: const Text('Vybrat pozadí (Roztáhnutý)'),
                onPressed: () async {
                  final newBackground = await chooseBackground(
                    backgroundMode: BackgroundMode.stretched,
                  );

                  if (newBackground != null) {
                    onBackgroundChanged(newBackground);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<Size?> showDiagramSizeDialog(
    BuildContext context, {
    required Size currentSize,
  }) async {
    final widthController = TextEditingController(
      text: currentSize.width.round().toString(),
    );

    final heightController = TextEditingController(
      text: currentSize.height.round().toString(),
    );

    try {
      return await showDialog<Size>(
        context: context,
        builder: (context) {
          return ContentDialog(
            title: const Text('Změnit velikost'),

            content: SizedBox(
              width: 320,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Šířka (px)'),
                  const SizedBox(height: 6),

                  TextBox(
                    controller: widthController,
                    keyboardType: TextInputType.number,
                    placeholder: '1200',
                  ),

                  const SizedBox(height: 16),

                  const Text('Výška (px)'),
                  const SizedBox(height: 6),

                  TextBox(
                    controller: heightController,
                    keyboardType: TextInputType.number,
                    placeholder: '800',
                  ),
                ],
              ),
            ),

            actions: [
              Button(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Zrušit'),
              ),

              FilledButton(
                onPressed: () {
                  final width = double.tryParse(
                    widthController.text,
                  );

                  final height = double.tryParse(
                    heightController.text,
                  );

                  if (width == null ||
                      height == null ||
                      !width.isFinite ||
                      !height.isFinite ||
                      width <= 0 ||
                      height <= 0) {
                    return;
                  }

                  Navigator.pop(
                    context,
                    Size(width, height),
                  );
                },
                child: const Text('Použít'),
              ),
            ],
          );
        },
      );
    } finally {
      widthController.dispose();
      heightController.dispose();
    }
  }
}
