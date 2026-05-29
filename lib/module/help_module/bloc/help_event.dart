part of 'help_bloc.dart';

@immutable
sealed class HelpEvent {}

class ClickImageHelpEvent extends HelpEvent {
  final String imagePath;

  ClickImageHelpEvent({required this.imagePath});
}

class AddDescriptionHelpEvent extends HelpEvent {
  final String description;

  AddDescriptionHelpEvent(this.description);
}

class AddTitleHelpEvent extends HelpEvent {
  final String title;

  AddTitleHelpEvent(this.title);
}

class HelpSaveEvent extends HelpEvent {}

class RemoveSelectedImageHelpEvent extends HelpEvent {}
