import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/module/ui/custom_material_button.dart';
import 'package:i_densfa/module/ui/button_views.dart';

import 'bloc/modify_quantity_bloc.dart';

class ModifyProductQuantityPopup extends StatelessWidget {
  final String title;
  final void Function() onPop;
  const ModifyProductQuantityPopup({
    super.key,
    required this.title,
    required this.onPop,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ModifyQuantityBloc, ModifyQuantityState>(
        listenWhen: (previous, current) =>
            current is ToastMessageState || current is SuccessQtyChange,
        listener: (context, state) {
          if (state is ToastMessageState) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
            ));
          }
          if (state is SuccessQtyChange) {
            final text = context.read<ModifyQuantityBloc>().isSale
                ? "Successfully Sale added"
                : "Successfully Inventory added";
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(text)));
            Navigator.pop(context);
            onPop();
          }
        },
        builder: (context, state) {
          if (state is LoadingState) {
            return SizedBox(
              height: 0.8.sh,
              width: 1.sw,
              child: const Center(child: CircularProgressIndicator()),
            );
          }
          final bloc = context.read<ModifyQuantityBloc>();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 12.h),
                Text("Category", style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 5),
                DropDownWithOptions(
                  options: bloc.categories.map((e) => e.categoryName).toList(),
                  hint: "Please select category",
                  selectedVal: bloc.selectedCategory?.categoryName,
                  valChanged: (value) {
                    if (value != null) {
                      bloc.add(SelectCategoryEvent(value));
                    }
                  },
                ),
                SizedBox(height: 8.h),
                if (bloc.selectedCategory != null) ...[
                  Text("Product",
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 5),
                  DropDownWithOptions(
                    options: bloc.products.map((e) => e.productName).toList(),
                    hint: "Please select product",
                    selectedVal: bloc.selectedProduct?.productName,
                    valChanged: (value) {
                      if (value != null) {
                        bloc.add(SelectProductEvent(value));
                      }
                    },
                  ),
                ],
                SizedBox(height: 8.h),
                if (bloc.selectedProduct != null) ...[
                  Text(
                      "Quantity (Stock count is ${bloc.selectedProduct!.stockBalance ?? 0})",
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 5),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: TextField(
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        hintText: 'Enter quantity',
                      ),
                      onChanged: (value) => bloc.add(ChangeQtyEvent(value)),
                    ),
                  ),
                  if (bloc.isSale && bloc.selectedProduct != null) ...[
                    SizedBox(height: 8.h),
                    Text("Calculated Price",
                        style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 5),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: TextField(
                        readOnly: true,
                        controller: TextEditingController(
                            text: bloc.enteredPrice.toStringAsFixed(0)),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text("Actual Price",
                        style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 5),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: TextField(
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^(\d+)?\.?\d{0,2}'))
                        ],
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(
                            text: bloc.enteredPrice.toStringAsFixed(0)),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                          hintText: 'Enter Price',
                        ),
                        onChanged: (value) =>
                            bloc.add(AddPriceSaleProductEvent(value)),
                      ),
                    ),
                  ],
                ],
                SizedBox(height: 12.h),
                CustomMaterialButton(
                    buttonText: "Submit",
                    onPressed: () => bloc.add(ModifyQtySubmitEvent())),
              ],
            ),
          );
        },
      ),
    );
  }
}
