import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:i_densfa/module/survey_module/bloc/survey_bloc.dart';

class SurveyNotesView extends StatelessWidget {
  const SurveyNotesView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  "Notes",
                  style: textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                      onPressed: () {
                        showCupertinoDialog(
                            context: context,
                            builder: (c) => BlocProvider.value(
                                value: context.read<SurveyBloc>(),
                                child: const AddNoteDialogueView()));
                      },
                      icon: const Icon(
                        Icons.add,
                        color: Colors.green,
                      )),
                )
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: BlocBuilder<SurveyBloc, SurveyState>(
                builder: (context, state) {
                  final bloc = context.read<SurveyBloc>();
                  final notes = bloc.surveyNotesList;

                  return notes.isEmpty
                      ? const Center(child: Text("No note added"))
                      : AnimationLimiter(
                          child: ListView.separated(
                            itemCount: notes.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) =>
                                AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: ColoredBox(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withValues(alpha: 0.1),
                                    child: ListTile(
                                      tileColor: Theme.of(context)
                                          .primaryColor
                                          .withValues(alpha: 0.2),
                                      title: Text(notes[index].note),
                                      trailing: IconButton(
                                          onPressed: () {
                                            bloc.add(DeleteNotesEvent(
                                                notes[index].noteId));
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          )),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddNoteDialogueView extends StatefulWidget {
  const AddNoteDialogueView({super.key});

  @override
  State<AddNoteDialogueView> createState() => _AddNoteDialogueViewState();
}

class _AddNoteDialogueViewState extends State<AddNoteDialogueView> {
  final noteTextEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: AlertDialog(
        title: const Text("Add Note"),
        content: TextField(
          controller: noteTextEditingController,
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp('(’|‘|”|“||<|>|)')),
          ],
          maxLines: 5,
          maxLength: 150,
          decoration: const InputDecoration(
              hintText: 'Please enter note here..',
              border: OutlineInputBorder()),
        ),
        actions: [
          MaterialButton(
              padding: EdgeInsets.zero,
              child: const Text("Save"),
              onPressed: () {
                context.read<SurveyBloc>().add(
                    CreateNotesEvent(comment: noteTextEditingController.text));
                Navigator.pop(context);
              }),
          MaterialButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.red),
              ))
        ],
      ),
    );
  }
}
