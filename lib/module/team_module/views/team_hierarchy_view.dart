import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/module/team_module/bloc/team_bloc.dart';
import 'package:i_densfa/module/team_module/models/team_list_model.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';

class TeamHierarchyView extends StatelessWidget {
  const TeamHierarchyView({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedTeam = context.select((TeamBloc value) => value.selectedTeam);
    final treeController = TreeController<TeamNode>(
      roots: [
        if (selectedTeam != null)
          TeamNode(
              teamLead: selectedTeam.supervisiorDetails,
              team: selectedTeam.dataList
                  .map((e) => TeamNode(teamLead: e))
                  .toList()),
      ],
      childrenProvider: (TeamNode node) => node.team,
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          if (selectedTeam != null)
            Row(
              children: [
                if (selectedTeam.supervisiorDetails.userId !=
                    AppStorage().userDetail?.id)
                  Ink(
                    decoration: const ShapeDecoration(
                      color: ColorConstants.amber,
                      shape: CircleBorder(),
                    ),
                    child: IconButton(
                        color: Colors.white,
                        onPressed: () => context
                            .read<TeamBloc>()
                            .add(GoUpperLevelTeamEvent()),
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 30,
                        )),
                  ),
                const Spacer(),
                Ink(
                  decoration: const ShapeDecoration(
                    color: ColorConstants.amber,
                    shape: CircleBorder(),
                  ),
                  child: IconButton(
                    color: Colors.white,
                    focusColor: Colors.red,
                    icon: const Icon(Icons.notification_add),
                    onPressed: () {
                      notificationDialogView(
                          context,
                          selectedTeam.supervisiorDetails.userId,
                          context.read());
                    },
                  ),
                )
              ],
            ),
          Expanded(
            child: TreeView<TeamNode>(
              treeController: treeController..expandAll(),
              nodeBuilder: (BuildContext context, TreeEntry<TeamNode> entry) {
                return MyTreeTile(
                  key: ValueKey(entry.node),
                  entry: entry,
                  onTap: () {
                    if (entry.level == 0) {
                      treeController.toggleExpansion(entry.node);
                    } else {
                      final TeamBloc bloc = context.read();
                      bloc.add(GetTeamMembersEvent(
                          userId: entry.node.teamLead.userId));
                    }
                  },
                );
              },
            ),
          ),
        ],
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
        child: Card(
          color: Colors.white,
          elevation: 4,
          shadowColor: ColorConstants.amberFade,
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(8, 8, 38.w, 8),
                child: Row(
                  children: [
                    CircleAvatar(
                        radius: 35,
                        backgroundImage: CachedNetworkImageProvider(
                            memberDetail.photoUrl ?? '')),
                    SizedBox(width: 5.w),
                    Expanded(
                      child: Column(
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
                      ),
                    )
                  ],
                ),
              ),
              IconButton(
                  color: ColorConstants.amber,
                  iconSize: 30.w,
                  onPressed: () =>
                      context.push(AppPaths.teamProfile, extra: memberDetail),
                  icon: const Icon(Icons.info))
            ],
          ),
        ),
      ),
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
