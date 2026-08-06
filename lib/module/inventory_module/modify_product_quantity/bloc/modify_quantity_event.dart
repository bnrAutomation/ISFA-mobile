part of 'modify_quantity_bloc.dart';

@immutable
abstract class ModifyQuantityEvent {}

class GetCategoriesListEvent extends ModifyQuantityEvent {}

class GetSubCategoriesListEvent extends ModifyQuantityEvent {
  final int categoryId;
  GetSubCategoriesListEvent(this.categoryId);
}

class GetProductListEvent extends ModifyQuantityEvent {
  final int categoryId;
  final int subCategoryId;
  GetProductListEvent(this.categoryId,this.subCategoryId);
}

class SelectCategoryEvent extends ModifyQuantityEvent {
  final String categoryName;
  SelectCategoryEvent(this.categoryName);
}


class SelectSubCategoryEvent extends ModifyQuantityEvent {
  final String categoryName;
  final int categoryId;
  final int subCategoryId;

  SelectSubCategoryEvent(this.categoryId,this.categoryName,this.subCategoryId);
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
