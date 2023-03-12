part of 'upload_selfie_bloc.dart';

@immutable
abstract class UploadSelfieEvent {}

class UploadSelfieControllerReadyEvent extends UploadSelfieEvent {}

class UploadSelfieFlashChangeEvent extends UploadSelfieEvent {}
