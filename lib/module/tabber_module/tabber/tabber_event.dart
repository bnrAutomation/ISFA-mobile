part of 'tabber_bloc.dart';

@immutable
abstract class TabberEvent {}

class ChangeTabEvent extends TabberEvent {
  final int selectIndex;
  ChangeTabEvent(this.selectIndex);
}
