import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/module/ui/app_image_picker.dart';
import 'package:i_densfa/module/ui/custom_material_button.dart';
import 'package:i_densfa/module/ui/speech_input_widgets.dart';
import 'package:i_densfa/utility/extensions.dart';

import 'bloc/help_bloc.dart';

class HelpView extends StatelessWidget {
  const HelpView({super.key});

  InputDecoration _fieldDecoration(BuildContext context, String hint) {
    final theme = Theme.of(context);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: theme.dividerColor.withValues(alpha: 0.65),
      ),
    );
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor:
          theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: BlocProvider(
        create: (context) => HelpBloc(),
        child: BlocConsumer<HelpBloc, HelpState>(
          listenWhen: (previous, current) =>
              current is HelpErrorState || current is HelpSuccessState,
          listener: (context, state) {
            if (state is HelpErrorState) {
              context.showSnackBarMessage(state.errorMessage);
            }
            if (state is HelpSuccessState) {
              _showSuccessDialog(
                context,
                context.read<HelpBloc>().showDialogMessage,
              );
            }
          },
          builder: (context, state) {
            final textTheme = Theme.of(context).textTheme;
            final bloc = context.read<HelpBloc>();
            final isLoading = state is HelpLoadingState;

            return Stack(
              children: [
                SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 28.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HelpInfoBanner(theme: theme),
                      SizedBox(height: 20.h),
                      Text(
                        'Subject',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TapRegion(
                        onTapOutside: (_) => context.hideKeyboard(),
                        child: SpeechEnabledTextFormField(
                          decoration: _fieldDecoration(
                            context,
                            'Brief summary of your issue…',
                          ),
                          textInputAction: TextInputAction.next,
                          onChanged: (value) =>
                              bloc.add(AddTitleHelpEvent(value)),
                        ),
                      ),
                      SizedBox(height: 18.h),
                      Text(
                        'Message',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TapRegion(
                        onTapOutside: (_) => context.hideKeyboard(),
                        child: SpeechEnabledTextFormField(
                          decoration: _fieldDecoration(
                            context,
                            'Describe your request in detail (type or speak)…',
                          ).copyWith(alignLabelWithHint: true),
                          minLines: 4,
                          maxLines: 8,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          onChanged: (value) =>
                              bloc.add(AddDescriptionHelpEvent(value)),
                        ),
                      ),
                      SizedBox(height: 18.h),
                      Text(
                        'Screenshot',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Attach an image so we can assist you faster.',
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      BlocBuilder<HelpBloc, HelpState>(
                        buildWhen: (previous, current) =>
                            current is! HelpLoadingState &&
                            current is! HelpSuccessState,
                        builder: (context, _) {
                          return _AttachmentSection(
                            imagePath: bloc.selectedImagePath,
                            onPick: () {
                              context.hideKeyboard();
                              AppImagePicker(context, (image) {
                                bloc.add(ClickImageHelpEvent(
                                    imagePath: image.path));
                              });
                            },
                            onRemove: () =>
                                bloc.add(RemoveSelectedImageHelpEvent()),
                          );
                        },
                      ),
                      SizedBox(height: 24.h),
                      SizedBox(
                        width: double.infinity,
                        child: CustomMaterialButton(
                          buttonText: 'Submit request',
                          onPressed: isLoading
                              ? () {}
                              : () {
                                  context.hideKeyboard();
                                  bloc.add(HelpSaveEvent());
                                },
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],
                  ),
                ),
                if (isLoading)
                  Positioned.fill(
                    child: ColoredBox(
                      color: theme.colorScheme.surface.withValues(alpha: 0.65),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: Icon(
            Icons.check_circle_rounded,
            color: theme.colorScheme.primary,
            size: 48,
          ),
          title: const Text('Request sent'),
          content: Text(
            message.isNotEmpty
                ? message
                : 'Your help request has been submitted successfully.',
            textAlign: TextAlign.center,
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: CustomMaterialButton(
                buttonText: 'Done',
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HelpInfoBanner extends StatelessWidget {
  final ThemeData theme;

  const _HelpInfoBanner({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.22),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.support_agent_rounded,
                color: theme.colorScheme.primary,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How can we help?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Tell us what went wrong. Our team will review your request and get back to you.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentSection extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _AttachmentSection({
    required this.imagePath,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = imagePath != null;

    if (hasImage) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.file(
                File(imagePath!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPick,
                  icon: const Icon(Icons.photo_library_outlined, size: 20),
                  label: const Text('Change image'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.65),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              IconButton.filledTonal(
                onPressed: onRemove,
                tooltip: 'Remove image',
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: theme.colorScheme.error,
                ),
                style: IconButton.styleFrom(
                  backgroundColor:
                      theme.colorScheme.errorContainer.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.5),
          style: BorderStyle.solid,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPick,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 16.w),
          child: Column(
            children: [
              Container(
                width: 52.w,
                height: 52.w,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 28.sp,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Tap to add screenshot',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'PNG or JPG from gallery or camera',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
