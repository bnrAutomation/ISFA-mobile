import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/issues_management_module/issues_list_module/issues_management_repository.dart';
import 'package:i_densfa/module/issues_management_module/issues_list_module/model/issues_ticket_model.dart';
import 'package:i_densfa/utility/base_bloc.dart';
import 'package:i_densfa/utility/debouncer.dart';

part 'issues_management_event.dart';
part 'issues_management_state.dart';

class IssuesManagementBloc
    extends BaseBloc<IssuesManagementEvent, IssuesManagementState> {
  IssuesManagementRepository repository;
  List<IssuesTicketModel> issuesTicketList = [];
  List<IssuesTicketModel> filterIssuesTicketList = [];
  final debouncer = Debouncer(duration: const Duration(milliseconds: 500));
  String? selectedStatus;
  String? afterImage;
  String? reopenBeforeImage;
  String? reopenAfterImage;

  bool selectedBefore = true;
  bool selectedrepronBefore = true;
  DateTime fromDate = DateTime.now().subtract(const Duration(days: 120));
  DateTime toDate = DateTime.now();
  int pageCount = 0;
  int pageOffset = 0;
  ScrollController controller = ScrollController();
  bool isLoad = false;
  String selectedFilter = "Status";
  bool isFromfilter = false;
  Map<String, String> param = {};
  List<String> filter = [
    "Status",
    "Ticket No.",
    'Store Code',
    'Store Name',
    "Issue Category",
    "Issue Sub-Category",
  ];

  bool selectAll = false;
  bool multiselect = false;
  IssuesManagementBloc(this.repository) : super(IssuesManagementInitial()) {
    controller.addListener(_scrollListener);
    on<IssuesManagementEvent>((event, emit) {});
    on<GetIssuesEvent>(
        (event, emit) async => await _getIssuesList(event, emit));
    on<GetNextIssuesEvent>(
        (event, emit) async => await _getNextIssuesList(event, emit));

    on<FromDateIssuesEvent>((event, emit) {
      fromDate = event.dateTime;
      toDate = event.dateTime;
      emit(DataChangeState());
    });
    on<ToDateIssuesEvent>((event, emit) {
      toDate = event.dateTime;
      emit(DataChangeState());
    });
    on<DataChangeEvent>((event, emit) => emit(DataChangeState()));
    on<SearchEvent>((event, emit) async => await _searchBy(event, emit));
    on<AcceptIssueEvent>(
        (event, emit) async => await _acceptIssues(event, emit));
    on<GetFilterIssuesEvent>(
        (event, emit) async => await _getIssuesListbyFilter(event, emit));
    on<GetNextFilterIssuesEvent>(
        (event, emit) async => await _getNextIssuesListbyFilter(event, emit));
  }
  _acceptIssues(
      AcceptIssueEvent event, Emitter<IssuesManagementState> emit) async {
    if (!filterIssuesTicketList.any((element) => element.selected)) {
      emit(IssuesManagementShowError("Please choose ticket before accept it."));
      return;
    }
    try {
      final body = {
        "ids": filterIssuesTicketList
            .where((item) => item.selected)
            .map((elementId) => elementId.id)
            .toList(),
        "status": "In Progress"
      };

      emit(AcceptIssueLoading());
      await repository.acceptIssues(body);
      multiselect = false;
      emit(AcceptIssueSuccess());
    } catch (err) {
      emit(IssuesManagementShowError(err.toString()));
    }
  }

  void _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      isFromfilter
          ? add(GetNextFilterIssuesEvent(pageOffset++))
          : add(GetNextIssuesEvent(pageOffset++));
    }
  }

  _searchBy(SearchEvent event, Emitter<IssuesManagementState> emit) {
    param = {
      "page": pageOffset.toString(),
      "size": 15.toString(),
      "sortBy": "ticketDate",
      "order": "desc",
    };
    isFromfilter = true;
    if (event.value.isNotEmpty) {
      switch (selectedFilter) {
        case "Status":
          param["status"] = event.value;

        case "Ticket No.":
          param["ticketNo"] = event.value;

        case "Store Code":
          param["storeCode"] = event.value;

        case "Store Name":
          param["storeName"] = event.value;

        case "Issue Category":
          param["issueCategory"] = event.value;

        case "Issue Sub-Category":
          param["issueSubcategory"] = event.value;
      }
      add(GetFilterIssuesEvent(param));
    } else {
      isFromfilter = false;
      add(GetIssuesEvent());
    }
    emit(SuccessfullyIssuesManagementState());
  }

  _getNextIssuesList(
      GetNextIssuesEvent event, Emitter<IssuesManagementState> emit) async {
    try {
      if (pageOffset > pageCount) {
        pageOffset = pageCount;
        return;
      } else if (pageOffset < 0) {
        pageOffset = 0;
      }
      isLoad = true;
      //  emit(IssuesManagementLoading());
      final response = await repository.getIssuesManagementList(
          fromDate, toDate, pageOffset);
      filterIssuesTicketList.addAll(response.content);
      issuesTicketList.addAll(response.content);
      pageCount = response.totalPages;
      isLoad = false;
      emit(SuccessfullyIssuesManagementState());
    } catch (err) {
      isLoad = false;
      emit(IssuesManagementShowError(err.toString()));
    }
  }

  _getIssuesList(
      GetIssuesEvent event, Emitter<IssuesManagementState> emit) async {
    try {
      emit(IssuesManagementLoading());
      pageOffset = 0;
      final response = await repository.getIssuesManagementList(
          fromDate, toDate, pageOffset);
      filterIssuesTicketList = response.content;
      issuesTicketList = response.content;
      pageCount = response.totalPages;
      emit(SuccessfullyIssuesManagementState());
    } catch (err) {
      emit(IssuesManagementShowError(err.toString()));
    }
  }

  _getNextIssuesListbyFilter(GetNextFilterIssuesEvent event,
      Emitter<IssuesManagementState> emit) async {
    try {
      if (pageOffset > pageCount) {
        pageOffset = pageCount;
        return;
      } else if (pageOffset < 0) {
        pageOffset = 0;
      }
      isLoad = true;
      param["page"] = pageOffset.toString();
      emit(IssuesManagementLoading());
      final response = await repository.getIssuesManagementListByParm(param);
      filterIssuesTicketList = response.content;
      issuesTicketList = response.content;
      pageCount = response.totalPages;
      emit(SuccessfullyIssuesManagementState());
    } catch (err) {
      emit(IssuesManagementShowError(err.toString()));
    }
  }

  _getIssuesListbyFilter(
      GetFilterIssuesEvent event, Emitter<IssuesManagementState> emit) async {
    try {
      emit(IssuesManagementLoading());
      pageOffset = 0;
      final response =
          await repository.getIssuesManagementListByParm(event.param);
      filterIssuesTicketList = response.content;
      issuesTicketList = response.content;
      pageCount = response.totalPages;
      emit(SuccessfullyIssuesManagementState());
    } catch (err) {
      emit(IssuesManagementShowError(err.toString()));
    }
  }
}
