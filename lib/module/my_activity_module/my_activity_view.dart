import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/module/my_activity_module/model/my_activity_model.dart';
import 'package:i_densfa/module/my_activity_module/myActivity/my_activity_bloc.dart';
import 'package:i_densfa/module/my_activity_module/my_activity_repository.dart';
import 'package:i_densfa/utility/extensions.dart';

class MyActivityView extends StatefulWidget {
  const MyActivityView({super.key});

  @override
  MyActivityViewState createState() => MyActivityViewState();
}

class MyActivityViewState extends State<MyActivityView> {
  final searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "My Activity",
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: Colors.white),
        ),
      ),
      body: RepositoryProvider(
        create: (context) => MyActivityRepository(),
        child: BlocProvider(
          create: (context) =>
              MyActivityBloc(context.read())..add(GetMyAcivityEvent()),
          child: BlocConsumer<MyActivityBloc, MyActivityState>(
            listenWhen: (previous, current) => current is MyActivityShowSnack,
            listener: (context, state) {
              if (state is MyActivityShowSnack) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.message),
                ));
              }
            },
            buildWhen: (previous, current) => current is! MyActivityShowSnack,
            builder: (context, state) {
              var bloc = context.read<MyActivityBloc>();
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                      child: SearchBar(
                          leading:
                              const Icon(Icons.search, color: Colors.black),
                          hintText: 'Search by store or activity...',
                          side: MaterialStateProperty.all(const BorderSide(
                              width: 1.0, color: Colors.black)),
                          controller: searchController,
                          elevation: MaterialStateProperty.all(0.0),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.white),
                          onChanged: (value) =>
                              bloc.add(SearchActivityEvent(value))),
                    ),
                  ),
                  Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white,
                            blurRadius: 1.0, // soften the shadow
                            spreadRadius: 1.0, //extend the shadow
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            bloc.selected.toStringFormat("dd MMMM"),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          IconButton(
                              onPressed: () async {
                                final now = DateTime.now();
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: now,
                                  firstDate: DateTime(now.year),
                                  lastDate: DateTime(now.year + 1),
                                );
                                if (date != null && context.mounted) {
                                  bloc.add(MyActivityChangeMonth(date));
                                }
                              },
                              icon: const Icon(
                                Icons.calendar_month,
                                color: Colors.blue,
                              )),
                        ],
                      )),
                  Container(color: Colors.grey.shade300, height: 1),
                  (searchController.text.isNotEmpty &&
                          bloc.activityList.isEmpty)
                      ? const Expanded(child: Center(child: Text("No Data")))
                      : bloc.activityList.isEmpty
                          ? Center(
                              child: TextButton(
                                child: const Text("Retry"),
                                onPressed: () => bloc.add(GetMyAcivityEvent()),
                              ),
                            )
                          : Expanded(
                              child: ListView.separated(
                                  itemCount: bloc.activityList.length,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  separatorBuilder: (context, index) =>
                                      Container(
                                          color: Colors.grey[300]!, height: 1),
                                  itemBuilder: (context, index) =>
                                      MyActiviyItemView(
                                          index, bloc.activityList[index])),
                            )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class MyActiviyItemView extends StatelessWidget {
  final int index;
  final MyActivityDataList item;

  const MyActiviyItemView(this.index, this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Colors.white,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 1.sw,
                  height: 5,
                ),
                Text(
                  "Activity : ${item.activityName.toUpperCase()}",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600, color: Colors.blue),
                ),
                Text(
                  "Activity On : ${item.storeName}",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600, color: Colors.black),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    "Time : ${item.time}",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                )
              ],
            )));
  }
}
