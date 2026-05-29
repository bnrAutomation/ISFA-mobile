part of 'store_detail_bloc.dart';

@immutable
abstract class StoreDetailEvent {}

class GotoCampaignEvent extends StoreDetailEvent {}

final class MarkInStoreDetailEvent extends StoreDetailEvent {
  final BuildContext context;
  MarkInStoreDetailEvent(this.context);
}

class MarkOutStoreDetailEvent extends StoreDetailEvent {
  final BuildContext context;
  MarkOutStoreDetailEvent(this.context);
}

class ChangeStateEvent extends StoreDetailEvent {}

class GetCampaignFilledEvent extends StoreDetailEvent {}

class GetStoreDetailsEvent extends StoreDetailEvent {}

class GetFeedbackEvent extends StoreDetailEvent {}

class SaveNoteStoreDetailEvent extends StoreDetailEvent {}

class DeleteNoteStoreDetailEvent extends StoreDetailEvent {
  final int noteId;

  DeleteNoteStoreDetailEvent(this.noteId);
}

class ShowStoreOnMapStoreDetailEvent extends StoreDetailEvent {}

class CallStoreDetailEvent extends StoreDetailEvent {}

final class MarkingWithImage extends StoreDetailEvent {
  final XFile file;
  MarkingWithImage(this.file);
}

final class MarkOutWithImage extends StoreDetailEvent {
  final XFile file;
  MarkOutWithImage(this.file);
}
