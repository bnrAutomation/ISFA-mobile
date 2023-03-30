import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i_densfa/module/inventory_module/modify_product_quantity/bloc/modify_quantity_bloc.dart';
import 'package:i_densfa/module/inventory_module/modify_product_quantity/repository.dart';
import 'package:i_densfa/module/promoter_module/bloc/promoter_bloc.dart';
import 'package:i_densfa/module/promoter_module/models/inventory_detail_model.dart';
import 'package:i_densfa/module/ui/custom_search_bar.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:intl/intl.dart';

import '../ui/app_pop_view.dart';
import '../ui/button_views.dart';
import 'modify_product_quantity/view.dart';

class InventoryView extends StatelessWidget {
  const InventoryView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: AddFloatingActionButton(onTap: () {
        AppPopup.showAppBottomSheet(
          context: context,
          child: BlocProvider(
            create: (context) =>
                ModifyQuantityBloc(ModifyProductsRepository(), false)
                  ..add(GetCategoriesListEvent()),
            child: ModifyProductQuantityPopup(
              title: "Add Product Quantity",
              onPop: () {},
            ),
          ),
        );
      }),
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Inventory",
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: Colors.white),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate.fixed([
              Align(
                alignment: Alignment.topRight,
                child: MaterialButton(
                  onPressed: () {},
                  color: Theme.of(context).colorScheme.primary,
                  textColor: Colors.white,
                  shape: const CircleBorder(),
                  child: SvgPicture.asset(ImageConstants.filter),
                ),
              ),
              Card(
                margin: EdgeInsets.symmetric(horizontal: 15.w),
                color: Theme.of(context).colorScheme.primary,
                elevation: 5,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Stack(
                  children: [
                    SvgPicture.asset(
                      ImageConstants.inventoryMask,
                      fit: BoxFit.fill,
                    ),
                    BlocBuilder<PromoterBloc, PromoterState>(
                      buildWhen: (previous, current) =>
                          current is StoreInventoryLoadedState,
                      builder: (context, state) {
                        final bloc = context.read<PromoterBloc>();
                        return Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Stock",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(color: Colors.white),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.info_outline_rounded,
                                    color: Colors.white,
                                  ),
                                  const Expanded(child: SizedBox(height: 10)),
                                  Text(
                                    "Value in",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(color: Colors.white),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5.h),
                              _detailNameVal(context,
                                  name: "Products",
                                  val: bloc.inventoryDetail?.numberOfProduct
                                          .toString() ??
                                      '0'),
                              _detailDivider(),
                              _detailNameVal(context,
                                  name: "Selling",
                                  val: bloc.inventoryDetail?.numberOfSelling
                                          .toString() ??
                                      '0'),
                              _detailDivider(),
                              if (bloc.inventoryDetail != null)
                                _detailNameVal(context,
                                    name: "Last recived on",
                                    val: DateFormat('dd MMM yyyy').format(
                                        bloc.inventoryDetail!.lastReciveDate)),
                              _detailDivider(),
                              _detailNameVal(context,
                                  name: 'Sustem Opening', val: ''),
                              _detailDivider(),
                              _detailNameVal(context,
                                  name: "Received as Reporded", val: ""),
                              _detailDivider(),
                              _detailNameVal(context,
                                  name: "System Opening", val: ""),
                              _detailDivider(),
                              _detailNameVal(context,
                                  name: "Sell-Out as Reported", val: ""),
                              _detailDivider(),
                              _detailNameVal(context,
                                  name: "Sell-Out as Dervived", val: ""),
                            ],
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Text(
                  "All the values are in MOP (Market Operating Price)",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.black),
                ),
              ),
              const CustomSearchBar(
                colors: Colors.white,
                iconColor: Colors.black,
                hintText: "Search by name...",
              ),
              const SizedBox(height: 5),
            ]),
          ),
          SliverFillRemaining(
            hasScrollBody: true,
            child: BlocBuilder<PromoterBloc, PromoterState>(
              buildWhen: (previous, current) =>
                  current is StoreInventoryLoadedState,
              builder: (context, state) {
                final bloc = context.read<PromoterBloc>();
                return ListView.separated(
                    itemCount: bloc.inventoryDetail?.productList.length ?? 0,
                    padding: const EdgeInsets.all(5),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 5),
                    itemBuilder: (context, index) => ItemsList(
                        detail: bloc.inventoryDetail!.productList[index]));
              },
            ),
          )
        ],
      ),
    );
  }

  Row _detailNameVal(BuildContext context,
      {required String name, required String val}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          name,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 10),
        Text(
          val,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.white),
        ),
      ],
    );
  }

  Padding _detailDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 5),
      child: Divider(color: Color(0xFF546E7A), height: 1),
    );
  }
}

class ItemsList extends StatelessWidget {
  final InventoryProductDetailModel detail;
  const ItemsList({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 0.2.sw,
              child: SvgPicture.asset(ImageConstants.product),
            ),
            const SizedBox(width: 5),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.productName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600, color: Colors.blue),
                ),
                Row(
                  children: [
                    Text(
                      "MOP :",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      "333/Unit",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                )
              ],
            )),
            Row(
              children: [
                Text(
                  "Qty :",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  detail.stockBalance.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(width: 5)
          ],
        ),
      ),
    );
  }
}
