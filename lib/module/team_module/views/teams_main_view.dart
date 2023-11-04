import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/team_module/bloc/team_bloc.dart';
import 'package:i_densfa/module/team_module/views/team_hierarchy_view.dart';
import 'package:i_densfa/module/team_module/views/team_list_view.dart';
import 'package:i_densfa/utility/extensions.dart';

class TeamMainView extends StatelessWidget {
  const TeamMainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Team'),
          backgroundColor: Colors.grey.shade800,
        ),
        body: BlocProvider(
          lazy: false,
          create: (context) => TeamBloc()..add(GetTeamMembersEvent()),
          child: BlocConsumer<TeamBloc, TeamState>(
            listener: (context, state) {
              if (state is SnackbarMessageTeamState) {
                context.showSnackBarMessage(state.message);
              }
            },
            buildWhen: (previous, current) =>
                current is! SnackbarMessageTeamState,
            builder: (context, state) {
              final TeamBloc teamBloc = context.read();
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TeamTabButton(
                          isSelected: teamBloc.isHierarchyView,
                          title: 'Hierarchy View',
                          onPressed: () =>
                              teamBloc.add(ChangeViewStyleTeamEvent(true)),
                        ),
                        const SizedBox(width: 2),
                        TeamTabButton(
                          isSelected: !teamBloc.isHierarchyView,
                          title: 'List View',
                          onPressed: () {
                            teamBloc.add(GetTeamDataEvent());
                            teamBloc.add(ChangeViewStyleTeamEvent(false));
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: teamBloc.isHierarchyView
                        ? const TeamHierarchyView()
                        : const TeamListView(),
                  )
                ],
              );
            },
          ),
        ));
  }
}

class TeamTabButton extends StatelessWidget {
  final String title;
  final void Function()? onPressed;
  final bool isSelected;
  const TeamTabButton({
    super.key,
    required this.title,
    this.onPressed,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            elevation: isSelected ? 4 : 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        onPressed: onPressed,
        child: Text(
          title,
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
