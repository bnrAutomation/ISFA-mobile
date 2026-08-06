import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/routes.dart';
import 'package:image_picker/image_picker.dart';

class AppImagePicker {
  final void Function(XFile) onSelectedImage;
  final BuildContext context;

  AppImagePicker(this.context, this.onSelectedImage) {
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: const Text("Select Image"),
            actions: [
              CupertinoActionSheetAction(
                  onPressed: () async {
                    context.pop();
                     String? image = await context.pushNamed(AppPaths.appcamera, pathParameters: {'from': "randowm"});
                    // final image = await ImagePicker()
                    //     .pickImage(source: ImageSource.camera);
                    if (image != null) {
                      onSelectedImage(XFile(image));
                    }
                  },
                  isDefaultAction: true,
                  child: const Text("Camera")),
              CupertinoActionSheetAction(
                  onPressed: () async {
                    context.pop();
                    FilePickerResult? image =
                        await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowMultiple: false,
                      allowedExtensions: ['jpg','jpeg', 'png'],
                    );

                    if (image != null) {
                      onSelectedImage(XFile(image.files.first.path ?? ""));
                    }
                  },
                  child: const Text("Gallery"))
            ],
            cancelButton: CupertinoActionSheetAction(
                onPressed: () => context.pop(),
                isDestructiveAction: true,
                child: const Text("Cancel")),
          );
        });
  }
}
