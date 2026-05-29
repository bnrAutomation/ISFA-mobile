import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/continuous_location_service.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';

class AppCameraPreview extends StatefulWidget {
  final String from;
  const AppCameraPreview({required this.from,super.key});
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setUpCameraController();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    super.dispose();
  }

  /// Dispose camera controller safely to avoid NPE in plugin (closeCaptureSession on null).
  void _disposeCamera() {
    if (cameraController == null) return;
    try {
      cameraController?.dispose();
    } catch (_) {
      // Plugin may throw when session is already closed (e.g. device closed first).
    }
    cameraController = null;
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
                        onPressed: () {
                          setState(() => _file = null);
                        },
                        icon: const Icon(Icons.refresh_rounded, color: Colors.white),
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
                        onPressed: () => context.pop(_file!.path),
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Use photo'),
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
                      'Saving photo…',
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
                color: capturing
                    ? Colors.white24
                    : ColorConstants.amber,
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

  Future<void> _handleShutterTap() async {
    try {
      if (loc == null) {
        context.showSnackBarMessage(
            'Location is required to stamp the photo.');
        try {
          setState(() => capturing = true);
          loc = await ContinuousLocationService.instance.resolveForSecureAction(
            fallbackDesiredAccuracy: LocationAccuracy.medium,
          );
          if (mounted) setState(() {});
        } catch (e) {
          setState(() => capturing = false);
          if (mounted) context.showSnackBarMessage(e.toString());
          return;
        }
      }
      if (!mounted) return;
      setState(() => capturing = true);
      final text =
          'DateTime: ${DateTime.now().toStringFormat("dd-MMM-yyyy hh:mm aa")}\nLatitude: ${loc?.latitude ?? 0.0}\nLongitude: ${loc?.longitude ?? 0.0}';
      final capturefile = await cameraController?.takePicture();
      if (capturefile == null) {
        if (mounted) setState(() => capturing = false);
        return;
      }
      final file = await addTextToImage(capturefile, text);
      if (!mounted) return;
      setState(() {
        _file = XFile(file);
        capturing = false;
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint(e.toString());
      }
      if (mounted) {
        context.showSnackBarMessage(e.toString());
        setState(() => capturing = false);
      }
    }
  }

  /// Decode cap keeps overlay GPU/CPU work bounded vs full [ResolutionPreset] capture.
  static const int _overlayMaxWidth = 1600;

  Future<String> addTextToImage(XFile imageFile, String text) async {
    final Uint8List bytes = await imageFile.readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: _overlayMaxWidth,
    );
    ui.Image? decoded;
    try {
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final image = frameInfo.image;
      decoded = image;
      final fontSize = (image.width * 0.038).clamp(22.0, 56.0);
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
        recorder,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      );
      canvas.drawImage(image, Offset.zero, Paint());

      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: Colors.red,
            backgroundColor: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout(maxWidth: image.width.toDouble() - 24);

      final x = (image.width - textPainter.width - 16)
          .clamp(0.0, image.width.toDouble());
      final y = (image.height - textPainter.height - 16)
          .clamp(0.0, image.height.toDouble());

      textPainter.paint(canvas, Offset(x, y));

      final picture = recorder.endRecording();
      final img = await picture.toImage(image.width, image.height);
      picture.dispose();
      final ByteData? byteData =
          await img.toByteData(format: ui.ImageByteFormat.png);
      img.dispose();

      final Uint8List pngBytes = byteData!.buffer.asUint8List();
      final File file = File(imageFile.path);
      await file.writeAsBytes(pngBytes);
      return file.path;
    } finally {
      decoded?.dispose();
      codec.dispose();
    }
  }

  Future<void> _setUpCameraController() async {
    try {
      List<CameraDescription> cameress = await availableCameras();
      if (cameress.isNotEmpty) {
        setState(() {
          cameres = cameress;

          if (kDebugMode) {
            debugPrint('Available cameras: ${cameres.length}');
            for (var i = 0; i < cameres.length; i++) {
              debugPrint(
                  'Camera $i: ${cameres[i].name} - ${cameres[i].lensDirection}');
            }
          }

          // Properly identify front and back cameras by lensDirection
          CameraDescription selectedCamera;
          
          if (isFront) {
            // Find front camera explicitly by lens direction
            try {
              selectedCamera = cameres.firstWhere(
                (camera) => camera.lensDirection == CameraLensDirection.front,
              );
              if (kDebugMode) {
                debugPrint('Selected FRONT camera: ${selectedCamera.name}');
              }
            } catch (e) {
              if (kDebugMode) {
                debugPrint('Front camera not found, using first camera');
              }
              selectedCamera = cameres.first;
            }
          } else {
            // Find back camera explicitly by lens direction
            try {
              selectedCamera = cameres.firstWhere(
                (camera) => camera.lensDirection == CameraLensDirection.back,
              );
              if (kDebugMode) {
                debugPrint('Selected BACK camera: ${selectedCamera.name}');
              }
            } catch (e) {
              if (kDebugMode) {
                debugPrint('Back camera not found, using first camera');
              }
              selectedCamera = cameres.first;
            }
          }
          
          cameraController = CameraController(
            selectedCamera,
            ResolutionPreset.high,
            enableAudio: false,
          );
        });
        cameraController?.initialize().then((value) {
          setState(() {});
        });
      } else {
        context.showSnackBarMessage('Please allow camera permission.');
      }
    } catch (e) {
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
