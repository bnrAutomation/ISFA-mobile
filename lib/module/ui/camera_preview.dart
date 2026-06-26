import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/continuous_location_service.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:image/image.dart' as img;

/// Params for [watermarkImageWorker] — must be a simple top-level type for [compute].
class WatermarkImageParams {
  const WatermarkImageParams({
    required this.path,
    required this.text,
    required this.maxWidth,
  });

  final String path;
  final String text;
  final int maxWidth;
}

/// Decode cap keeps overlay work bounded vs full [ResolutionPreset] capture.
const int kCameraWatermarkMaxWidth = 1600;

int _bitmapFontStringWidth(img.BitmapFont font, String string) {
  var width = 0;
  for (final codeUnit in string.codeUnits) {
    if (!font.characters.containsKey(codeUnit)) {
      width += font.base ~/ 2;
      continue;
    }
    width += font.characters[codeUnit]!.xAdvance;
  }
  return width;
}

/// Burns stamp text into [WatermarkImageParams.path] as JPEG (runs in isolate).
String watermarkImageWorker(WatermarkImageParams params) {
  final bytes = File(params.path).readAsBytesSync();
  img.Image? image = img.decodeImage(bytes);
  if (image == null) {
    throw Exception('Failed to decode image for watermark');
  }

  if (image.width > params.maxWidth) {
    image = img.copyResize(image, width: params.maxWidth);
  }

  final lines = params.text.split('\n');
  const lineHeight = 28;
  const padding = 8;
  var maxLineWidth = 0;
  for (final line in lines) {
    final w = _bitmapFontStringWidth(img.arial24, line);
    if (w > maxLineWidth) maxLineWidth = w;
  }

  final blockHeight = lines.length * lineHeight + padding * 2;
  final blockWidth = maxLineWidth + padding * 2;
  final blockX =
      (image.width - blockWidth - 16).clamp(0, image.width).toInt();
  final blockY =
      (image.height - blockHeight - 16).clamp(0, image.height).toInt();

  img.fillRect(
    image,
    x1: blockX,
    y1: blockY,
    x2: blockX + blockWidth,
    y2: blockY + blockHeight,
    color: img.ColorRgb8(255, 255, 255),
  );

  var y = blockY + padding;
  for (final line in lines) {
    img.drawString(
      image,
      line,
      font: img.arial24,
      x: blockX + blockWidth - padding,
      y: y,
      rightJustify: true,
      color: img.ColorRgb8(255, 0, 0),
    );
    y += lineHeight;
  }

  File(params.path).writeAsBytesSync(img.encodeJpg(image, quality: 88));
  return params.path;
}

class AppCameraPreview extends StatefulWidget {
  final String from;
  const AppCameraPreview({required this.from, super.key});
  @override
  State<AppCameraPreview> createState() => _CameraPreviewState();
}

