import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i_densfa/module/ui/custom_search_bar.dart';
import 'package:i_densfa/utility/app_constants.dart';

class InventoryView extends StatelessWidget {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: MaterialButton(
                onPressed: () {},
                color: Theme.of(context).colorScheme.primary,
                textColor: Colors.white,
                shape: const CircleBorder(),
                child: SvgPicture.asset(imageConstants.filter),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // SizedBox(
                  //   width: 1.sw,
                  //   height: 5,
                  // ),
                  Card(
                    color: Theme.of(context).colorScheme.primary,
                    elevation: 5,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Stack(
                      children: [
                        SvgPicture.asset(
                          imageConstants.inventoryMask,
                          fit: BoxFit.fill,
                        ),
                        Padding(
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
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  const Icon(
                                    Icons.info_outline_rounded,
                                    color: Colors.white,
                                  ),
                                  const Expanded(
                                      child: SizedBox(
                                    height: 10,
                                  )),
                                  Text(
                                    "Value in",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(color: Colors.white),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2, vertical: 5),
                                child: Divider(
                                  color: Color(0xFF546E7A),
                                  height: 1,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "System Opening",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.white),
                                  ),
                                  const Expanded(
                                      child: SizedBox(
                                    height: 10,
                                  )),
                                  Text(
                                    "1,08,98700",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.white),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2, vertical: 5),
                                child: Divider(
                                  color: Color(0xFF546E7A),
                                  height: 1,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Received as Reporded",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.white),
                                  ),
                                  const Expanded(
                                      child: SizedBox(
                                    height: 10,
                                  )),
                                  Text(
                                    "0",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.white),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2, vertical: 5),
                                child: Divider(
                                  color: Color(0xFF546E7A),
                                  height: 1,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "System Opening",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.white),
                                  ),
                                  const Expanded(
                                      child: SizedBox(
                                    height: 10,
                                  )),
                                  Text(
                                    "1,2323,123",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.white),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2, vertical: 5),
                                child: Divider(
                                  color: Color(0xFF546E7A),
                                  height: 1,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Sell-Out as Reported",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.white),
                                  ),
                                  const Expanded(
                                      child: SizedBox(
                                    height: 10,
                                  )),
                                  Text(
                                    "0",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.white),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2, vertical: 5),
                                child: Divider(
                                  color: Color(0xFF546E7A),
                                  height: 1,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Sell-Out as Dervived",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.white),
                                  ),
                                  const Expanded(
                                      child: SizedBox(
                                    height: 10,
                                  )),
                                  Text(
                                    "Value in",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.white),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2, vertical: 5),
                                child: Divider(
                                  color: Color(0xFF546E7A),
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "All the values are in MOP (Market Operating Price)",
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.black),
                  ),
                  const CustomSearchBar(
                    colors: Colors.white,
                    iconColor: Colors.black,
                    hintText: "Search by name...",
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Container(
              constraints: BoxConstraints(maxHeight: 1.sh),
              child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(5),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 5),
                  itemBuilder: (context, index) => const ItemsList()),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemsList extends StatelessWidget {
  const ItemsList({super.key});

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
              child: SvgPicture.asset(imageConstants.product),
            ),
            const SizedBox(
              width: 5,
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Samsung",
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
                  "06",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(
              width: 5,
            )
          ],
        ),
      ),
    );
  }
}
