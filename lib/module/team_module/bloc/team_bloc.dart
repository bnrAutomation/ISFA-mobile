import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/team_module/models/team_data_model.dart';
import 'package:i_densfa/module/team_module/models/team_list_model.dart';
import 'package:i_densfa/module/team_module/team_repository.dart';

part 'team_event.dart';
part 'team_state.dart';

class TeamBloc extends Bloc<TeamEvent, TeamState> {
  bool isHierarchyView = true;
  final repo = TeamRepository();
  TeamListResponse? selectedTeam;
  List<TeamMemberModel> myTeamMembers = [];
  List<TeamMemberModel> myTeamMembersFiltered = [];
  List<int> subTeamNavIds = [];
  TeamDataModel? teamData;
  TeamBloc() : super(TeamInitial()) {
    on((ChangeViewStyleTeamEvent event, emit) {
      isHierarchyView = event.isHierarchyView;
      emit(ViewStyleChangedTeamState());
    });

    on((GetTeamMembersEvent event, emit) async {
      try {
        final team = await repo.getTeamMembers(event.userId);
        selectedTeam = team;
        if (event.userId == null) {
          myTeamMembers = team.dataList;
          myTeamMembersFiltered = team.dataList;
        } else {
          if (!subTeamNavIds.contains(event.userId!)) {
            subTeamNavIds.add(event.userId!);
          }
        }
        emit(ViewStyleChangedTeamState());
      } catch (e) {
        emit(SnackbarMessageTeamState(e.toString()));
      }
    });
    on((GetTeamDataEvent event, emit) async {
      try {
        teamData = await repo.teamData();
        emit(TeamDataUpdatedTeamState());
      } catch (e) {
        emit(SnackbarMessageTeamState(e.toString()));
      }
    });

    on((SearchTeamEvent event, emit) {
      myTeamMembersFiltered = myTeamMembers.where((element) {
        final containsUserName = element.username
            .toLowerCase()
            .contains(event.searchText.trim().toLowerCase());

        final containsEmail = element.email
            .toLowerCase()
            .contains(event.searchText.trim().toLowerCase());
        return containsEmail || containsUserName;
      }).toList();
      emit(TeamDataUpdatedTeamState());
    });

    on((GoUpperLevelTeamEvent event, emit) {
      subTeamNavIds.removeLast();
      if (subTeamNavIds.isEmpty) {
        add(GetTeamMembersEvent());
      } else {
        add(GetTeamMembersEvent(userId: subTeamNavIds.last));
      }
    });

    on((SendNotificationTeamEvent event, emit) async {
      if (event.message.trim().isEmpty) {
        emit(SnackbarMessageTeamState('Please add message to send'));
      } else if (selectedTeam != null) {
        try {
          final message = await repo.sendNotification(
              title: "",
              message: event.message.trim(),
              userIds: selectedTeam!.dataList.map((e) => e.userId).toList(),
              leadUserId: selectedTeam!.supervisiorDetails.userId);
          emit(SnackbarMessageTeamState(message));
          emit(NotificationSentSuccessTeamState());
        } catch (e) {
          emit(SnackbarMessageTeamState(e.toString()));
        }
      }
    });
  }
}
