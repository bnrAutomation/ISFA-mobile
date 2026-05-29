import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/module/ui/custom_material_button.dart';
import 'package:i_densfa/routes.dart';
import 'package:image_picker/image_picker.dart';

class CheckInView extends StatefulWidget {
  const CheckInView({super.key});

  @override
  State<CheckInView> createState() => _CheckInViewState();
}

class _CheckInViewState extends State<CheckInView> {
  XFile? image;

  Future<void> _openCamera() async {
    final result = await context.pushNamed(
      AppPaths.appcamera,
      pathParameters: {'from': 'checkinout'},
    );
    if (!mounted) return;
    final path = result is String ? result : null;
    if (path != null && path.isNotEmpty) {
      setState(() => image = XFile(path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in'),
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Material(
                        color: cs.primaryContainer.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: EdgeInsets.all(14.w),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.storefront_rounded,
                                color: theme.primaryColor,
                                size: 24.sp,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  'Please be at the store when you mark attendance. Your photo should show the surroundings clearly.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    height: 1.35,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Store selfie',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.15,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Tap the frame to open the camera',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      AspectRatio(
                        aspectRatio: 1,
                        child: Material(
                          color: cs.surfaceContainerHighest
                              .withValues(alpha: 0.45),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(
                              color: theme.primaryColor.withValues(alpha: 0.45),
                              width: 1.2,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: _openCamera,
                            child: image == null
                                ? Padding(
                                    padding: EdgeInsets.all(20.w),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.photo_camera_rounded,
                                          size: 48.sp,
                                          color: theme.primaryColor
                                              .withValues(alpha: 0.85),
                                        ),
                                        SizedBox(height: 14.h),
                                        Text(
                                          'Include the surroundings and avoid glare.',
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: theme.primaryColor,
                                            fontWeight: FontWeight.w600,
                                            height: 1.35,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Image.file(
                                    File(image!.path),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      SizedBox(
                        width: double.infinity,
                        child: CustomMaterialButton(
                          buttonText:
                              image == null ? 'Take selfie' : 'Submit',
                          onPressed: () async {
                            if (image == null) {
                              await _openCamera();
                            } else {
                              if (context.mounted) {
                                context.pop(image);
                              }
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
