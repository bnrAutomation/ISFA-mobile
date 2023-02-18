import 'package:flutter/material.dart';

class AppTabViewController extends StatelessWidget {
  final List<String> titles;
  final List<Widget> children;
  final Color backgroundColor;
  final Color textColor;
  final Color indicatorColors;

  const AppTabViewController({
    super.key,
    required this.titles,
    required this.children,
    this.backgroundColor = const Color(0xffFFBF00),
    this.textColor = Colors.black,
    this.indicatorColors = Colors.black,
  }) : assert(children.length == titles.length);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: titles.length,
      child: Column(
        children: [
          ColoredBox(
            color: backgroundColor,
            child: TabBar(
              labelColor: textColor,
              indicatorColor: indicatorColors,
              tabs: titles.map((e) => Tab(text: e)).toList(),
            ),
          ),
          Expanded(child: TabBarView(children: children))
        ],
      ),
    );
  }
}
