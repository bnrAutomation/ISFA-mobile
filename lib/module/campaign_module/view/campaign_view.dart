import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_densfa/module/campaign_module/bloc/campaign_bloc.dart';
import 'package:i_densfa/module/campaign_module/view/campain_list.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';

class CampaignView extends StatelessWidget {
  final int storeId;
  const CampaignView({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) =>
            CampaignBloc(storeId)..add(GetStoreCampaignsEvent()),
        child: BlocBuilder<CampaignBloc, CampaignState>(
          builder: (context, state) {
            final CampaignBloc bloc = context.read();
            if (state is CampaignListLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }
            if (bloc.storeCampaigns.isEmpty) {
              return Center(
                  child: Text(
                "No Campaign",
                style: Theme.of(context).textTheme.labelLarge,
              ));
            }
            return ListView.separated(
                itemCount: bloc.storeCampaigns.length,
                separatorBuilder: (context, index) => const SizedBox(height: 5),
                itemBuilder: (context, index) => InkWell(
                    onTap: () {
                      final campaign = bloc.storeCampaigns[index];
                      bloc.selectedCampaign = campaign;
                      bloc.add(GetCampaignSections(campaign.uuid));
                      context.push(AppPaths.selectedCampaignView, extra: bloc);
                    },
                    child: CampaignListItem(item: bloc.storeCampaigns[index])));
          },
        ),
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

class SelectedCampaignView extends StatelessWidget {
  const SelectedCampaignView({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xffBFD1DF),
      appBar: AppBar(title: const Text("Campaign")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: BlocConsumer<CampaignBloc, CampaignState>(
          listener: (context, state) {
            if (state is SnackbarMessageCampaignState) {
              context.showSnackBarMessage(state.message);
            }
          },
          builder: (context, state) {
            final CampaignBloc bloc = context.read();
            final selectedCamp = bloc.selectedCampaign;
            final campaignData = bloc.savedCampaignDetails;
            return Column(
              children: [
                Card(
                  child: ListTile(
                    leading: CircleAvatar(radius: 25.w),
                    title: Text(AppStorage().userDetail?.username ?? ""),
                    subtitle: Text(AppStorage().userDetail?.reportTo ?? ""),
                  ),
                ),
                if (selectedCamp != null)
                  Card(
                    child: ListTile(
                      textColor: theme.primaryColor,
                      horizontalTitleGap: 5,
                      leading: Icon(
                        Icons.calendar_month_outlined,
                        color: theme.primaryColor,
                      ),
                      title: Text(selectedCamp.name),
                      subtitle: Text(
                          "From ${selectedCamp.startDate.toStringFormat('dd MMM yy')} To ${selectedCamp.endDate.toStringFormat('dd MMM yy')}"),
                    ),
                  ),
                if (!bloc.storeId.isNegative &&
                    selectedCamp != null &&
                    selectedCamp.isNagative() == false)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: FilledButton(
                        onPressed: () => context
                            .pushNamed(AppPaths.campaignQuestion, extra: bloc),
                        style: TextButton.styleFrom(
                          elevation: 2,
                          alignment: Alignment.center,
                          backgroundColor: theme.primaryColor,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40.w),
                          child: Text('Enter Questionnaire',
                              style: GoogleFonts.inter(
                                  fontSize: 14.sp, color: Colors.white)),
                        )),
                  ),
                campaignData != null
                    ? Card(
                        child: Padding(
                          padding: EdgeInsets.all(12.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    campaignData.targetedStores.toString(),
                                    style: TextStyle(
                                        color: theme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.sp),
                                  ),
                                  SizedBox(width: 10.w),
                                  const Text("Store Targeted"),
                                ],
                              ),
                              SizedBox(height: 15.h),
                              Row(
                                children: [
                                  Text(
                                    campaignData.totalResponse.toString(),
                                    style: TextStyle(
                                        color: theme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.sp),
                                  ),
                                  SizedBox(width: 10.w),
                                  const Text("Total Responses"),
                                ],
                              ),
                              SizedBox(height: 15.h),
                              Row(
                                children: [
                                  Text(
                                    campaignData.includedStores.toString(),
                                    style: TextStyle(
                                        color: theme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.sp),
                                  ),
                                  SizedBox(width: 10.w),
                                  const Text("Store Included in Responses"),
                                ],
                              ),
                              SizedBox(height: 6.h),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20.w),
                                child: LinearProgressIndicator(
                                  backgroundColor: Colors.grey.shade400,
                                  color: const Color(0xffDB4C5B),
                                  minHeight: 40,
                                  value: max(0.05, campaignData.totalResponse) /
                                      max(1, campaignData.targetedStores),
                                ),
                              ),
                              SizedBox(height: 6.h),
                            ],
                          ),
                        ),
                      )
                    : const Center(child: Text("Analytics is not available.")),
              ],
            );
          },
        ),
      ),
    );
  }
}
