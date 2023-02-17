import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LeaderboardView extends StatelessWidget {
  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const LeaderboardSearchBar(),
          Expanded(
            child: AppTabbarController(
              titles: const ['MI', 'DAP'],
              children: [
                ListView.separated(
                    itemCount: 2,
                    padding: const EdgeInsets.all(15),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 20),
                    itemBuilder: (context, index) => const LeaderboardMI()),
                const Center(child: Text("DAP"))
              ],
            ),
          )
        ],
      ),
    );
  }
}

class LeaderboardMI extends StatelessWidget {
  const LeaderboardMI({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    color: Colors.grey.shade100,
                    alignment: Alignment.center,
                    child: Image.network('https://picsum.photos/290/160',
                        fit: BoxFit.fitWidth)),
                Container(
                  color: const Color(0xffBFD1DF),
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Neeraj Pan Bhandar",
                        style: GoogleFonts.inter(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(CupertinoIcons.person, size: 12),
                          const SizedBox(width: 8),
                          Text('Assigned to: John Doe',
                              style: GoogleFonts.inter(fontSize: 10))
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(CupertinoIcons.placemark, size: 12),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                                '9, 6 Number Bus stop, No 6 Locality, Shiv Nagar, Bhopal, Madhya Pradesh 462011, India, Bhopal, MP',
                                maxLines: 3,
                                overflow: TextOverflow.fade,
                                style: GoogleFonts.inter(fontSize: 10)),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            alignment: Alignment.center,
                            backgroundColor: const Color(0xff003D5B),
                          ),
                          child: Center(
                            child: Text('Assign',
                                style: GoogleFonts.inter(
                                    fontSize: 10, color: Colors.white)),
                          ))
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 24),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(5)),
              color: Color(0xffC92434)),
          child: Text(
            "MARK IN",
            style: GoogleFonts.inter(
                fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        )
      ],
    );
  }
}

class AppTabbarController extends StatelessWidget {
  final List<String> titles;
  final List<Widget> children;
  const AppTabbarController({
    super.key,
    required this.titles,
    required this.children,
  }) : assert(children.length == titles.length);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: titles.length,
      child: Column(
        children: [
          ColoredBox(
            color: const Color(0xffFFBF00),
            child: TabBar(
              labelColor: Colors.black,
              indicatorColor: Colors.black,
              tabs: titles.map((e) => Tab(text: e)).toList(),
            ),
          ),
          Expanded(child: TabBarView(children: children))
        ],
      ),
    );
  }
}

class LeaderboardSearchBar extends StatelessWidget {
  const LeaderboardSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: const Color(0xff003D5B),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
            prefixIcon: const Icon(
              CupertinoIcons.search,
              color: Colors.white,
              size: 16,
            ),
            hintText: "Search with owner, Contact Number",
            hintStyle: GoogleFonts.inter(color: Colors.white70, fontSize: 10),
            iconColor: Colors.white,
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(width: 1, color: Colors.white),
                borderRadius: BorderRadius.circular(40)),
            enabledBorder: OutlineInputBorder(
                gapPadding: 30,
                borderSide: const BorderSide(width: 1, color: Colors.white),
                borderRadius: BorderRadius.circular(40)),
            border: OutlineInputBorder(
                borderSide: const BorderSide(width: 1, color: Colors.white),
                borderRadius: BorderRadius.circular(40))),
      ),
    );
  }
}