class _CameraPreviewState extends State<AppCameraPreview>
    with WidgetsBindingObserver {
  List<CameraDescription> cameres = [];
  CameraController? cameraController;
  XFile? _file;
  bool isFront = false;
  Position? loc;
  bool capturing = false;
  bool _watermarking = false;
  bool _locating = false;
  int _watermarkGeneration = 0;
  int _locationPrefetchGeneration = 0;
  int _cameraSetupGeneration = 0;
  final ContinuousLocationService _locationService =
      ContinuousLocationService.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _locationService.addListener(_onLocationServiceUpdate);
    unawaited(_locationService.start());
    _applyCachedLocation();
    _prefetchLocation();
    _setUpCameraController();
  }

  void _applyCachedLocation() {
    final cached = _locationService.snapshot.lastValidPosition;
    if (cached != null) {
      loc = cached;
    }
  }

  void _onLocationServiceUpdate() {
    if (!mounted || loc != null) return;
    final cached = _locationService.snapshot.lastValidPosition;
    if (cached != null) {
      setState(() => loc = cached);
    }
  }

  Future<void> _prefetchLocation() async {
    if (loc != null) return;
    final gen = ++_locationPrefetchGeneration;
    if (mounted) setState(() => _locating = true);
    try {
      final position =
          await _locationService.resolveForSecureActionFast();
      if (!mounted || gen != _locationPrefetchGeneration || loc != null) {
        return;
      }
      setState(() => loc = position);
    } catch (_) {
      // Shutter tap will retry; chip stays on "GPS on capture" until then.
    } finally {
      if (mounted && gen == _locationPrefetchGeneration) {
        setState(() => _locating = false);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locationService.removeListener(_onLocationServiceUpdate);
    _locationPrefetchGeneration++;
    _watermarkGeneration++;
    _cameraSetupGeneration++;
    unawaited(_disposeCamera());
    super.dispose();
  }

  /// Dispose camera controller safely to avoid NPE in plugin (closeCaptureSession on null).
  Future<void> _disposeCamera() async {
    final controller = cameraController;
    cameraController = null;
    if (controller == null) return;
    try {
      await controller.dispose();
    } catch (_) {
      // Plugin may throw when session is already closed (e.g. device closed first).
    }
  }

  /// iPhone 17+ needs a lower preset to avoid unsupported btp2 pixel formats.
  Future<ResolutionPreset> _resolveResolutionPreset() async {
    if (!Platform.isIOS) return ResolutionPreset.high;
    final ios = await DeviceInfoPlugin().iosInfo;
    if (ios.utsname.machine.contains('iPhone18')) {
      return ResolutionPreset.veryHigh;
    }
    return ResolutionPreset.high;
  }

  CameraDescription _selectCamera(List<CameraDescription> cameras) {
    if (isFront) {
      if (Platform.isIOS) {
        final mainFront = cameras.where(
          (c) =>
              c.lensDirection == CameraLensDirection.front &&
              c.name.endsWith(':1'),
        );
        if (mainFront.isNotEmpty) return mainFront.first;
      }
      return cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
    }

    if (Platform.isIOS) {
      // Prefer main wide back (:0); avoid ultra-wide (:5) on multi-camera iPhones.
      final mainBack = cameras.where(
        (c) =>
            c.lensDirection == CameraLensDirection.back && c.name.endsWith(':0'),
      );
      if (mainBack.isNotEmpty) return mainBack.first;
    }
    return cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Do not dispose on inactive: it races with Android camera device close
    // and can trigger NPE in camera plugin (closeCaptureSession on null).
    // Only dispose when the widget is disposed (user leaves the screen).
    if (state == AppLifecycleState.resumed) {
      if (cameraController == null ||
          !(cameraController?.value.isInitialized ?? false)) {
        _setUpCameraController();
      }
      _prefetchLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (cameraController == null ||
        cameraController?.value.isInitialized == false) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: ColorConstants.amber,
              strokeWidth: 3,
            ),
            SizedBox(height: 24.h),
            Text(
              'Preparing camera…',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_file != null) {
      return _buildReviewUI();
    }

    return _buildCameraUI();
  }

  Widget _buildReviewUI() {
    return Stack(
      fit: StackFit.expand,
      children: [
        InteractiveViewer(
          minScale: 0.8,
          maxScale: 4,
          child: Center(
            child: Image.file(
              File(_file!.path),
              fit: BoxFit.contain,
              gaplessPlayback: true,
            ),
          ),
        ),
        if (_watermarking)
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: _pillChip(
                  icon: Icons.branding_watermark_outlined,
                  label: 'Stamping photo…',
                ),
              ),
            ),
          ),
        SafeArea(
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: _circleIconButton(
                icon: Icons.close_rounded,
                onPressed: () => context.pop(),
                tooltip: 'Close',
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.88),
                ],
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 32.h, 20.w, 20.h),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _watermarking
                            ? null
                            : () {
                                _watermarkGeneration++;
                                setState(() {
                                  _file = null;
                                  _watermarking = false;
                                });
                              },
                        icon: const Icon(Icons.refresh_rounded,
                            color: Colors.white),
                        label: const Text('Retake'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        onPressed: _watermarking
                            ? null
                            : () => context.pop(_file!.path),
                        icon: _watermarking
                            ? SizedBox(
                                width: 18.w,
                                height: 18.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black87,
                                ),
                              )
                            : const Icon(Icons.check_rounded),
                        label: Text(_watermarking ? 'Stamping…' : 'Use photo'),
                        style: FilledButton.styleFrom(
                          backgroundColor: ColorConstants.amber,
                          foregroundColor: Colors.black87,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraUI() {
    final hintMarkIn = widget.from == 'markinout'
        ? 'Stand in front of the store and keep the storefront visible.'
        : 'Align your face in the frame before capturing.';

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: Colors.black,
          child: Center(
            child: CameraPreview(cameraController!),
          ),
        ),
        IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: CustomPaint(
              painter: _CameraFramePainter(
                color: Colors.white.withValues(alpha: 0.35),
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(8.w, 4.h, 8.w, 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _circleIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onPressed: () => context.pop(),
                    tooltip: 'Back',
                    iconSize: 20,
                  ),
                  const Spacer(),
                  if (loc != null)
                    _pillChip(
                      icon: Icons.gps_fixed_rounded,
                      label: 'Location locked',
                    )
                  else if (_locating)
                    _pillChip(
                      icon: Icons.gps_not_fixed_rounded,
                      label: 'Acquiring GPS…',
                    )
                  else
                    _pillChip(
                      icon: Icons.gps_not_fixed_rounded,
                      label: 'GPS on capture',
                    ),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.92),
                ],
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 20.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      hintMarkIn,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14.sp,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 56.w,
                          child: Center(
                            child: _circleIconButton(
                              icon: Icons.cameraswitch_rounded,
                              onPressed: capturing
                                  ? null
                                  : () {
                                      isFront = !isFront;
                                      _setUpCameraController();
                                    },
                              tooltip: 'Flip camera',
                              iconSize: 26,
                            ),
                          ),
                        ),
                        _shutterButton(),
                        SizedBox(width: 56.w),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (capturing)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: ColorConstants.amber,
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Capturing…',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _shutterButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: capturing ? null : _handleShutterTap,
        child: Ink(
          width: 76.w,
          height: 76.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            color: Colors.transparent,
          ),
          child: Center(
            child: Container(
              width: 58.w,
              height: 58.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: capturing ? Colors.white24 : ColorConstants.amber,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
    String? tooltip,
    double iconSize = 24,
  }) {
    return Material(
      color: Colors.black45,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, color: Colors.white, size: iconSize.sp),
        onPressed: onPressed,
        style: IconButton.styleFrom(
          padding: EdgeInsets.all(12.w),
        ),
      ),
    );
  }

  Widget _pillChip({required IconData icon, required String label}) {
    return Material(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: ColorConstants.amber, size: 16.sp),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _stampText() =>
      'DateTime: ${DateTime.now().toStringFormat("dd-MMM-yyyy hh:mm aa")}\n'
      'Latitude: ${loc?.latitude ?? 0.0}\n'
      'Longitude: ${loc?.longitude ?? 0.0}';

  Future<void> _applyWatermarkAsync(XFile capturefile, String text) async {
    final gen = ++_watermarkGeneration;
    final capturePath = capturefile.path;
    try {
      final path = await compute(
        watermarkImageWorker,
        WatermarkImageParams(
          path: capturePath,
          text: text,
          maxWidth: kCameraWatermarkMaxWidth,
        ),
      );
      if (!mounted ||
          gen != _watermarkGeneration ||
          _file?.path != capturePath) {
        return;
      }
      setState(() {
        _file = XFile(path);
        _watermarking = false;
      });
    } catch (e) {
      if (!mounted ||
          gen != _watermarkGeneration ||
          _file?.path != capturePath) {
        return;
      }
      setState(() => _watermarking = false);
      context.showSnackBarMessage('Failed to stamp photo: $e');
    }
  }

  Future<void> _handleShutterTap() async {
    try {
      if (loc == null) {
        setState(() => capturing = true);
        try {
          loc = await _locationService.resolveForSecureActionFast();
          if (mounted) setState(() {});
        } catch (e) {
          if (mounted) {
            setState(() => capturing = false);
            context.showSnackBarMessage(e.toString());
          }
          return;
        }
      }
      if (!mounted) return;
      setState(() => capturing = true);
      final capturefile = await cameraController?.takePicture();
      if (capturefile == null) {
        if (mounted) setState(() => capturing = false);
        return;
      }
      final text = _stampText();
      if (!mounted) return;
      setState(() {
        _file = capturefile;
        capturing = false;
        _watermarking = true;
      });
      await _applyWatermarkAsync(capturefile, text);
    } catch (e) {
      if (kDebugMode) {
        debugPrint(e.toString());
      }
      if (mounted) {
        context.showSnackBarMessage(e.toString());
        setState(() {
          capturing = false;
          _watermarking = false;
        });
      }
    }
  }

  Future<void> _setUpCameraController() async {
    if (!mounted) return;
    final gen = ++_cameraSetupGeneration;
    try {
      final cameras = await availableCameras();
      if (!mounted || gen != _cameraSetupGeneration) return;

      if (cameras.isEmpty) {
        context.showSnackBarMessage('Please allow camera permission.');
        return;
      }

      if (kDebugMode) {
        debugPrint('Available cameras: ${cameras.length}');
        for (var i = 0; i < cameras.length; i++) {
          debugPrint(
            'Camera $i: ${cameras[i].name} - ${cameras[i].lensDirection}',
          );
        }
      }

      final selectedCamera = _selectCamera(cameras);
      final preset = await _resolveResolutionPreset();
      if (!mounted || gen != _cameraSetupGeneration) return;

      if (kDebugMode) {
        debugPrint(
          'Selected ${isFront ? 'FRONT' : 'BACK'} camera: '
          '${selectedCamera.name} (preset: $preset)',
        );
      }

      await _disposeCamera();
      if (!mounted || gen != _cameraSetupGeneration) return;

      final controller = CameraController(
        selectedCamera,
        preset,
        enableAudio: false,
        imageFormatGroup:
            Platform.isIOS ? ImageFormatGroup.jpeg : ImageFormatGroup.yuv420,
      );

      await controller.initialize();
      if (!mounted || gen != _cameraSetupGeneration) {
        await controller.dispose();
        return;
      }

      setState(() {
        cameres = cameras;
        cameraController = controller;
      });
    } on CameraException catch (e) {
      if (!mounted || gen != _cameraSetupGeneration) return;
      context.showSnackBarMessage(e.description ?? e.code);
    } catch (e) {
      if (!mounted || gen != _cameraSetupGeneration) return;
      context.showSnackBarMessage(e.toString());
    }
  }
}

/// Subtle corner brackets to suggest framing (non-interactive overlay).
class _CameraFramePainter extends CustomPainter {
  _CameraFramePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const inset = 36.0;
    const len = 42.0;
    final w = size.width;
    final h = size.height;

    void corner(double sx, double sy, double dx, double dy) {
      canvas.drawLine(Offset(sx, sy), Offset(sx + dx, sy), paint);
      canvas.drawLine(Offset(sx, sy), Offset(sx, sy + dy), paint);
    }

    corner(inset, inset, len, 0);
    corner(inset, inset, 0, len);

    corner(w - inset, inset, -len, 0);
    corner(w - inset, inset, 0, len);

    corner(inset, h - inset, len, 0);
    corner(inset, h - inset, 0, -len);

    corner(w - inset, h - inset, -len, 0);
    corner(w - inset, h - inset, 0, -len);
  }

  @override
  bool shouldRepaint(covariant _CameraFramePainter oldDelegate) =>
      oldDelegate.color != color;
}
