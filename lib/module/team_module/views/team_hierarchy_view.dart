import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/module/team_module/bloc/team_bloc.dart';
import 'package:i_densfa/module/team_module/models/team_list_model.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';

class TeamHierarchyView extends StatelessWidget {
  const TeamHierarchyView({super.key});

  @override
  Widget build(BuildContext context) {
    final ids = context.read<TeamBloc>().subTeamNavIds;
    final treeController = TreeController<TeamNode>(
      roots: [
        TeamNode(
            teamLead: TeamMemberModel.fromJson({
              "userId": ids.isEmpty ? AppStorage().userDetail!.id : ids.last,
              "email": "ayooshkr@gmail.com",
              "username": "ayooshkr@gmail.com",
              "designation": "fwp",
              "role": "user",
              "mobile": "9988776676",
              "uuid": "MjhmZmJiMGMtNzQyMi00OTNlLTlhOTUtYTQ2ZTgwNWFmZmFl",
              "doj": "2022-07-30"
            }),
            team: context
                .select((TeamBloc value) => value.selectedTeamMembers)
                .map((e) => TeamNode(teamLead: e))
                .toList()),
      ],
      childrenProvider: (TeamNode node) => node.team,
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TreeView<TeamNode>(
        treeController: treeController,
        nodeBuilder: (BuildContext context, TreeEntry<TeamNode> entry) {
          return MyTreeTile(
            key: ValueKey(entry.node),
            entry: entry,
            onTap: () {
              if (entry.level == 0) {
                treeController.toggleExpansion(entry.node);
              } else {
                final TeamBloc bloc = context.read();
                bloc.add(
                    GetTeamMembersEvent(userId: entry.node.teamLead.userId));
              }
            },
          );
        },
      ),
    );
  }
}

class MyTreeTile extends StatelessWidget {
  const MyTreeTile({
    super.key,
    required this.entry,
    required this.onTap,
  });

  final TreeEntry<TeamNode> entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final memberDetail = entry.node.teamLead;
    return InkWell(
      onTap: onTap,
      child: TreeIndentation(
        entry: entry,
        guide:
            const IndentGuide.connectingLines(color: ColorConstants.amberFade),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Card(
                color: Colors.white,
                elevation: 4,
                shadowColor: ColorConstants.amberFade,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      if (entry.level == 0 &&
                          entry.node.teamLead.userId !=
                              AppStorage().userDetail?.id)
                        IconButton.filled(
                            onPressed: () => context
                                .read<TeamBloc>()
                                .add(GoUpperLevelTeamEvent()),
                            icon: const Icon(Icons.keyboard_backspace)),
                      const CircleAvatar(radius: 35),
                      SizedBox(width: 5.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            memberDetail.username,
                            style: TextStyle(
                                fontSize: 18.sp, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Designation:${memberDetail.designation}',
                            style: TextStyle(
                                fontSize: 12.sp, fontWeight: FontWeight.normal),
                          ),
                          Text(
                            'Role:${memberDetail.role}',
                            style: TextStyle(
                                fontSize: 11.sp, fontWeight: FontWeight.w300),
                          ),
                          ColoredBox(
                              color: ColorConstants.amberFade,
                              child: Text(
                                memberDetail.mobile,
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.normal),
                              )),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            if (entry.level == 0)
              IconButton(
                color: ColorConstants.amber,
                icon: const Icon(Icons.notification_add),
                onPressed: () {
                  notificationDialogView(
                      context, entry.node.teamLead.userId, context.read());
                },
              )
          ],
        ),
      ),
    );
  }

  Future<dynamic> notificationDialogView(
      BuildContext context, int userId, TeamBloc bloc) {
    final textController = TextEditingController();
    return showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          elevation: 2,
          shadowColor: ColorConstants.amber,
          surfaceTintColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white60,
                    borderRadius: BorderRadius.circular(12.w),
                    border: Border.all(color: ColorConstants.amber, width: 1),
                  ),
                  child: TextField(
                    controller: textController,
                    minLines: 7,
                    maxLines: 10,
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        iconSize: 30,
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.red,
                        )),
                    BlocProvider.value(
                      value: bloc,
                      child: BlocListener<TeamBloc, TeamState>(
                        listener: (context, state) {
                          if (state is NotificationSentSuccessTeamState) {
                            Navigator.pop(context);
                          }
                        },
                        child: IconButton(
                            onPressed: () {
                              bloc.add(SendNotificationTeamEvent(
                                  textController.text, userId));
                            },
                            iconSize: 30,
                            icon: const Icon(
                              Icons.send,
                              color: Colors.green,
                            )),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class TeamNode {
  const TeamNode({
    required this.teamLead,
    this.team = const <TeamNode>[],
  });

  final TeamMemberModel teamLead;
  final List<TeamNode> team;
}
