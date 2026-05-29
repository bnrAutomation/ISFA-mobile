import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/module/issues_management_module/issues_list_module/issuesManagement/issues_management_bloc.dart';
import 'package:i_densfa/module/issues_management_module/issues_list_module/issues_management_repository.dart';
import 'package:i_densfa/module/issues_management_module/issues_list_module/model/issues_ticket_model.dart';
import 'package:i_densfa/module/ui/app_pop_view.dart';
import 'package:i_densfa/module/ui/custom_button.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_storage.dart';

import 'package:i_densfa/utility/extensions.dart';

class IssuesManagementView extends StatelessWidget {
  final String name;
  const IssuesManagementView({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => IssuesManagementRepository(),
      child: BlocProvider(
        create: (context) =>
            IssuesManagementBloc(context.read())..add(GetIssuesEvent()),
        child: BlocConsumer<IssuesManagementBloc, IssuesManagementState>(
          listener: (context, state) {
            if (state is IssuesManagementShowError) {
              context.showSnackBarMessage(state.message);
            }
          },
          builder: (context, state) {
            final bloc = context.read<IssuesManagementBloc>();
            bool canSelect = ["admin", "stakeholder"]
                .contains(AppStorage().userDetail?.role.toLowerCase());
            return Scaffold(
                appBar: AppBar(title: Text(name)),
                floatingActionButton: FloatingActionButton.small(
                  onPressed: () {
                    AppPopup.showAppBottomSheet(
                      context: context,
                      child: BlocProvider.value(
                        value: bloc,
                        child: const FilterFormView(),
                      ),
                    );
                  },
                  backgroundColor: Colors.amber,
                  child: const Icon(
                    Icons.filter_list_outlined,
                    color: Colors.black,
                  ),
                ),
                body: RefreshIndicator(
                  onRefresh: () async => bloc.isFromfilter
                      ? bloc.add(GetFilterIssuesEvent(bloc.param))
                      : bloc.add(GetIssuesEvent()),
                  child: Column(
                    children: [
                      _statusView(context),
                      _filterView(context, bloc),
                      if (canSelect && bloc.multiselect)
                        Row(
                          children: [
                            Checkbox(
                                value: bloc.selectAll,
                                onChanged: (value) {
                                  for (int index = 0;
                                      index <
                                          bloc.filterIssuesTicketList.length;
                                      index++) {
                                    _onSelectChange(
                                        value ?? false,
                                        bloc.filterIssuesTicketList[index],
                                        bloc);
                                  }
                                  bloc.selectAll = value ?? false;
                                  bloc.add(DataChangeEvent());
                                }),
                            Text(
                              "Select All",
                              style: Theme.of(context).textTheme.titleMedium,
                            )
                          ],
                        ),
                      Expanded(
                        child: state is IssuesManagementLoading
                            ? SizedBox(
                                width: 1.sw,
                                height: 0.5.sh,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : AnimationLimiter(
                                child: ListView.separated(
                                    shrinkWrap: true,
                                    controller: bloc.controller,
                                    // physics: const NeverScrollableScrollPhysics(),
                                    itemCount:
                                        bloc.filterIssuesTicketList.length,
                                    padding: const EdgeInsets.all(5),
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 5),
                                    itemBuilder: (context, index) => InkWell(
                                          onLongPress: canSelect
                                              ? () {
                                                  bloc.multiselect =
                                                      !bloc.multiselect;
                                                  bloc.add(DataChangeEvent());
                                                }
                                              : null,
                                          onTap: () {
                                            context
                                                .pushNamed(
                                                    AppPaths.issuesDetail,
                                                    extra: bloc
                                                        .filterIssuesTicketList[
                                                            index]
                                                        .id
                                                        .toString())
                                                .then((value) {
                                              bloc.add(GetIssuesEvent());
                                            });
                                          },
                                          child: AnimationConfiguration
                                              .staggeredList(
                                                  position: index,
                                                  duration: const Duration(
                                                      milliseconds: 500),
                                                  child: SlideAnimation(
                                                    verticalOffset: 50.0,
                                                    child: IssuesTicketListItem(
                                                        bloc.filterIssuesTicketList[
                                                            index]),
                                                  )),
                                        ))),
                      ),
                      Visibility(
                          visible: bloc.isLoad,
                          child: const Center(
                            child: Text("Loading..."),
                          )),
                      bloc.multiselect
                          ? BlocConsumer<IssuesManagementBloc,
                              IssuesManagementState>(
                              listener: (context, state) {
                                if (state is AcceptIssueSuccess) {
                                  bloc.multiselect = false;
                                  bloc.add(GetIssuesEvent());
                                }
                              },
                              builder: (context, state) {
                                return SizedBox(
                                  width: 0.3.sw,
                                  child: CustomButton(
                                      buttonText: "Accept Issue",
                                      onPressed: () =>
                                          {bloc.add(AcceptIssueEvent())},
                                      isLoading: state is AcceptIssueLoading,
                                      isSuccess: state is AcceptIssueSuccess),
                                );
                              },
                            )
                          : const SizedBox()
                    ],
                  ),
                ));
          },
        ),
      ),
    );
  }

