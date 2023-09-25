import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/module/ui/custom_material_button.dart';
import 'package:image_picker/image_picker.dart';

class CheckInView extends StatelessWidget {
  const CheckInView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Check-In")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 1.sw,
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              "Please ensure you are at the store while making the attendence and do not forget to sync it.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: Border.all(
                      width: 0.5.sp, color: Theme.of(context).primaryColor)),
              width: 1.sw,
              height: 0.5.sw,
              child: Center(
                  child:

                      // filePath.value.isEmpty
                      //     ?
                      Text(
                'Include the surroundings and avoid glare.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).primaryColor),
              )
                  // : Image.file(File(
                  //     .filePath.value)),
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              "Take selfie at the store",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          CustomMaterialButton(
              buttonText: "Take Selfie ",
              onPressed: () async {
                final image = await ImagePicker().pickImage(
                    source: kReleaseMode
                        ? ImageSource.camera
                        : ImageSource.gallery);
                if (context.mounted) {
                  context.pop(image);
                }
              }),
          const SizedBox(height: 10)
        ],
      ),
    );
  }
}
