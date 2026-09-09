import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_broadcast_receiver/flutter_broadcast_receiver.dart';
import 'package:i_densfa/module/inventory_module/modify_product_quantity/inventory_repository.dart';
import 'package:i_densfa/module/inventory_module/modify_product_quantity/product_category_model.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';

part 'modify_quantity_event.dart';
part 'modify_quantity_state.dart';

class ModifyQuantityBloc
    extends Bloc<ModifyQuantityEvent, ModifyQuantityState> {
  final ModifyProductsRepository repo;
  List<ProductCategoryModel> categories = [];
  ProductCategoryModel? selectedCategory;
  SubCategoryModel? selectedSubCategory;

  ProductList? selectedProduct;
  int? selectedQuantity;
  int? selectedApprochedQuantity;
  double enteredPrice = 0;
  final bool isSale;

  List<ProductList> get products {
    return 
    AppStorage().userDetail?.companyName.toLowerCase()=="apple"?

    selectedSubCategory?.productList??[]:

    selectedCategory?.productList ?? [];
  }

   List<SubCategoryModel> get subcategory {
    return selectedCategory?.subCategoryList ?? [];
  }

  ModifyQuantityBloc(this.repo, this.isSale) : super(LoadingState()) {
    on((GetCategoriesListEvent event, emit) async =>await _getCategoryList(emit));
    on((GetSubCategoriesListEvent event, emit) async =>await _getSubCategoryList(event,emit));
    on((GetProductListEvent event, emit) async =>await _getProductList(event,emit));
    on(_selectCategoryEvent);
    on(_selectSubCategoryEvent);
    on(_selectProductEvent);
    on((ModifyQtySubmitEvent event, emit) async => await _onSubmitEvent(emit));
    on((ChangeQtyEvent event, emit) {
      final val = int.tryParse(event.value) ?? 0;
      enteredPrice = (selectedProduct?.price ?? 0.0) * val;
      selectedQuantity = val;
      emit(LoadedState());
    });

    on((ChangeAprochQtyEvent event, emit) {
      final val = int.tryParse(event.value) ?? 0;
      selectedApprochedQuantity = val;
      emit(LoadedState());
    });

    
    on((AddPriceSaleProductEvent event, emit) {
      final val = double.tryParse(event.price) ?? 0;
      enteredPrice = val;
    });
  }

  Future<void> _getCategoryList(Emitter<ModifyQuantityState> emit) async {
    emit(LoadingState());
    categories = await repo.getCategoryList().catchError((onError) {
      emit(ToastMessageState(onError.toString()));
      return <ProductCategoryModel>[];
    });
    emit(LoadedState());
  }

  Future<void> _getSubCategoryList(
     event ,Emitter<ModifyQuantityState> emit) async {
   // emit(LoadingState());
   final subcategory = await repo.getSubCategoryList(event.categoryId.toString()).catchError((onError) {
      emit(ToastMessageState(onError.toString()));
      return <SubCategoryModel>[];
    });
    selectedCategory?.subCategoryList = subcategory;
    categories.firstWhere((element) =>element.categoryId==event.categoryId).subCategoryList = subcategory;
    emit(LoadedState());
  }

    Future<void> _getProductList(GetProductListEvent event,Emitter<ModifyQuantityState> emit) async {
   // emit(LoadingState());
    final  productlist = await repo.getProduct(event.categoryId,event.subCategoryId).catchError((onError) {
      emit(ToastMessageState(onError.toString()));
      return <ProductList>[];
    });
    selectedCategory?.productList = productlist;
    selectedCategory?.subCategoryList.firstWhere((element) =>element.subCategoryId==event.subCategoryId).productList = productlist;
    categories.firstWhere((element) =>element.categoryId==event.categoryId).subCategoryList
    .firstWhere((element) =>element.subCategoryId==event.subCategoryId).productList= productlist;
    emit(LoadedState());
  }

  void _selectCategoryEvent(
      SelectCategoryEvent event, Emitter<ModifyQuantityState> emit) {
    selectedCategory = categories
        .firstWhere((element) => element.categoryName == event.categoryName);
        if( AppStorage().userDetail?.companyName.toLowerCase()==
      "organic india".toLowerCase()){
    add(GetSubCategoriesListEvent(selectedCategory?.categoryId??-1));
        }
    emit(LoadedState());
  }

  void _selectSubCategoryEvent(
      SelectSubCategoryEvent event, Emitter<ModifyQuantityState> emit) {
    selectedSubCategory =
        selectedCategory?.subCategoryList.firstWhere((subcateElement)=>subcateElement.categoryId==event.categoryId && subcateElement.subCategoryId== event.subCategoryId);
    add(GetProductListEvent(selectedSubCategory?.categoryId??-1,selectedSubCategory?.subCategoryId??-1));
    emit(LoadedState());
  }

  void _selectProductEvent(
      SelectProductEvent event, Emitter<ModifyQuantityState> emit) {
    selectedProduct = products
        .firstWhere((element) => element.productName == event.productName);

    enteredPrice = (selectedProduct?.price ?? 0.0) * (selectedQuantity ?? 1);
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

    if (selectedQuantity == null || selectedQuantity == 0) {
      emit(ToastMessageState('Please enter quantity'));
      return;
    }

    if (isSale) {
      if (selectedQuantity! > (selectedProduct!.stockBalance ?? 0)) {
        emit(ToastMessageState('Quantity entered is more than stock balance'));
        return;
      }
      if (enteredPrice <= 0) {
        emit(ToastMessageState('Please enter price'));
        return;
      }
      if(["tata consumer", "tata consumers"].contains(
                          AppStorage()
                              .userDetail
                              ?.companyName
                              .toLowerCase()) && ((selectedApprochedQuantity??0) <= (selectedQuantity?? 0))){
                                    emit(ToastMessageState('Total Approach must always be MORE than Total Sales Units.'));
        return;
                              }
      final response = await repo
          .addSaleQty(
              catId: selectedCategory!.categoryId,
              productId: selectedProduct!.productId,
              qty: selectedQuantity!,
              approchQty: selectedApprochedQuantity??0,
              price: selectedProduct?.price ?? 0.0)
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
        qty: selectedQuantity!,
        price: selectedProduct!.price,
      )
          .catchError((onError) {
        emit(ToastMessageState(onError.toString()));
        return false;
      });

      if (response) {
        emit(SuccessQtyChange());
      }
       BroadcastReceiver().publish<String>(AppConstant.updateAnylitec,
          arguments:"");
    }

    emit(LoadedState());
  }
}