  Widget _filterView(BuildContext context, IssuesManagementBloc bloc) {
    return BlocBuilder<IssuesManagementBloc, IssuesManagementState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white, // Background color
              border: Border.all(
                color: Colors.amber, // Border color
                width: .5, // Border width
              ),
              borderRadius: BorderRadius.circular(6.0), // Rounded corners
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    alignment: Alignment.center,
                    value: bloc.selectedFilter,
                    hint: Text(
                      "Select one",
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    items: bloc.filter
                        .map((item) => DropdownMenuItem<String>(
                              value: item,
                              alignment: Alignment.center,
                              child: Text(
                                item,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ))
                        .toList(),
                    onChanged: (filterValue) {
                      bloc.selectedFilter = filterValue ?? "Status";
                      bloc.add(DataChangeEvent());
                    },
                    // isExpanded: true, // Ensures the dropdown takes the full width
                  ),
                ),
                Container(
                  width: 1.sp,
                  height: 30.sp,
                  color: Colors.amber,
                ),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                      style: Theme.of(context).textTheme.labelSmall,
                      onChanged: (value) {
                        bloc.debouncer.run(() {
                          bloc.add(SearchEvent(value));
                        });
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          CupertinoIcons.search,
                          color: Colors.black,
                          size: 18,
                        ),
                        border: InputBorder.none, // Removes the underline
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 15.0),
                        hintText: "Search for ${bloc.selectedFilter}",
                        hintStyle: Theme.of(context).textTheme.labelSmall,
                        iconColor: Colors.white,
                      )),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statusView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          singleStatus(context, Colors.white, "Open"),
          singleStatus(context, Colors.blue, "In Progress"),
          singleStatus(context, Colors.green, "Resolved"),
          singleStatus(context, Colors.red, "Not an Issue"),
          singleStatus(context, Colors.orange, "Re-Open"),
          singleStatus(context, Colors.grey, "Closed"),
        ],
      ),
    );
  }

  Widget singleStatus(BuildContext context, Color colors, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Container(
            width: 10.sp,
            height: 10.sp,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              shape: BoxShape.circle,
              color: colors,
            ),
          ),
          const SizedBox(
            width: 3,
          ),
          Text(
            status,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}

_onSelectChange(
    bool value, IssuesTicketModel issuesTicketList, IssuesManagementBloc bloc) {
  if (value) {
    if ((issuesTicketList.status.toLowerCase().trim() ==
            'Re-Open'.toLowerCase().trim() ||
        issuesTicketList.status.toLowerCase().trim() == 'open')) {
      issuesTicketList.selected = true;
    }
  } else {
    if ((issuesTicketList.status.toLowerCase().trim() ==
            'Re-Open'.toLowerCase().trim() ||
        issuesTicketList.status.toLowerCase().trim() == 'open')) {
      issuesTicketList.selected = false;
    }
  }
  bloc.selectAll =
      bloc.filterIssuesTicketList.any((element) => element.selected);
  bloc.add(DataChangeEvent());
}

class IssuesTicketListItem extends StatelessWidget {
  final IssuesTicketModel issuesTicketList;
  const IssuesTicketListItem(this.issuesTicketList, {super.key});

