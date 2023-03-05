import 'package:flutter/cupertino.dart';
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
                    Navigator.pop(context);
                    final image = await ImagePicker()
                        .pickImage(source: ImageSource.camera);
                    if (image != null) {
                      onSelectedImage(image);
                    }
                  },
                  isDefaultAction: true,
                  child: const Text("Camera")),
              CupertinoActionSheetAction(
                  onPressed: () async {
                    Navigator.pop(context);
                    final image = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      onSelectedImage(image);
                    }
                  },
                  child: const Text("Gallery"))
            ],
            cancelButton: CupertinoActionSheetAction(
                onPressed: () => Navigator.pop(context),
                isDestructiveAction: true,
                child: const Text("Cancel")),
          );
        });
  }
}
