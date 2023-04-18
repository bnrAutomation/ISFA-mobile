import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_densfa/module/campaign_module/view/campaign_view.dart';
import 'package:i_densfa/module/dynamic_questions_module/views/dynamic_questions_view.dart';
import 'package:i_densfa/module/inventory_module/modify_product_quantity/bloc/modify_quantity_bloc.dart';
import 'package:i_densfa/module/inventory_module/modify_product_quantity/repository.dart';
import 'package:i_densfa/module/promoter_module/feedback/feedback_view.dart';
import 'package:i_densfa/module/promoter_module/models/promoter_store_detail_model.dart';

import 'package:i_densfa/module/ui/custom_image_button.dart';
import 'package:i_densfa/module/ui/custom_material_button.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/module/ui/app_pop_view.dart';
import '../inventory_module/modify_product_quantity/view.dart';
import 'bloc/promoter_bloc.dart';

class PromoterView extends StatelessWidget {
  const PromoterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0XFF003D5B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Promoter",
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: Colors.white),
        ),
      ),
      body: Column(children: [
        const SizedBox(height: 5),
        Card(
          color: const Color(0xffBFD1DF),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          elevation: 5,
          child: Column(
            children: [
              Container(
                  height: 0.2.sh,
                  decoration: const BoxDecoration(
                    color: Color(0xffBFD1DF),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  alignment: Alignment.center,
                  child: Image.network(
                    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQpo1BfypXH0JcsdyjZI_w3rK-T4utQ_RAVjBx5ELNHpuN9fUdPBNuwjLjSxaVfCpXhsRQ&usqp=CAU",
                    fit: BoxFit.fitWidth,
                  )),
              _storeDetailsView()
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: BlocBuilder<PromoterBloc, PromoterState>(
            builder: (context, state) {
              final PromoterBloc bloc = context.read();
              if (!bloc.isMarkedIn) {
                return const SizedBox();
              }
              return Row(
                children: [
                  Expanded(
                    child: CustomImageButton(
                      buttonText: "Sale Log",
                      onPressed: () => _saleLogTapped(context),
                      image: SvgPicture.asset(
                        ImageConstants.navigator,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: CustomImageButton(
                      buttonText: "Inventory",
                      onPressed: () {
                        final promoterBloc = context.read<PromoterBloc>();
                        final storeId = promoterBloc.storeDetail?.storeId;
                        if (storeId == null) {
                          promoterBloc.add(
                              PromoterShowToastMessageEvent("Store not found"));
                          return;
                        }
                        context.pushNamed(AppPaths.inventory,
                            extra: promoterBloc);
                      },
                      image: SvgPicture.asset(ImageConstants.box),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: CustomImageButton(
                      buttonText: "Start\nCampaign",
                      onPressed: () =>
                          context.read<PromoterBloc>().add(GotoCompaignEvent()),
                      image: SvgPicture.asset(ImageConstants.campaign),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: CustomImageButton(
                      buttonText: "Feedback",
                      onPressed: () {
                        final storeDetail =
                            context.read<PromoterBloc>().storeDetail;
                        if (storeDetail != null) {
                          AppPopup.showAppBottomSheet(
                            context: context,
                            child: FeedbackView(
                                storeName:
                                    "${storeDetail.name} ${storeDetail.storeBranch}"),
                          );
                        }
                      },
                      image: SvgPicture.asset(ImageConstants.feedback),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ]),
    );
  }

  BlocConsumer<PromoterBloc, PromoterState> _storeDetailsView() {
    return BlocConsumer<PromoterBloc, PromoterState>(
      listenWhen: (previous, current) =>
          current is PromoterToastMessageState ||
          current is CompaignsLoadedPromoterState,
      listener: (context, state) {
        if (state is PromoterToastMessageState) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
          ));
        } else if (state is CompaignsLoadedPromoterState) {
          final PromoterBloc bloc = context.read();
          AppPopup.showAppBottomSheet(
              context: context,
              child: _openCampaignSheet(context, bloc.storeDetail!));
        }
      },
      builder: (context, state) {
        final bloc = context.read<PromoterBloc>();
        return Container(
          padding: const EdgeInsets.all(15),
          decoration: const BoxDecoration(
            color: Color(0xffBFD1DF),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      bloc.storeDetail?.name ?? "",
                      style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (bloc.storeDetail?.latitude != null)
                    IconButton(
                        onPressed: () => bloc.add(GoToMapPromoterEvent()),
                        icon: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                        ))
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(CupertinoIcons.person, size: 12),
                  const SizedBox(width: 8),
                  Text(bloc.storeDetail?.storeBranch ?? "",
                      style: GoogleFonts.inter(fontSize: 10))
                ],
              ),
              const SizedBox(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(CupertinoIcons.placemark, size: 12),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(bloc.storeDetail?.address ?? "",
                        maxLines: 3,
                        overflow: TextOverflow.fade,
                        style: GoogleFonts.inter(fontSize: 10)),
                  )
                ],
              ),
              const SizedBox(height: 8),
              if (!bloc.isMarkedIn)
                CustomMaterialButton(
                    buttonText: state is PromoterStoreDetailLoadingState
                        ? "Loading..."
                        : bloc.storeDetail == null
                            ? "No Store"
                            : "Check-In Store",
                    gradient: const LinearGradient(colors: <Color>[
                      Color(0XFF003D5B),
                      Color(0XFF278BBC),
                    ]),
                    onPressed: () {
                      if (state is! PromoterStoreDetailLoadingState ||
                          bloc.storeDetail != null) {
                        bloc.add(PromoterCheckInStoreEvent());
                      }
                    }),
              const SizedBox(height: 8),
              if (bloc.isMarkedIn)
                CustomMaterialButton(
                    gradient: const LinearGradient(
                      colors: <Color>[Color(0XFFC92434), Color(0XFF003D5B)],
                    ),
                    buttonText: state is PromoterStoreDetailLoadingState ||
                            bloc.storeDetail == null
                        ? "Loading..."
                        : "Check-Out Store",
                    onPressed: () {
                      if (state is! PromoterStoreDetailLoadingState ||
                          bloc.storeDetail != null) {
                        bloc.add(PromoterCheckOutStoreEvent());
                      }
                    })
            ],
          ),
        );
      },
    );
  }

  Widget _openCampaignSheet(
      BuildContext context, PromoterStoreDetailModel storeDetail) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            "Campaign",
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: CampaignView(
              storeID: storeDetail.storeId,
            ),
          ),
          // Expanded(
          //   child: ListView.separated(
          //       itemCount: items.length,
          //       separatorBuilder: (context, index) => const SizedBox(height: 5),
          //       itemBuilder: (context, index) => InkWell(
          //           onTap: () {
          //             // Navigator.pop(context);
          //             // AppPopup.showAppBottomSheet(
          //             //   context: context,
          //             //   child: salesLogForm(textTheme),
          //             // );
          //           },
          //           child: CampaignListItem(item: items[index]))),
          // ),
        ],
      ),
    );
  }

  Widget salesLogForm(TextTheme textTheme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sales Log Form",
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const DynamicQuestionsView(questions: []),
              ],
            ),
          ),
          Container(
            color: const Color(0xff278bbc).withOpacity(0.2),
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Customer Details",
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const DynamicQuestionsView(questions: []),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(15),
            child: DynamicQuestionsView(questions: []),
          ),
          CustomMaterialButton(buttonText: "Submit", onPressed: () {}),
        ],
      ),
    );
  }

  void _saleLogTapped(BuildContext context) {
    final promoterBloc = context.read<PromoterBloc>();
    final storeId = promoterBloc.storeDetail?.storeId;
    if (storeId == null) {
      promoterBloc.add(PromoterShowToastMessageEvent("Store not found"));
      return;
    }
    AppPopup.showAppBottomSheet(
      context: context,
      child: BlocProvider(
        create: (context) =>
            ModifyQuantityBloc(ModifyProductsRepository(storeId), true)
              ..add(GetCategoriesListEvent()),
        child: ModifyProductQuantityPopup(
          title: "Add Sale Log",
          onPop: () {},
        ),
      ),
    );
  }
}
