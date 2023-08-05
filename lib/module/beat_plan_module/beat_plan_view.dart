import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_densfa/module/beatplan_stores_module/beatplan_store_list_view.dart';
import 'package:i_densfa/utility/app_constants.dart';

class BeatPlanView extends StatelessWidget {
  const BeatPlanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const BeatPlanSearchBar(),
          Expanded(
            child: AppTabbarController(
              titles: const ['MI', 'DAP'],
              children: [
                ListView.separated(
                    itemCount: 2,
                    padding: const EdgeInsets.all(15),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 20),
                    itemBuilder: (context, index) => const BeatPlanMI()),
                const Center(child: Text("DAP"))
              ],
            ),
          )
        ],
      ),
    );
  }
}

class BeatPlanMI extends StatelessWidget {
  const BeatPlanMI({super.key});

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
                    child: Image.network(
                        'https://media.istockphoto.com/id/912819604/vector/storefront-flat-design-e-commerce-icon.jpg?s=612x612&w=0&k=20&c=_x_QQJKHw_B9Z2HcbA2d1FH1U1JVaErOAp2ywgmmoTI=',
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
                            backgroundColor: Theme.of(context).primaryColor,
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
        const Padding(
          padding: EdgeInsets.only(right: 20),
          child: NoteClip(text: 'MARK IN', backColor: Color(0xff7B000C)),
        ),
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
            color: ColorConstants.amber,
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

class BeatPlanSearchBar extends StatelessWidget {
  const BeatPlanSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Theme.of(context).primaryColor,
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
