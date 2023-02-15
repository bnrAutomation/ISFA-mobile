import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:i_densfa/module/tabber_module/tabber/tabber_bloc.dart';

class TabberView extends StatelessWidget {
  const TabberView({super.key});
  static const TextStyle optionStyle =
      TextStyle(color: Colors.black, fontWeight: FontWeight.w600);

  static const List<Widget> widgetOptions = <Widget>[
    Text(
      'My Schedule',
      style: optionStyle,
    ),
    Text(
      'Learner',
      style: optionStyle,
    ),
    Text(
      'Leaderboard',
      style: optionStyle,
    ),
    Text(
      'Campaign',
      style: optionStyle,
    ),
    Text(
      'Analytics',
      style: optionStyle,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TabberBloc(),
      child: BlocBuilder<TabberBloc, TabberState>(
        builder: (context, state) {
          return Scaffold(
            body: Center(
              child: widgetOptions[
                  BlocProvider.of<TabberBloc>(context).selectIndex],
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: const Color(0XFF003D5B),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    color: Colors.white.withOpacity(.1),
                  )
                ],
              ),
              child: SafeArea(
                  child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 2.0, vertical: 8),
                child: GNav(
                  rippleColor: Colors.grey[300]!,
                  hoverColor: Colors.grey[100]!,
                  gap: 6,
                  activeColor: Colors.black,
                  //iconSize: 24,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                  curve: Curves.linear,
                  duration: const Duration(milliseconds: 400),
                  tabBackgroundColor: Colors.grey[100]!,
                  color: Colors.white,
                  tabs: const [
                    GButton(
                      icon: Icons.calendar_month_outlined,
                      text: 'My Schedule',
                    ),
                    GButton(
                      icon: Icons.book_online,
                      text: 'Learner',
                    ),
                    GButton(
                      icon: Icons.leaderboard_outlined,
                      text: 'Leaderboard',
                    ),
                    GButton(
                      icon: Icons.campaign_outlined,
                      text: 'Campaign',
                    ),
                    GButton(
                      icon: Icons.pie_chart_outline,
                      text: 'Analytics',
                    ),
                  ],

                  selectedIndex: context.read<TabberBloc>().selectIndex,
                  onTabChange: (index) {
                    BlocProvider.of<TabberBloc>(context)
                        .add(ChangeTabEvent(index));
                  },
                ),
              )),
            ),
          );
        },
      ),
    );
  }
}
