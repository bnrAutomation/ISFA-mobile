part of 'modify_quantity_bloc.dart';

@immutable
abstract class ModifyQuantityEvent {}

class GetCategoriesListEvent extends ModifyQuantityEvent {}

class SelectCategoryEvent extends ModifyQuantityEvent {
  final String categoryName;

  SelectCategoryEvent(this.categoryName);
}

class SelectProductEvent extends ModifyQuantityEvent {
  final String productName;

  SelectProductEvent(this.productName);
}

class ModifyQtySubmitEvent extends ModifyQuantityEvent {}

class ChangeQtyEvent extends ModifyQuantityEvent {
  final String value;

  ChangeQtyEvent(this.value);
}

class AddPriceSaleProductEvent extends ModifyQuantityEvent {
  final String price;

  AddPriceSaleProductEvent(this.price);
}