  Color _getStatusColor(String status, BuildContext context) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.white;
      case 'in progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'not an issue':
        return Colors.red;
      case 're-open':
        return Colors.orange;
      case 'closed':
        return Colors.grey;
    }
    return Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<IssuesManagementBloc, IssuesManagementState>(
      listener: (context, state) {},
      builder: (context, state) {
        final bloc = context.read<IssuesManagementBloc>();
        bool canSelect = ["admin", "stakeholder"]
            .contains(AppStorage().userDetail?.role.toLowerCase());
        return Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
                side: BorderSide(
                    color: _getStatusColor(issuesTicketList.status, context),
                    width: 3.0),
                borderRadius: BorderRadius.circular(10.r)),
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: ListTile(
                  leading: (canSelect && bloc.multiselect)
                      ? Checkbox(
                          value: issuesTicketList.selected,
                          onChanged: (value) {
                            _onSelectChange(
                                value ?? false, issuesTicketList, bloc);
                          })
                      : Icon(
                          Icons.store,
                          size: 34.sp,
                          color: Colors.amber,
                        ),
                  title: Text("Ticket NO.: ${issuesTicketList.ticketNo}",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Issue Date:",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Text(
                                issuesTicketList.ticketDate
                                        ?.toStringFormat("dd-MMM-yyyy") ??
                                    "NA",
                                style: Theme.of(context).textTheme.titleMedium),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Due Date:",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Text(
                                issuesTicketList.dueDate
                                        ?.toStringFormat("dd-MMM-yyyy") ??
                                    "NA",
                                style: Theme.of(context).textTheme.titleMedium),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Store Code:",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Text(issuesTicketList.storeCode.toString(),
                                style: Theme.of(context).textTheme.titleMedium),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Store Name:",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Text(issuesTicketList.storeName,
                                style: Theme.of(context).textTheme.titleMedium),
                          )
                        ],
                      ),
                      issuesTicketList.status != 'open'
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Status:",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold)),
                                const SizedBox(
                                  width: 10,
                                ),
                                Flexible(
                                  child: Text(
                                      issuesTicketList.status.toUpperCase(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: _getStatusColor(
                                                  issuesTicketList.status,
                                                  context))),
                                )
                              ],
                            )
                          : const SizedBox.shrink()
                    ],
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 14.sp,
                    color: Colors.grey,
                  ),
                )));
      },
    );
  }
}

class FilterFormView extends StatefulWidget {
  const FilterFormView({super.key});

  @override
  State<FilterFormView> createState() => _FilterFormViewState();
}

class _FilterFormViewState extends State<FilterFormView> {
  late IssuesManagementBloc bloc;

  @override
  Widget build(BuildContext context) {
    bloc = context.read<IssuesManagementBloc>();
    return BlocConsumer<IssuesManagementBloc, IssuesManagementState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Container(
          width: 1.sw,
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                width: 5,
              ),
              Flexible(
                child: Text(
                  "Search",
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        "Start Date",
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      TextField(
                        textAlign: TextAlign.start,
                        controller: TextEditingController(
                            text: bloc.fromDate.toStringFormat("dd/MM/yyyy")),
                        decoration: const InputDecoration(
                            suffixIcon: Icon(Icons.calendar_month),
                            border: OutlineInputBorder(),
                            hintText: "DD/MM/YY"),
                        readOnly: true,
                        onTap: () => _selectFromDate(context, bloc),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  )),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        "End Date",
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      TextField(
                        textAlign: TextAlign.start,
                        controller: TextEditingController(
                            text: bloc.toDate.toStringFormat("dd/MM/yyyy")),
                        decoration: const InputDecoration(
                            suffixIcon: Icon(Icons.calendar_month),
                            border: OutlineInputBorder(),
                            hintText: "DD/MM/YY"),
                        readOnly: true,
                        onTap: () async {
                          //final now = DateTime.now();
                          final date = await showDatePicker(
                              context: context,
                              initialDate: bloc.fromDate,
                              firstDate: bloc.fromDate,
                              lastDate:
                                  bloc.fromDate.add(const Duration(days: 20)));
                          if (date != null && context.mounted) {
                            bloc.add(ToDateIssuesEvent(date));
                          }
                        },
                      ),
                    ],
                  )),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: CustomButton(
                      buttonText: "Search",
                      onPressed: () {
                        bloc.add(GetIssuesEvent());
                        context.pop();
                      },
                      isLoading: false,
                      isSuccess: false,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: CustomButton(
                      buttonColor: Colors.grey,
                      buttonText: "Reset",
                      onPressed: () {
                        bloc.fromDate =
                            DateTime.now().subtract(const Duration(days: 5));
                        bloc.toDate =
                            DateTime.now().add(const Duration(days: 15));
                        bloc.add(DataChangeEvent());
                      },
                      isLoading: false,
                      isSuccess: false,
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}

_selectFromDate(BuildContext context, IssuesManagementBloc bloc) async {
  final now = DateTime.now();
  final date = await showDatePicker(
      //   selectableDayPredicate: (date) => date.weekday != DateTime.sunday,
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 20)),
      lastDate: now.add(const Duration(days: 20)));
  if (date != null && context.mounted) {
    bloc.add(FromDateIssuesEvent(date));
  }
}
