import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/issues_management_module/issues_detail_module/issues_management_detail_repository.dart';
import 'package:i_densfa/module/issues_management_module/issues_list_module/model/issues_ticket_model.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';

part 'issue_management_detail_event.dart';
part 'issue_management_detail_state.dart';

class IssueManagementDetailBloc
    extends Bloc<IssueManagementDetailEvent, IssueManagementDetailState> {
  IssuesManagementDetailRepository repository;
  IssuesTicketModel? selectedTicket;
  String? selectedStatus;
  String ticketId;
  bool selectedBefore = true;
  bool selectedrepronBefore = true;
  String? afterImage;
  String? reopenBeforeImage;
  String? reopenAfterImage;
  // List<String> statusList = ['In Progress', 'Resolved', 'Not an issue'];
  IssueManagementDetailBloc(this.repository, this.ticketId)
      : super(IssueManagementDetailInitial()) {
    on<IssueManagementDetailEvent>((event, emit) {});
    on<DataChangeEvent>((event, emit) => emit(DataChangeState()));
    on<GetTicketDetailEvent>(
        (event, emit) async => await _getTicketDetails(event, emit));

    on<SubmitTicketEvent>(
        (event, emit) async => await _submitDetails(event, emit));
    on<AcceptIssueEvent>(
        (event, emit) async => await _acceptIssues(event, emit));
  }

  _acceptIssues(
      AcceptIssueEvent event, Emitter<IssueManagementDetailState> emit) async {
    try {
      final body = {
        "ids": [selectedTicket?.id.toString()],
        "status": "In Progress"
      };
      emit(AcceptIssueLoading());
      await repository.acceptIssues(body);
      emit(AcceptIssueSuccess());
      add(GetTicketDetailEvent());
    } catch (err) {
      emit(IssueManagementDetailErroState(err.toString()));
    }
  }

  Future<void> _submitDetails(
      SubmitTicketEvent event, Emitter<IssueManagementDetailState> emit) async {
    try {
      final changeStatus = selectedStatus ?? selectedTicket?.status ?? "";
      if (selectedTicket?.afterImage == null ||
          (selectedTicket?.afterImage ?? "").isEmpty ||
          !(selectedTicket?.afterImage ?? "").urlValid()) {
        emit(IssueManagementDetailErroState("Please add after image."));
        return;
      }
      if (changeStatus == 'Re-Open') {
        if (selectedTicket?.reopenBeforeImage == null ||
            (selectedTicket?.reopenBeforeImage ?? "").isEmpty ||
            !(selectedTicket?.reopenBeforeImage ?? "").urlValid()) {
          emit(IssueManagementDetailErroState(
              "Please add re-open before image."));
          return;
        }
      }
      if ((selectedTicket?.hasReopen ?? false)) {
        if (selectedTicket?.reopenAfterImage == null ||
            (selectedTicket?.reopenAfterImage ?? "").isEmpty ||
            !(selectedTicket?.reopenAfterImage ?? "").urlValid()) {
          emit(IssueManagementDetailErroState(
              "Please add re-open after image."));
          return;
        }
      }

      emit(SubmitStatusLoading());
      final response = await repository.submitTicketDetails(
        selectedTicket?.id.toString() ?? "",
        selectedStatus ?? selectedTicket?.status ?? "",
        afterImage ?? selectedTicket?.afterImage,
        reopenBeforeImage ?? selectedTicket?.reopenBeforeImage,
        reopenAfterImage ?? selectedTicket?.reopenAfterImage,
      );
      if (response) {
        emit(SubmitStatusSuccessfully());
      } else {
        emit(IssueManagementDetailErroState("Something went wrong"));
      }
    } catch (err) {
      emit(IssueManagementDetailErroState(err.toString()));
    }
  }

  Future<void> _getTicketDetails(GetTicketDetailEvent event,
      Emitter<IssueManagementDetailState> emit) async {
    try {
      emit(IssueManagementDetailLoading());
      final response = await repository.getTicketDetails(ticketId.toString());
      selectedTicket = response;
      selectedStatus = selectedTicket?.status;
      emit(SuccessfulIssueManagementDetailLoadState());
    } catch (err) {
      emit(IssueManagementDetailErroState(err.toString()));
    }
  }

  List<String> getStatusList(String status, bool hasreopen) {
    String role = AppStorage().userDetail?.role ?? "";
    List<String> list = <String>[];
    if (role.toLowerCase().trim() == "stakeholder") {
      list = <String>['In Progress', 'Resolved', 'Not an issue'];
      switch (status) {
        case 'open':
          list = <String>['In Progress', 'Resolved', 'Not an issue'];
        case "Re-Open":
          list = <String>[];
        case "Resolved" || "Not an issue":
          list = <String>[status];
        case "Closed":
          list = <String>[status];
      }
    } else if (["manager", "auditor"].contains(role.toLowerCase().trim())) {
      list = <String>['Re-Open', "Closed"];
      switch (status) {
        case "Resolved" || "Not an issue":
          list = hasreopen
              ? <String>[status, "Closed"]
              : <String>[status, "Re-Open", "Closed"];
        case "Closed":
          list = <String>[status];
      }
    } else {
      list = <String>['In Progress', 'Resolved', 'Not an issue', "Closed"];
      switch (status) {
        case 'open' || "Re-Open":
          list = <String>['In Progress', 'Resolved', 'Not an issue'];
        case "Resolved" || "Not an issue":
          list = <String>[status, "Re-Open", "Closed"];
        case "Closed":
          list = <String>[status];
      }
    }
    return list;
  }
}
