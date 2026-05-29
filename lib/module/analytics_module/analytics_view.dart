import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:i_densfa/module/analytics_module/analytics/analytics_bloc.dart';
import 'package:i_densfa/module/analytics_module/model/analytics_model.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_densfa/utility/app_storage.dart';
//import 'package:lottie/lottie.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:upgrader/upgrader.dart';

import 'analytics_repository.dart';

String _periodFilterLabel(AnalyticsPeriodFilter period) {
  switch (period) {
    case AnalyticsPeriodFilter.fy2526:
      return 'FY-25-26';
    case AnalyticsPeriodFilter.lastMonth:
      return 'Last month';
    case AnalyticsPeriodFilter.currentMonth:
      return 'Current month';
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  final T value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          borderRadius: BorderRadius.circular(12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: ColorConstants.amber,
          ),
          items: items
              .map(
                (e) => DropdownMenuItem<T>(
                  value: e,
                  child: Text(
                    labelBuilder(e),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff003D5B),
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// Tab-style period filter: Current month, Last month, FY 25-26.
class _PeriodFilterTabs extends StatelessWidget {
  const _PeriodFilterTabs({
    required this.value,
    required this.onSelected,
  });

  final AnalyticsPeriodFilter value;
  final ValueChanged<AnalyticsPeriodFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: AnalyticsBloc.periodFilterOptions.map((option) {
          final isSelected = option == value;
          return Expanded(
            child: Material(
              color: isSelected ? ColorConstants.amber : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () => onSelected(option),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      _periodFilterLabel(option),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color:
                            isSelected ? Colors.black87 : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class AnalyticsView extends StatelessWidget {
  final int? forUserId;
  const AnalyticsView({super.key, this.forUserId});

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: Upgrader(durationUntilAlertAgain: const Duration(seconds: 10)),
      shouldPopScope: () => false,
      showIgnore: false,
      showLater: false,
      navigatorKey: router.routerDelegate.navigatorKey,
      child: RepositoryProvider(
        create: (context) => AnalyticsRepository(forUserId),
        lazy: false,
        child: BlocProvider(
          lazy: false,
          create: (context) =>
              AnalyticsBloc(context, context.read())..add(GetAnalyticsEvent()),
          child: Scaffold(
            appBar: forUserId != null
                ? AppBar(title: const Text('Analytics'))
                : null,
            body: Builder(builder: (context) {
              final AnalyticsBloc bloc = context.read();
              return RefreshIndicator(
                onRefresh: () async {
                  bloc.add(GetAnalyticsEvent());
                },
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Container(
                      //   padding: const EdgeInsets.all(12),
                      //   decoration: const BoxDecoration(
                      //       gradient: LinearGradient(colors: [
                      //     Color(0xff959595),
                      //     Color(0xff636363)
                      //   ])),
                      //   alignment: Alignment.center,
                      //   child: Stack(
                      //     alignment: Alignment.topRight,
                      //     children: [
                      //     // Lottie.asset(ImageConstants.graph, repeat: true),
                      //       Align(
                      //         alignment: Alignment.topRight,
                      //         child: IconButton(
                      //           onPressed: () => bloc.add(GetAnalyticsEvent()),
                      //           color: Colors.white,
                      //           iconSize: 30,
                      //           icon: const Icon(
                      //               Icons.replay_circle_filled_rounded),
                      //         ),
                      //       )
                      //     ],
                      //   ),
                      // ),

                      BlocBuilder<AnalyticsBloc, AnalyticsState>(
                        builder: (context, state) {
                          return [
                            "tata consumer",
                            "tata consumers",
                            "organic india"
                          ].contains(AppStorage()
                                  .userDetail
                                  ?.companyName
                                  .toLowerCase())
                              ?
                              // AppStorage().userDetail?.companyName.toLowerCase()=="Tata Consumer".toLowerCase()?

                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 5),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _FilterDropdown<int>(
                                          value: bloc.selecteYears,
                                          items: bloc.yearsFilterOptions,
                                          labelBuilder: (y) => '$y year',
                                          onChanged: (year) {
                                            if (year != null) {
                                              bloc.add(
                                                  AnalyticsYearsChangeEvent(
                                                      year));
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _FilterDropdown<String>(
                                          value: bloc.selecteMonthsString ??
                                              bloc.monthFilterOptionsString
                                                  .first,
                                          items: bloc.monthFilterOptionsString,
                                          labelBuilder: (m) => '$m month',
                                          onChanged: (month) {
                                            if (month != null) {
                                              bloc.add(
                                                  AnalyticsMonthChangeEvent(
                                                      month));
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ))
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  child: _PeriodFilterTabs(
                                    value: bloc.selectedPeriodFilter,
                                    onSelected: (period) => bloc.add(
                                        AnalyticsPeriodFilterChangeEvent(
                                            period)),
                                  ),
                                );
                        },
                      ),
                      _analyticsList()
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  BlocBuilder<AnalyticsBloc, AnalyticsState> _analyticsList() {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, state) {
        final AnalyticsBloc bloc = context.read();
        if (state is LoadingState) {
          return SizedBox(
            width: 1.sw,
            height: 0.45.sh,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (bloc.analyticsList.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(3.0),
            child: Card(
              elevation: 0,
              color: Colors.grey.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Icon(Icons.insights_outlined, color: Colors.grey.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No analytics data available for the selected filter.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return AnimationLimiter(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bloc.analyticsList.length,
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
            separatorBuilder: (context, index) => const SizedBox(height: 5),
            itemBuilder: (context, index) {
              final TextTheme textTheme = Theme.of(context).textTheme;
              final item = bloc.analyticsList[index];

              final child = ["organic india"].contains(AppStorage()
                      .userDetail
                      ?.companyName
                      .toLowerCase()
                      .trim())
                  ? _newListItem(item, textTheme, context, bloc, index)
                  : ["mobil", "exxonmobil"].contains(AppStorage()
                          .userDetail
                          ?.companyName
                          .toLowerCase()
                          .trim())
                      ? _exxonListItem(item, textTheme, context, bloc, index)
                      : _oldListItem(item, textTheme, context, bloc, index);

              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 450),
                child: SlideAnimation(
                  verticalOffset: 18.0,
                  child: FadeInAnimation(
                    child: Card(
                      elevation: 1,
                      color: Colors.white,
                      surfaceTintColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: child,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _exxonListItem(AnalyticsModel item, TextTheme textTheme, context,
      AnalyticsBloc bloc, int index) {
    return ![
          "isp",
          "ISP CONDUCTED".toLowerCase(),
          "Total packs sold".toLowerCase()
        ].contains(item.kpiName.toLowerCase())
        ? _oldListItem(item, textTheme, context, bloc, index)
        : ExpansionTile(
                initiallyExpanded: item.isExpand,
                onExpansionChanged: (value) {
                  if (value) {
                    item.kpiName.trim().toLowerCase() == "total packs sold"
                        ? bloc.add(GetPackSoldEvent(index))
                        : bloc.add(GetISPProduct(index));
                  }
                  item.isExpand = value;
                },
                backgroundColor: Colors.transparent,
                shape: Border.all(color: Colors.transparent),
                title: _oldListItem(item, textTheme, context, bloc, index),
                children: [
                            for (int indexProduct = 0;
                                indexProduct < item.ispProductList.length;
                                indexProduct++)
                              Column(
                                children: [
                                  _getISPProductidget(
                                      item.ispProductList[indexProduct],
                                      bloc,
                                      index,
                                      textTheme,
                                      indexProduct),

                                      (item.ispProductList.length-1)!=indexProduct?
                                  const Padding(
                                    padding:  EdgeInsets.symmetric(horizontal:18.0),
                                    child:  Divider(
                                      color: Colors.amber,
                                    ),
                                  ): const SizedBox()
                                ],
                              ),
                          ],
              );
  }

  Widget _newListItem(AnalyticsModel item, TextTheme textTheme, context,
      AnalyticsBloc bloc, int index) {
    return ExpansionTile(
            initiallyExpanded: item.isExpand,
            onExpansionChanged: (value) {
              if (value) {
                bloc.add(GetCategoryListEvent(index));
              }
              item.isExpand = value;
            },
            backgroundColor: Colors.transparent,
            shape: Border.all(color: Colors.transparent),
            title: _oldListItem(item, textTheme, context, bloc, index),
            children: [
              for (int indexCategory = 0;
                  indexCategory < item.categories.length;
                  indexCategory++)
                _getCategoroyWidget(item.categories[indexCategory], bloc, index,
                    textTheme, indexCategory)
            ]);
  }

  Widget _oldListItem(AnalyticsModel item, TextTheme textTheme, context,
      AnalyticsBloc bloc, int index) {
    String achiveValue = "";
    if (![ "BrotherInternational".toLowerCase(),"mobil", "exxonmobil"].contains(AppStorage()
                          .userDetail
                          ?.companyName
                          .toLowerCase()
                          .trim())
      
      
      ) {
      achiveValue = "(₹)${item.achieved.toString()}";
    } else {
      achiveValue = item.achieved.toString();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            item.kpiName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 1,
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Target",
                        textAlign: TextAlign.center,
                        style: textTheme.titleSmall,
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        item.target.toString(),
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "Achieved",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      achiveValue,
                      //"(₹)${item.achieved.toString()}",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: CircularPercentIndicator(
                radius: 40.0,
                lineWidth: 10,
                percent: min(item.percentage, 100) / 100,
                backgroundColor: const Color(0xffededee),
                center: Text("${item.percentage.toStringAsFixed(1)}%"),
                progressColor: Colors.amber,
                animation: true,
                animationDuration: 2000,
                restartAnimation: false,
              ),
            )
          ],
        ),
        if (!["mobil", "exxonmobil"].contains(
                AppStorage().userDetail?.companyName.toLowerCase().trim()) &&
            bloc.analyticsList[index].incentive >= 0) ...[
          const SizedBox(height: 10),
          if (AppStorage().userDetail?.companyName.toLowerCase() !=
              "BrotherInternational".toLowerCase())
            Container(
              // decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(8),
              //     color: Colors.white,
              //     border: Border.all(color: ColorConstants.amber),
              //     boxShadow: const [
              //       BoxShadow(
              //         color: ColorConstants.amber,
              //         blurRadius: 1,
              //         spreadRadius: 0.5,
              //       )
              //     ]),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Incentive earned",
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Container(color: Colors.grey.shade400, width: 2, height: 20),
                  Text("Rs.${bloc.analyticsList[index].incentive}",
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold))
                ],
              ),
            )
        ]
      ],
    );
  }

  Widget _getISPProductidget(ISPProductModel item, AnalyticsBloc bloc,
      int index, TextTheme textTheme, int indexProduct) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: Text("→ ${item.productName}",
                  textAlign: TextAlign.left, style: textTheme.titleSmall),
            ),
            Expanded(
              flex: 1,
              child: Text(
                "Achieved\n${item.achieved}",
                textAlign: TextAlign.center,
                style: textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold, fontSize: 10.sp),
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            Expanded(
              flex: 1,
              child: Text(
                "Target\n${item.target}",
                textAlign: TextAlign.center,
                style: textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold, fontSize: 10.sp),
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            Expanded(
              flex: 1,
              child: Text(
                "Percentage\n${item.percentage}",
                textAlign: TextAlign.center,
                style: textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold, fontSize: 10.sp),
              ),
            ),
          ]),
    );
  }

  Widget _getCategoroyWidget(Category item, AnalyticsBloc bloc, int index,
      TextTheme textTheme, int indexCategory) {
    return ExpansionTile(
      initiallyExpanded: item.isExpand,
      onExpansionChanged: (value) {
        if (value) {
          bloc.add(
              GetSubCategoryListEvent(index, item.categoryId, indexCategory));
        }
        item.isExpand = value;
      },
      backgroundColor: Colors.transparent,
      shape: Border.all(color: Colors.transparent),
      title: Row(
        children: [
          Expanded(
            child: Text(
              item.categoryName.toUpperCase(),
              textAlign: TextAlign.start,
              style: textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xff0F766E)),
            ),
          ),
          Text(
            "${item.achieved}",
            textAlign: TextAlign.center,
            style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xff0F766E),
                fontSize: 10.sp),
          ),
        ],
      ),
      children: [
        const Divider(
          color: Colors.blueGrey,
          height: 0.5,
        ),
        for (int indexSubCategory = 0;
            indexSubCategory < item.subcategories.length;
            indexSubCategory++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: _getSubCategoryWidget(
                item.subcategories[indexSubCategory],
                bloc,
                index,
                textTheme,
                indexCategory,
                indexSubCategory,
                item.categoryId),
          )
      ],
    );
  }

  Widget _getSubCategoryWidget(
      SubCategory item,
      AnalyticsBloc bloc,
      int index,
      TextTheme textTheme,
      int indexCategory,
      int indexSubCategory,
      int categoryId) {
    return ExpansionTile(
      initiallyExpanded: item.isExpand,
      onExpansionChanged: (value) {
        if (value) {
          bloc.add(GetProductListListEvent(index, indexCategory,
              indexSubCategory, categoryId, item.subCategoryId));
        }
        item.isExpand = value;
      },
      backgroundColor: Colors.transparent,
      shape: Border.all(color: Colors.transparent),
      title: Row(
        children: [
          Expanded(
            child: Text("📂${item.subCategoryName.toUpperCase()}",
                textAlign: TextAlign.start,
                style: textTheme.titleSmall?.copyWith(
                  color: const Color(0xff1D4ED8),
                  fontWeight: FontWeight.w700,
                )),
          ),
          Text(
            "${item.achieved}",
            textAlign: TextAlign.center,
            style: textTheme.titleSmall?.copyWith(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 10.sp),
          ),
        ],
      ),
      children: [
        const Divider(
          color: Colors.blueGrey,
          height: 0.5,
        ),
        for (int indexProduct = 0;
            indexProduct < item.products.length;
            indexProduct++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child:
                _getProductWidget(item.products[indexProduct], bloc, textTheme),
          )
      ],
    );
  }

  Widget _getProductWidget(
      Product item, AnalyticsBloc bloc, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Text("→ ${item.productName}",
                  textAlign: TextAlign.left, style: textTheme.titleSmall),
            ),
            Text(
              "${item.achieved}",
              textAlign: TextAlign.center,
              style: textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold, fontSize: 10.sp),
            ),
          ]),
    );
  }

  Widget borderedBox({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorConstants.amber),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(8), child: child),
    );
  }

  Widget shadowBox({required Widget child}) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                  color: ColorConstants.amber, blurRadius: 2, spreadRadius: 2)
            ]),
        child: child);
  }
}
