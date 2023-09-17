part of 'help_bloc.dart';

@immutable
sealed class HelpState {}

final class HelpInitial extends HelpState {}

class HelpLoadingState extends HelpState {}

class HelpSuccessState extends HelpState {}

class HelpErrorState extends HelpState {
  final String errorMessage;

  HelpErrorState(this.errorMessage);
}
