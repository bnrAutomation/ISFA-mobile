import 'package:camera/camera.dart';
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
import 'package:i_densfa/module/inventory_module/modify_product_quantity/inventory_repository.dart';
import 'package:i_densfa/module/promoter_module/feedback/feedback_view.dart';
import 'package:i_densfa/module/promoter_module/models/promoter_store_detail_model.dart';

import 'package:i_densfa/module/ui/custom_image_button.dart';
import 'package:i_densfa/module/ui/custom_material_button.dart';
import 'package:i_densfa/module/ui/dialog_helper.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/module/ui/app_pop_view.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';
import '../inventory_module/modify_product_quantity/view.dart';
import 'bloc/promoter_bloc.dart';

class PromoterView extends StatelessWidget {
  final String name;
  const PromoterView({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PromoterBloc>();
    return Scaffold(
        appBar: AppBar(title: Text(name)),
        body: BlocConsumer<PromoterBloc, PromoterState>(
          // listenWhen: (previous, current) =>
          //     current is PromoterToastMessageState ||
          //     current is CompaignsLoadedPromoterState,
          listener: (context, state) async {
            if (state is PromoterToastMessageState) {
              context.showSnackBarMessage(state.message);
            } else if (state is CompaignsLoadedPromoterState) {
              final PromoterBloc bloc = context.read();
              AppPopup.showAppBottomSheet(
                  context: context,
                  child: _openCampaignSheet(context, bloc.storeDetail!));
            }
            if (state is TakeMarkinImage) {
              String? path = await context.pushNamed(AppPaths.appcamera,
                  pathParameters: {'from': "markinout"});
              if (path == null && path!.isEmpty) {
                context.showSnackBarMessage('Please click image');
              } else {
                bloc.add(MarkingWithImage(XFile(path), state.loc));
              }
            }
            if (state is TakeMarkOutImage) {
              String? path = await context.pushNamed(AppPaths.appcamera,
                  pathParameters: {'from': "markinout"});
              if (path == null && path!.isEmpty) {
                context.showSnackBarMessage('Please click image');
              } else {
                bloc.add(MarkOutWithImage(XFile(path), state.loc));
              }
            }
            if (state is PromoterPOPMessageState) {
              DialogHelper.showErrorMessage(context, "Message", state.message,
                  onOkayClick: () => {
                        Navigator.pop(context),
                      });
            }

            if (state is ShowSalesMessage) {
              DialogHelper.showErrorMessage(context, "Message", state.message,
                  onOkayClick: () => {
                        context.pop(),
                        bloc.add(MoveToFeedBackEvent()),
                      });
            }

            if (state is MoveToFeedBackState) {
              final storeDetail = context.read<PromoterBloc>().storeDetail;
              if (storeDetail != null) {
                AppPopup.showAppBottomSheet(
                  context: context,
                  child: FeedbackView(storeName: storeDetail.name),
                ).then((value) => {
                      if (value)
                        {
                          if (state is! PromoterStoreDetailLoadingState ||
                              bloc.storeDetail != null)
                            {bloc.add(PromoterCheckOutStoreEvent())}
                        }
                    });
              }
            }
          },
          builder: (context, state) {
            return bloc.storeDetail == null
                ? Center(
                    child: Text(
                        "Look's like store not assigned yet.".toUpperCase()),
                  )
                : Column(children: [
                    const SizedBox(height: 5),
                    Card(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.2),
                        // color: const Color(0xffBFD1DF),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        elevation: 0,
                        child: Column(
                          children: [
                            Container(
                                height: 0.2.sh,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20)),
                                ),
                                alignment: Alignment.center,
                                child: Image.network(
                                  (bloc.storeDetail?.storeImage1 ?? "")
                                          .urlValid()
                                      ? (bloc.storeDetail?.storeImage1 ?? "")
                                      : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQpo1BfypXH0JcsdyjZI_w3rK-T4utQ_RAVjBx5ELNHpuN9fUdPBNuwjLjSxaVfCpXhsRQ&usqp=CAU",
                                  fit: BoxFit.cover,
                                  width: 1.sw,
                                  height: 1.sh,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.network(
                                      'https://media.istockphoto.com/id/912819604/vector/storefront-flat-design-e-commerce-icon.jpg?s=612x612&w=0&k=20&c=_x_QQJKHw_B9Z2HcbA2d1FH1U1JVaErOAp2ywgmmoTI=',
                                      fit: BoxFit.fitWidth,
                                    );
                                  },
                                )),
                            _storeDetailsView(bloc)
                          ],
                        )),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: BlocBuilder<PromoterBloc, PromoterState>(
                        builder: (context, state) {
                          if (!context.read<PromoterBloc>().isMarkedIn) {
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
                                    final promoterBloc =
                                        context.read<PromoterBloc>();
                                    final storeId =
                                        promoterBloc.storeDetail?.storeId;
                                    if (storeId == null) {
                                      promoterBloc.add(
                                          PromoterShowToastMessageEvent(
                                              "Store not found"));
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
                                  onPressed: () => context
                                      .read<PromoterBloc>()
                                      .add(GotoCompaignEvent()),
                                  image:
                                      SvgPicture.asset(ImageConstants.campaign),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: CustomImageButton(
                                  buttonText: "Feedback",
                                  onPressed: () {
                                    final storeDetail = context
                                        .read<PromoterBloc>()
                                        .storeDetail;
                                    if (storeDetail != null) {
                                      AppPopup.showAppBottomSheet(
                                        context: context,
                                        child: FeedbackView(
                                            storeName: storeDetail.name),
                                      );
                                    }
                                  },
                                  image:
                                      SvgPicture.asset(ImageConstants.feedback),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ]);
          },
        ));
  }

  Widget _storeDetailsView(PromoterBloc bloc) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(
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
              Text(bloc.storeDetail?.storeCode ?? "",
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
          if ( (AppStorage().userDetail?.configuration.requiredDoubleMarkIn??false) && bloc.isAlreadyMarkin)
            const Center(child: Text("Visit Complete"))
          else
          
           if (bloc.isMarkedIn)
            BlocConsumer<PromoterBloc, PromoterState>(
              listener: (context, state) async {},
              builder: (context, state) {
                return CustomMaterialButton(
                    textColor: Colors.black,
                    gradient: const LinearGradient(
                      colors: <Color>[Color(0XFFC92434), ColorConstants.amber],
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
                    });
              },
            )
          else
            BlocConsumer<PromoterBloc, PromoterState>(
              listener: (context, state) {},
              builder: (context, state) {
                return CustomMaterialButton(
                    textColor: Colors.black,
                    buttonText: state is PromoterStoreDetailLoadingState
                        ? "Loading..."
                        : bloc.storeDetail == null
                            ? "No Store"
                            : "Check-In Store",
                    gradient: const LinearGradient(colors: <Color>[
                      ColorConstants.amber,
                      ColorConstants.amberFade,
                    ]),
                    onPressed: () {
                      if (state is! PromoterStoreDetailLoadingState ||
                          bloc.storeDetail != null) {
                        bloc.add(PromoterCheckInStoreEvent());
                      }
                    });
              },
            ),
        ],
      ),
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
                mechanicsContact: "",
                mechanicsName: "",
                  storeId: storeDetail.storeId,
                  from: AppPaths.promoter,
                  storeLat: storeDetail.latitude,
                  storeLong: storeDetail.longitude)),
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
                DynamicQuestionsView(
                  questions: const [],
                  name: 'invantory',
                ),
              ],
            ),
          ),
          Container(
            color: const Color(0xff278bbc).withValues(alpha: 0.2),
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Customer Details",
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                DynamicQuestionsView(
                  questions: const [],
                  name: "invantory",
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: DynamicQuestionsView(
              questions: const [],
              name: 'invantory',
            ),
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
