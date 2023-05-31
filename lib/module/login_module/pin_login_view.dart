import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/extensions.dart';

class PinLoginView extends StatefulWidget {
  const PinLoginView({super.key});

  @override
  State<PinLoginView> createState() => _PinLoginViewState();
}

class _PinLoginViewState extends State<PinLoginView> {
  final otpTextFieldController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        children: [
          Align(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    ImageConstants.denSfa,
                  ),
                  SizedBox(height: 15.h),
                  Text(
                    'Hi, John Doe!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w700),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    child: Text(
                      'Welcome to the portal! Please enter your login PIN to gain access and explore all the features.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  Text(
                    'Enter Login PIN',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20.h, bottom: 15.h),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6.w)),
                    padding: EdgeInsets.all(5.w),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 120.w,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(4, (index) {
                                if (otpTextFieldController.text.length >
                                    index) {
                                  return const Icon(Icons.circle,
                                      color: Colors.black);
                                } else {
                                  return const Icon(Icons.radio_button_off,
                                      color: Colors.black);
                                }
                              }).toList()),
                        ),
                        TextField(
                          maxLength: 4,
                          controller: otpTextFieldController,
                          autofocus: true,
                          enableInteractiveSelection: false,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          showCursor: false,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            counterText: '',
                          ),
                          style: const TextStyle(color: Colors.transparent),
                          onChanged: (value) {
                            setState(() {});
                            if (value.length == 4) {
                              context.hideKeyboard();
                            }
                          },
                        )
                      ],
                    ),
                  ),
                  MaterialButton(
                      minWidth: double.maxFinite,
                      color: Colors.amber,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7.w)),
                      onPressed: () {},
                      child: Text(
                        'Enter',
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.w400),
                      )),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: TextButton(
                onPressed: () {},
                child: Text(
                  "Login Instead?",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400),
                )),
          )
        ],
      ),
    );
  }
}
