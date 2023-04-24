part of 'store_detail_bloc.dart';

@immutable
abstract class StoreDetailEvent {}

class GotoCompaignEvent extends StoreDetailEvent {}

class MarkInStoreDetailEvent extends StoreDetailEvent {}

class MarkOutStoreDetailEvent extends StoreDetailEvent {}

class GetStoreDetailsEvent extends StoreDetailEvent {}

class SaveNoteStoreDetailEvent extends StoreDetailEvent {}

class DeleteNoteStoreDetailEvent extends StoreDetailEvent {
  final int noteId;

  DeleteNoteStoreDetailEvent(this.noteId);
}

class ShowStoreOnMapStoreDetailEvent extends StoreDetailEvent {}

class CallStoreDetailEvent extends StoreDetailEvent {}
