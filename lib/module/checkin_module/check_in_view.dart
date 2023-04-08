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
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Check-In",
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: Colors.white),
        ),
      ),
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
                      width: 0.5.sp,
                      color: Theme.of(context).colorScheme.primary)),
              width: 1.sw,
              height: 0.5.sw,
              child: Center(
                  child:

                      // filePath.value.isEmpty
                      //     ?
                      Text(
                'Include the surroundings and avoid glare.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
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
                final image =
                    await ImagePicker().pickImage(source: ImageSource.camera);
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
