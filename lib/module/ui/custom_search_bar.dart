import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final Color colors;
  final String hintText;
  final Color iconColor;
  final Function onChange;
  const CustomSearchBar(
      {super.key,
      required this.hintText,
      required this.onChange,
      this.colors = const Color(0xff003D5B),
      this.iconColor = Colors.amber});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: TextFormField(
        style: Theme.of(context).textTheme.labelSmall,
        onChanged: (value) => onChange(value),
        decoration: InputDecoration(
            prefixIcon: const Icon(
              CupertinoIcons.search,
              color: Colors.black,
              size: 18,
            ),
            hintText: hintText,
            hintStyle: Theme.of(context).textTheme.labelSmall,
            iconColor: Colors.white,
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 1, color: iconColor),
                borderRadius: BorderRadius.circular(5)),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 1, color: iconColor),
                borderRadius: BorderRadius.circular(5)),
            border: OutlineInputBorder(
                borderSide: BorderSide(width: 1, color: iconColor),
                borderRadius: BorderRadius.circular(5))),
      ),
    );
  }
}
