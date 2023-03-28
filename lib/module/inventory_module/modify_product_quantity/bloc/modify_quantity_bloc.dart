import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/inventory_module/modify_product_quantity/product_category_model.dart';
import 'package:i_densfa/module/inventory_module/modify_product_quantity/repository.dart';

part 'modify_quantity_event.dart';
part 'modify_quantity_state.dart';

class ModifyQuantityBloc
    extends Bloc<ModifyQuantityEvent, ModifyQuantityState> {
  final ModifyProductsRepository repo;
  List<ProductCategoryModel> categories = [];
  ProductCategoryModel? selectedCategory;
  ProductList? selectedProduct;
  int? selectedQuantity;
  final bool isSale;

  List<ProductList> get products {
    return selectedCategory?.productList ?? [];
  }

  ModifyQuantityBloc(this.repo, this.isSale) : super(LoadingState()) {
    on((GetCategoriesListEvent event, emit) async =>
        await _getCategoryList(emit));
    on(_selectCategoryEvent);
    on(_selectProductEvent);
    on((ModifyQtySubmitEvent event, emit) async => await _onSubmitEvent(emit));
    on((ChangeQtyEvent event, emit) {
      final val = int.tryParse(event.value) ?? 0;
      selectedQuantity = val;
    });
  }

  Future<void> _getCategoryList(Emitter<ModifyQuantityState> emit) async {
    emit(LoadingState());
    categories = await repo.getCategoryList();
    emit(LoadedState());
  }

  void _selectCategoryEvent(
      SelectCategoryEvent event, Emitter<ModifyQuantityState> emit) {
    selectedCategory = categories
        .firstWhere((element) => element.categoryName == event.categoryName);
    emit(LoadedState());
  }

  void _selectProductEvent(
      SelectProductEvent event, Emitter<ModifyQuantityState> emit) {
    selectedProduct = products
        .firstWhere((element) => element.productName == event.productName);
    emit(LoadedState());
  }

  Future<void> _onSubmitEvent(emit) async {
    emit(LoadingState());

    if (selectedCategory == null) {
      emit(ToastMessageState('Please select category'));
      return;
    }

    if (selectedProduct == null) {
      emit(ToastMessageState('Please select product'));
      return;
    }

    if (selectedQuantity == null) {
      emit(ToastMessageState('Please enter quantity'));
      return;
    }

    if (isSale) {
      if (selectedQuantity! > (selectedProduct!.stockBalance ?? 0)) {
        emit(ToastMessageState('Quanity entered is more than stock balance'));
        return;
      }
      final response = await repo
          .addSaleQty(
              catId: selectedCategory!.categoryId,
              productId: selectedProduct!.productId,
              qty: selectedQuantity!)
          .catchError((onError) {
        emit(ToastMessageState(onError.toString()));
        return false;
      });

      if (response) {
        emit(SuccessQtyChange());
      }
    } else {
      final response = await repo
          .addInventoryQty(
              catId: selectedCategory!.categoryId,
              productId: selectedProduct!.productId,
              qty: selectedQuantity!)
          .catchError((onError) {
        emit(ToastMessageState(onError.toString()));
        return false;
      });

      if (response) {
        emit(SuccessQtyChange());
      }
    }

    emit(LoadedState());
  }
}
