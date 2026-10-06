import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anatomy_fitness_app_mobile/core/theme/app_colors.dart';
import 'package:anatomy_fitness_app_mobile/features/anatomy/presentation/providers/selected_muscle_provider.dart';

class BodyView2d extends ConsumerStatefulWidget {
  const BodyView2d({super.key});

  @override
  ConsumerState<BodyView2d> createState() => _BodyView2dState();
}

class _BodyView2dState extends ConsumerState<BodyView2d> {
  ui.Image? _frontImage;
  ui.Image? _backImage;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    _frontImage = await _loadImageAsset('assets/images/front.png');
    _backImage = await _loadImageAsset('assets/images/back.png');
    if (mounted) setState(() {});
  }

  Future<ui.Image> _loadImageAsset(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  // SVG-to-Path Parser implementation
  Path _parsePathData(String d) {
    final path = Path();
    final tokens = d.split(RegExp(r'\s+|,')).where((t) => t.isNotEmpty).toList();
    int idx = 0;
    while (idx < tokens.length) {
      final token = tokens[idx];
      
      if (token == 'M' || token == 'm') {
        final x = double.parse(tokens[idx + 1]);
        final y = double.parse(tokens[idx + 2]);
        path.moveTo(x, y);
        idx += 3;
      } else if (token == 'L' || token == 'l') {
        final x = double.parse(tokens[idx + 1]);
        final y = double.parse(tokens[idx + 2]);
        path.lineTo(x, y);
        idx += 3;
      } else if (token == 'C' || token == 'c') {
        final x1 = double.parse(tokens[idx + 1]);
        final y1 = double.parse(tokens[idx + 2]);
        final x2 = double.parse(tokens[idx + 3]);
        final y2 = double.parse(tokens[idx + 4]);
        final x = double.parse(tokens[idx + 5]);
        final y = double.parse(tokens[idx + 6]);
        path.cubicTo(x1, y1, x2, y2, x, y);
        idx += 7;
      } else if (token == 'Z' || token == 'z') {
        path.close();
        idx++;
      } else {
        idx++;
      }
    }
    return path;
  }

  // Raw Path Strings (Anterior & Posterior)
  Map<String, String> get _anteriorPaths => {
    'neck': 'M 136 72 C 136 80, 138 88, 142 94 L 158 94 C 162 88, 164 80, 164 72 Z',
    'shoulder-left': 'M 124 88 C 112 90, 103 98, 102 110 C 101 119, 107 125, 116 126 C 122 122, 124 110, 125 88 Z',
    'shoulder-right': 'M 176 88 C 188 90, 197 98, 198 110 C 199 119, 193 125, 184 126 C 178 122, 176 110, 175 88 Z',
    'chest': 'M 150 93 C 140 92, 130 90, 125 88 C 117 96, 116 112, 120 128 C 130 134, 142 130, 150 120 C 158 130, 170 134, 180 128 C 184 112, 183 96, 175 88 C 170 90, 160 92, 150 93 Z',
    'biceps-left': 'M 104 120 C 97 124, 96 138, 100 148 C 104 152, 110 148, 113 140 C 115 130, 110 122, 104 120 Z',
    'biceps-right': 'M 196 120 C 203 124, 204 138, 200 148 C 196 152, 190 148, 187 140 C 185 130, 190 122, 196 120 Z',
    'forearm-left': 'M 100 148 C 94 154, 88 168, 90 186 C 92 192, 98 191, 100 183 C 104 172, 109 160, 111 144 Z',
    'forearm-right': 'M 200 148 C 206 154, 212 168, 210 186 C 208 192, 202 191, 200 183 C 196 172, 191 160, 189 144 Z',
    'abs': 'M 129 129 C 127 150, 127 175, 132 196 L 168 196 C 173 175, 173 150, 171 129 Z',
    'quads-left': 'M 125 198 C 120 215, 115 242, 119 270 C 121 282, 131 285, 145 281 C 147 265, 149 220, 147 198 Z',
    'quads-right': 'M 175 198 C 180 215, 185 242, 181 270 C 179 282, 169 285, 155 281 C 153 265, 151 220, 153 198 Z',
    'calves-left': 'M 120 286 C 113 296, 111 316, 118 335 C 123 355, 127 368, 130 376 L 137 376 C 137 360, 134 312, 132 286 Z',
    'calves-right': 'M 180 286 C 187 296, 189 316, 182 335 C 177 355, 173 368, 170 376 L 163 376 C 163 360, 166 312, 168 286 Z',
  };
 
  Map<String, String> get _posteriorPaths => {
    'traps': 'M 138 72 C 142 80, 145 84, 150 86 C 155 84, 158 80, 162 72 L 170 88 C 160 95, 140 95, 130 88 Z',
    'lats': 'M 130 90 C 140 96, 160 96, 170 90 C 178 112, 171 144, 150 166 C 129 144, 122 112, 130 90 Z',
    'shoulder-left': 'M 125 88 C 115 90, 107 100, 108 112 C 110 118, 116 119, 122 116 Z',
    'shoulder-right': 'M 175 88 C 185 90, 193 100, 192 112 C 190 118, 184 119, 178 116 Z',
    'triceps-left': 'M 107 114 C 98 122, 97 136, 102 148 L 110 138 C 111 130, 111 120, 107 114 Z',
    'triceps-right': 'M 193 114 C 202 122, 203 136, 198 148 L 190 138 C 189 130, 189 120, 193 114 Z',
    'glutes': 'M 128 168 C 135 168, 145 174, 150 176 C 155 174, 165 168, 172 168 C 184 185, 184 212, 171 222 C 162 225, 155 220, 150 216 C 145 220, 138 225, 129 222 C 116 212, 116 185, 128 168 Z',
    'hamstrings-left': 'M 122 224 C 128 224, 138 225, 146 222 C 145 245, 141 270, 137 284 C 131 285, 125 282, 121 270 C 119 250, 120 234, 122 224 Z',
    'hamstrings-right': 'M 178 224 C 172 224, 162 225, 154 222 C 155 245, 159 270, 163 284 C 169 285, 175 282, 179 270 C 181 250, 180 234, 178 224 Z',
    'calves-left': 'M 120 286 C 113 296, 111 316, 118 335 C 123 355, 127 368, 130 376 L 137 376 C 137 360, 134 312, 132 286 Z',
    'calves-right': 'M 180 286 C 187 296, 189 316, 182 335 C 177 355, 173 368, 170 376 L 163 376 C 163 360, 166 312, 168 286 Z',
  };
 
  // Maps nested detailed paths to standard muscle keys
  String _mapSubIdToMuscleId(String subId) {
    if (subId.startsWith('shoulder-')) return 'shoulders';
    if (subId.startsWith('biceps-')) return 'biceps';
    if (subId.startsWith('triceps-')) return 'triceps';
    if (subId.startsWith('forearm-')) return 'forearms';
    if (subId.startsWith('quads-')) return 'quads';
    if (subId.startsWith('hamstrings-')) return 'hamstrings';
    if (subId.startsWith('calves-')) return 'calves';
    if (subId == 'traps' || subId == 'lats') return 'back';
    return subId; // abs, neck, chest, glutes
  }

  @override
  Widget build(BuildContext context) {
    final isFront = ref.watch(isFrontViewProvider);
    final selectedId = ref.watch(selectedMuscleIdProvider);
    final zoom = ref.watch(zoomLevelProvider);

    final rawPaths = isFront ? _anteriorPaths : _posteriorPaths;
    final parsedPaths = rawPaths.map((key, val) => MapEntry(key, _parsePathData(val)));

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapDown: (details) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final localPos = box.globalToLocal(details.globalPosition);
            
            final scale = (box.size.height / 420.0) * zoom;
            final originX = (box.size.width - (300.0 * scale)) / 2;
            final originY = (box.size.height - (420.0 * scale)) / 2;
            
            final targetX = (localPos.dx - originX) / scale;
            final targetY = (localPos.dy - originY) / scale;
            final checkPoint = Offset(targetX, targetY);

            String? hitMuscleId;
            parsedPaths.forEach((id, path) {
              if (path.contains(checkPoint)) {
                hitMuscleId = _mapSubIdToMuscleId(id);
              }
            });

            if (hitMuscleId != null) {
              ref.read(selectedMuscleIdProvider.notifier).state = hitMuscleId;
            } else {
              ref.read(selectedMuscleIdProvider.notifier).state = null;
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: ClipRect(
              child: CustomPaint(
                painter: MusclePainter(
                  paths: parsedPaths,
                  selectedId: selectedId,
                  mapFunc: _mapSubIdToMuscleId,
                  backgroundImage: isFront ? _frontImage : _backImage,
                  zoom: zoom,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MusclePainter extends CustomPainter {
  final Map<String, Path> paths;
  final String? selectedId;
  final String Function(String) mapFunc;
  final ui.Image? backgroundImage;
  final double zoom;

  const MusclePainter({
    required this.paths,
    required this.selectedId,
    required this.mapFunc,
    this.backgroundImage,
    required this.zoom,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = (size.height / 420.0) * zoom;
    final double offsetX = (size.width - (300.0 * scale)) / 2;
    final double offsetY = (size.height - (420.0 * scale)) / 2;

    // Apply viewport translation and scale
    canvas.save();
    canvas.translate(offsetX, offsetY);
    canvas.scale(scale);

    // Draw background image if available (fits 300x420 viewport)
    if (backgroundImage != null) {
      final paint = Paint()..filterQuality = FilterQuality.medium;
      canvas.drawImageRect(
        backgroundImage!,
        Rect.fromLTWH(0, 0, backgroundImage!.width.toDouble(), backgroundImage!.height.toDouble()),
        const Rect.fromLTWH(0, 0, 300, 420),
        paint,
      );
    }

    // Paint options
    final baseFillPaint = Paint()
      ..color = const Color(0xFF14171D).withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final hoverFillPaint = Paint()
      ..color = AppColors.neonOrange.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    // Draw paths
    paths.forEach((id, path) {
      final isSelected = selectedId == mapFunc(id);
      
      if (isSelected) {
        // Layer glowing shadow underneath
        canvas.drawPath(
          path,
          Paint()
            ..color = AppColors.neonOrange.withValues(alpha: 0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
        );
        canvas.drawPath(path, hoverFillPaint);
        
        // Draw border for the selected muscle only
        canvas.drawPath(
          path,
          Paint()
            ..color = AppColors.neonOrange.withValues(alpha: 0.6)
            ..strokeWidth = 1.5
            ..style = PaintingStyle.stroke,
        );
      } else {
        canvas.drawPath(path, baseFillPaint);
      }
    });

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MusclePainter oldDelegate) {
    return oldDelegate.selectedId != selectedId || 
        oldDelegate.paths != paths || 
        oldDelegate.backgroundImage != backgroundImage ||
        oldDelegate.zoom != zoom;
  }
}
