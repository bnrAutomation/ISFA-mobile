import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_broadcast_receiver/flutter_broadcast_receiver.dart';
import 'package:i_densfa/module/analytics_module/analytics_repository.dart';
import 'package:i_densfa/module/analytics_module/model/analytics_model.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final userDetails = AppStorage().userDetail!;

  final AnalyticsRepository repo;
  int selectedDays = 30;
  int selecteMonths = DateTime.now().month;
  int selecteYears = DateTime.now().year;
  String? selecteMonthsString;

  /// Selected period filter for non–Tata/Organic companies.
  AnalyticsPeriodFilter selectedPeriodFilter =
      AnalyticsPeriodFilter.currentMonth;

  static const List<AnalyticsPeriodFilter> periodFilterOptions = [
    AnalyticsPeriodFilter.fy2526,
    AnalyticsPeriodFilter.lastMonth,
    AnalyticsPeriodFilter.currentMonth,
  ];

  List<int> daysFilterOptions = [45, 30, 15, 7, 1];
  List<int> monthFilterOptions = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
  List<int> yearsFilterOptions = [2024, 2025, 2026];

  List<String> monthFilterOptionsString = [
    "Jan",
    "Feb",
    "March",
    "April",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];

  List<AnalyticsModel> analyticsList = [];

  String? selectedSubCategory;
  int? selectedSubCategoryId;

  Product? selectedProduct;

  AnalyticsBloc(BuildContext context, this.repo) : super(AnalyticsInitial()) {
    int index = monthFilterOptions
        .indexWhere((element) => DateTime.now().month == element);
    selecteMonthsString = monthFilterOptionsString[index];
    registerBroadcast(context);
    on<DataChangeAnalyticEvent>((event, emit) => emit(DataChangeState()));
    on((AnalyticsDaysChangeEvent event, emit) {
      selectedDays = event.days;
      add(GetAnalyticsEvent());
    });

    on((AnalyticsMonthChangeEvent event, emit) {
      selecteMonthsString = event.month;
      //selecteMonths = event.month;
      int index = monthFilterOptionsString
          .indexWhere((element) => selecteMonthsString == element);
      selecteMonths = monthFilterOptions[index];
      add(GetAnalyticsEvent());
    });
    on((AnalyticsYearsChangeEvent event, emit) {
      selecteYears = event.years;
      add(GetAnalyticsEvent());
    });
    on((AnalyticsPeriodFilterChangeEvent event, emit) {
      selectedPeriodFilter = event.period;
      add(GetAnalyticsEvent());
    });
    on((GetAnalyticsEvent event, emit) async {
      try {
        emit(LoadingState());
        if (kDebugMode) {
          debugPrint(AppStorage().userDetail?.companyName.toString());
        }
        final isTataOrOrganic = [
          "tata consumer",
          "tata consumers",
          "organic india"
        ].contains(AppStorage().userDetail?.companyName.toLowerCase());
        final query = isTataOrOrganic
            ? {
                'year': selecteYears.toString(),
                "month": selecteMonths.toString()
              }
            : _buildPeriodQuery();
        final details = await repo.getDetails(query);
        analyticsList = details;
        emit(AnalyticsUpdateData());
      } catch (e) {
        emit(AnalyticsSnackBarMessage(e.toString()));
      }
    });

    on<GetCategoryListEvent>((event, emit) async {
      try {
        if (!["organic india"]
            .contains(AppStorage().userDetail?.companyName.toLowerCase())) {
          return;
        }
        final query = {
          'year': selecteYears.toString(),
          "month": selecteMonths.toString()
        };
        final categorylist = await repo.getCategoryList(query);
        analyticsList[event.index].categories = categorylist;
        emit(AnalyticsUpdateData());
      } catch (e) {
        emit(AnalyticsSnackBarMessage(e.toString()));
      }
    });

    on<GetSubCategoryListEvent>((event, emit) async {
      try {
        if (!["organic india"]
            .contains(AppStorage().userDetail?.companyName.toLowerCase())) {
          return;
        }
        final query = {
          'year': selecteYears.toString(),
          "month": selecteMonths.toString(),
          "categoryId": event.selectedCategoryId.toString()
        };
        final subCategorylist = await repo.getSubCategoryList(query);
        analyticsList[event.index]
            .categories[event.indexCategory]
            .subcategories = subCategorylist;

        emit(AnalyticsUpdateData());
      } catch (e) {
        emit(AnalyticsSnackBarMessage(e.toString()));
      }
    });
    on<GetPackSoldEvent>((event,emit)async {
        try{
           final query = {
          'year': selecteYears.toString(),
          "month": selecteMonths.toString(),
        };
          List<ISPProductModel> ispProductList = await repo.getPackSoldList(query);
          analyticsList[event.index].ispProductList = ispProductList;
           emit(AnalyticsUpdateData());

        }catch (e) {
        emit(AnalyticsSnackBarMessage(e.toString()));
      }
    });

    on<GetISPProduct>((event,emit)async {
        try{
        List<ISPProductModel> ispProductList =    await repo.getIspProductList();
          analyticsList[event.index].ispProductList = ispProductList;
           emit(AnalyticsUpdateData());
        }catch (e) {
        emit(AnalyticsSnackBarMessage(e.toString()));
      }

    });

    on<GetProductListListEvent>((event, emit) async {
      try {
        if (!["organic india"]
            .contains(AppStorage().userDetail?.companyName.toLowerCase())) {
          return;
        }
        final query = {
          'year': selecteYears.toString(),
          "month": selecteMonths.toString(),
          "categoryId": event.selectedCategoryId.toString(),
          "subCategoryId": event.selectedSubCategoryId.toString()
        };
        final productList = await repo.getProductList(query);
        analyticsList[event.index]
            .categories[event.indexCategory]
            .subcategories[event.indexSubCategory]
            .products = productList;
        emit(AnalyticsUpdateData());
      } catch (e) {
        emit(AnalyticsSnackBarMessage(e.toString()));
      }
    });
  }

  Map<String, String> getFinancialYearRange() {
    final now = DateTime.now();
    final isAfterApril = now.month >= 4;

    final startYear = isAfterApril ? now.year : now.year - 1;
    final endYear = startYear + 1;

    final start = DateTime(startYear, 4, 1);
    final end = DateTime(endYear, 3, 31, 23, 59, 59);

    return {
      "startDate": start.toIso8601String().split('.').first,
      "endDate": end.toIso8601String().split('.').first
    };
  }

  Map<String, String> getLastMonthYear() {
    final now = DateTime.now();
    // If current month is January
    if (now.month == 1) {
      return {"month": "12", "year": "${now.year - 1}"};
    }

    return {"month": "${now.month - 1}", "year": "${now.year}"};
  }

  Map<String, String> getCurrentMonthYear() {
    final now = DateTime.now();
    return {"month": "${now.month}", "year": "${now.year}"};
  }

  /// Builds query params for period filter (FY-26-26, Last month, Current month).
  Map<String, String> _buildPeriodQuery() {
    if (selectedPeriodFilter == AnalyticsPeriodFilter.fy2526) {
      return getFinancialYearRange();
    } else if (selectedPeriodFilter == AnalyticsPeriodFilter.lastMonth) {
      return getLastMonthYear();
    } else {
      return getCurrentMonthYear();
    }
  }

  void registerBroadcast(BuildContext context) {
    BroadcastReceiver().subscribe<String>(AppConstant.updateAnylitec,
        (String message) async {
      add(GetAnalyticsEvent());
    });
  }
}
