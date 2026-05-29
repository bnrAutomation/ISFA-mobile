part of 'analytics_bloc.dart';

/// Period filter options: FY 2025-26, Last month, Current month.
enum AnalyticsPeriodFilter {
  fy2526,
  lastMonth,
  currentMonth,
}

@immutable
abstract class AnalyticsEvent {}

class AnalyticsPeriodFilterChangeEvent extends AnalyticsEvent {
  final AnalyticsPeriodFilter period;
  AnalyticsPeriodFilterChangeEvent(this.period);
}

class AnalyticsDaysChangeEvent extends AnalyticsEvent {
  final int days;
  AnalyticsDaysChangeEvent(this.days);
}

class AnalyticsMonthChangeEvent extends AnalyticsEvent {
  final String month;
  AnalyticsMonthChangeEvent(this.month);
}

class AnalyticsYearsChangeEvent extends AnalyticsEvent {
  final int years;
  AnalyticsYearsChangeEvent(this.years);
}

class GetAnalyticsEvent extends AnalyticsEvent {}

class DataChangeAnalyticEvent extends AnalyticsEvent {}


class GetCategoryListEvent extends AnalyticsEvent {
  final int index;
  GetCategoryListEvent(this.index);
}
class GetPackSoldEvent extends AnalyticsEvent {
  final int index;
  GetPackSoldEvent(this.index);
}

class GetISPProduct extends AnalyticsEvent {
  final int index;
  GetISPProduct(this.index);
}



class GetSubCategoryListEvent extends AnalyticsEvent {
  final int index;
   final int indexCategory;
  final int? selectedCategoryId;
  
  GetSubCategoryListEvent(
      this.index,this.selectedCategoryId,
      this.indexCategory);
}

class GetProductListListEvent extends AnalyticsEvent {
  final int index;
  final int indexCategory;
  final int indexSubCategory;

  final int? selectedCategoryId;
  final int? selectedSubCategoryId;

  GetProductListListEvent(
  this.index, this.indexCategory,
  this.indexSubCategory,this.selectedCategoryId,
  this.selectedSubCategoryId);
}
