import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddFloatingActionButton extends StatelessWidget {
  final void Function() onTap;
  const AddFloatingActionButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      onPressed: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [
              Theme.of(context).primaryColor,
              const Color(0xff278BBC)
            ])),
        child: SizedBox(
          width: 60,
          height: 60,
          child: Icon(
            Icons.add,
            size: 30.w,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class DropDownWithOptions extends StatelessWidget {
  final List<String> options;
  final String hint;
  final void Function(String?)? valChanged;
  final String? selectedVal;
  const DropDownWithOptions({
    super.key,
    required this.options,
    required this.hint,
    required this.valChanged,
    this.selectedVal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
        value: selectedVal,
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: valChanged,
        hint: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            hint,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      )),
    );
  }
}
