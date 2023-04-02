import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSearchBar extends StatelessWidget {
  final String hintText;
  final Color color;
  final void Function(String)? onChange;
  const CustomSearchBar(
      {super.key,
      required this.hintText,
      required this.onChange,
      this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(color: color),
      textInputAction: TextInputAction.search,
      onChanged: onChange,
      decoration: InputDecoration(
          prefixIcon: Icon(
            CupertinoIcons.search,
            color: color,
            size: 16,
          ),
          hintText: hintText,
          hintStyle: GoogleFonts.inter(color: color, fontSize: 10),
          contentPadding: const EdgeInsets.all(0),
          iconColor: Colors.white,
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: color),
              borderRadius: BorderRadius.circular(40)),
          enabledBorder: OutlineInputBorder(
              // gapPadding: 20,
              borderSide: BorderSide(width: 1, color: color),
              borderRadius: BorderRadius.circular(40)),
          border: OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: color),
              borderRadius: BorderRadius.circular(40))),
    );
  }
}
