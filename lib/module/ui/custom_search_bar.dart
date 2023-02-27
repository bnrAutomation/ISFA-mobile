import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSearchBar extends StatelessWidget {
  final Color colors;
  final String hintText;
  final Color iconColor;
  const CustomSearchBar(
      {super.key,
      required this.hintText,
      this.colors = const Color(0xff003D5B),
      this.iconColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: colors,
      child: TextField(
        style: TextStyle(color: iconColor),
        decoration: InputDecoration(
            prefixIcon: Icon(
              CupertinoIcons.search,
              color: iconColor,
              size: 16,
            ),
            hintText: hintText,
            hintStyle: GoogleFonts.inter(color: iconColor, fontSize: 10),
            iconColor: Colors.white,
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 1, color: iconColor),
                borderRadius: BorderRadius.circular(40)),
            enabledBorder: OutlineInputBorder(
                // gapPadding: 20,
                borderSide: BorderSide(width: 1, color: iconColor),
                borderRadius: BorderRadius.circular(40)),
            border: OutlineInputBorder(
                borderSide: BorderSide(width: 1, color: iconColor),
                borderRadius: BorderRadius.circular(40))),
      ),
    );
  }
}
