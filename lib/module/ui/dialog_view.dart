import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DialogView extends StatelessWidget {
  final VoidCallback? onDelete;
  final String? title;
  final String? description;
  final String? okayButtonText;
  const DialogView(
      {super.key,
      required this.onDelete,
      this.title,
      this.description,
      this.okayButtonText});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 0.7.sw,
                height: 10,
              ),
              // SvgPicture.asset(imageConstants.attention, width: 40, height: 40),
              const SizedBox(
                height: 10,
              ),
              Text(title ?? "Are you sure you want to delete?",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                    description ??
                        "It will not longer available to view in your panel after deletion.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
              const SizedBox(
                height: 20,
              ),
              Wrap(children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.only(
                        top: 5, bottom: 5, left: 15, right: 15),
                    backgroundColor: Colors.white, //background color of button
                    side: const BorderSide(
                        width: 1,
                        color: Color(
                            0x80000000)), //border width and color//elevation of button
                    shape: RoundedRectangleBorder(
                        //to set border radius to button
                        borderRadius: BorderRadius.circular(
                            5)), //content padding inside button
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontSize: 13),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.only(
                        top: 5, bottom: 5, left: 15, right: 15),
                    backgroundColor:
                        const Color(0xFFFFBF00), //background color of button
                    side: const BorderSide(
                        width: 1,
                        color: Color(
                            0xFFFFBF00)), //border width and color//elevation of button
                    shape: RoundedRectangleBorder(
                        //to set border radius to button
                        borderRadius: BorderRadius.circular(
                            5)), //content padding inside button
                  ),
                  onPressed: onDelete,
                  child: Text(
                    okayButtonText ?? "Delete",
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontSize: 13),
                  ),
                ),
              ]),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
