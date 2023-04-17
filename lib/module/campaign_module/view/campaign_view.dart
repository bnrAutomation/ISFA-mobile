import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_densfa/module/campaign_module/bloc/campaign_bloc.dart';
import 'package:i_densfa/module/campaign_module/campaign_repository.dart';
import 'package:i_densfa/module/campaign_module/view/campain_list.dart';
import 'package:i_densfa/routes.dart';

class CampaignView extends StatelessWidget {
  final int storeID;
  const CampaignView({super.key, required this.storeID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) {
          return CampaignBloc(CampaignRepository(storeID))
            ..add(GetStoreCampaignsEvent());
        },
        child: BlocBuilder<CampaignBloc, CampaignState>(
          builder: (context, state) {
            final CampaignBloc bloc = context.read();
            return Column(
              children: [
                Expanded(
                    child: ListView.separated(
                        itemCount: bloc.storeCampaigns.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 5),
                        itemBuilder: (context, index) => InkWell(
                            onTap: () {
                              bloc.add(GetQuestionsForCampaign(
                                  bloc.storeCampaigns[index].campaignId));
                              context.pushNamed(AppPaths.campaignQuestion,
                                  extra: bloc);
                            },
                            child: CampaignListItem(
                                item: bloc.storeCampaigns[index]))))
              ],
            );
          },
        ),
      ),
    );
  }
}

// class CampaignView extends StatelessWidget {
//   final int storeID;
//   const CampaignView({super.key, required this.storeID});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocProvider(
//         create: (context) {
//           return CampaignBloc(CampaignRepository(storeID))
//             ..add(GetStoreCampaignsEvent());
//         },
//         child: BlocBuilder<CampaignBloc, CampaignState>(
//           builder: (context, state) {
//             final CampaignBloc bloc = context.read();
//             // final now = DateTime.now();
//             // final activeCamps = bloc.storeCampaigns
//             //     .where((element) =>
//             //         element.startDate.isBefore(now) &&
//             //         element.endDate.isAfter(now))
//             //     .toList();
//             // final other = bloc.storeCampaigns
//             //     .where((element) =>
//             //         element.endDate.isBefore(now) ||
//             //         element.startDate.isAfter(now))
//             //     .toList();
//             return Column(
//               children: [
//                 const CampaignSearchBar(),
//                 Expanded(
//                   child: state is CampaignListLoadingState
//                       ? const Center(child: CircularProgressIndicator())
//                       : AppTabViewController(
//                           backgroundColor: Colors.transparent,
//                           titles: const ['ACTIVE', 'OTHER'],
//                           children: [
//                             ListView.separated(
//                                 itemCount: activeCamps.length,
//                                 padding: const EdgeInsets.all(5),
//                                 separatorBuilder: (context, index) =>
//                                     const SizedBox(height: 5),
//                                 itemBuilder: (context, index) => InkWell(
//                                     onTap: () {

//                                     },
//                                     child: ActiveCampaign(
//                                         detail: activeCamps[index]))),
//                             ListView.separated(
//                                 itemCount: other.length,
//                                 padding: const EdgeInsets.all(5),
//                                 separatorBuilder: (context, index) =>
//                                     const SizedBox(height: 5),
//                                 itemBuilder: (context, index) =>
//                                     ActiveCampaign(detail: other[index])),
//                           ],
//                         ),
//                 )
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

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
