part of 'mystore_bloc.dart';

@immutable
sealed class MystoreState {}

final class MystoreInitial extends MystoreState {}
final class MyStoreLoadingState  extends MystoreState {}
final class MyStoreSussesfully extends MystoreState{}
final class MyStoreShowError extends MystoreState{
  final String message;
  MyStoreShowError(this.message);
}
final class LoadedFillCampainState extends MystoreState{}