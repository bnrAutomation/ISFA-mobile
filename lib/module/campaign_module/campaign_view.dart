import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_densfa/module/campaign_module/campaign_view/active_campaign_view.dart';
import 'package:i_densfa/module/ui/app_tabview_view.dart';

class CampaignView extends StatelessWidget {
  const CampaignView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CampaignSearchBar(),
          Expanded(
            child: AppTabViewController(
              backgroundColor: Colors.transparent,
              titles: const ['ACTIVE', 'OTHER'],
              children: [
                ListView.separated(
                    itemCount: 3,
                    padding: const EdgeInsets.all(5),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 5),
                    itemBuilder: (context, index) => const ActiveCampaign()),
                ListView.separated(
                    itemCount: 5,
                    padding: const EdgeInsets.all(5),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 5),
                    itemBuilder: (context, index) => const ActiveCampaign()),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class CampaignSearchBar extends StatelessWidget {
  const CampaignSearchBar({super.key});

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
            hintText: "Search by campaign name.",
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
