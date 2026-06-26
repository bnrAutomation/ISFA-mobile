import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_broadcast_receiver/flutter_broadcast_receiver.dart';
import 'package:geolocator/geolocator.dart';
import 'package:i_densfa/module/tabber_module/models/remote_notification.dart';
import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/module/tabber_module/models/side_menu_model.dart';
import 'package:i_densfa/module/tabber_module/tabbar_repository.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/base_bloc.dart';
import 'package:i_densfa/utility/continuous_location_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'tabbar_event.dart';
part 'tabbar_state.dart';

class TabbarBloc extends BaseBloc<TabbarEvent, TabbarState> {
  final TabbarRepository repo;
  int selectIndex = 0;
  SideMenuModel? sideMenuData;
  final userDetail = AppStorage().userDetail;
  var tabbarItems = TabbarItemCase.values.toList();
  bool _sessionExpiredHandled = false;
  TabbarBloc(BuildContext context, this.repo) : super(TabbarInitial()) {
    tabbarItems.removeWhere((element) => element == TabbarItemCase.settings);
    registerBroadcast(context);
    unawaited(ContinuousLocationService.instance.start());
    on<TabbarEvent>((event, emit) {
      if (event is ChangeTabEvent) {
        selectIndex = event.selectIndex;
        emit(UpdateIndexState(selectIndex));
      }
    });
    on((UpdateSideMenuDetailsEvent event, emit) async =>
        await _getSideMenuData(emit));
    on(_endDuty);
    on(_startDuty);
    on<SubmitToken>((event, emit) => submitToken());
    on(logout);
    on<ShowSectionPopUp>((event, emit) =>
        emit(ShowSectionPopUpState(event.title, event.message)));
    on<ResetPassword>((event, emit) {
      emit(ResetPasswordState());
    });
  }
  @override
  Future<void> onCleanup() async {
    await ContinuousLocationService.instance.stop();
    unRegisterBroadcast();
    await super.onCleanup();
  }

  void unRegisterBroadcast() {
    BroadcastReceiver().unsubscribe(AppConstant.sectionExpire);
    BroadcastReceiver().unsubscribe(AppConstant.tokenupdate);
  }

  void registerBroadcast(BuildContext context) {
    BroadcastReceiver().subscribe<String>(AppConstant.sectionExpire,
        (String message) async {
      if (_sessionExpiredHandled) return;
      _sessionExpiredHandled = true;
      AppRemoteNotification remoteMessage =
          AppRemoteNotification.fromRawJson(message);
      add(ShowSectionPopUp(remoteMessage.title, remoteMessage.body));
    });

    BroadcastReceiver().subscribe<String>(AppConstant.tokenupdate,
        (String message) async {
      add(SubmitToken());
    });
  }

  Future<void> _getSideMenuData(Emitter<TabbarState> emit) async {
    var data = await repo.getSideMenuDetails().catchError((onError) {
      emit(TabbarSnackBarMessageState(onError.toString()));
      return Future<SideMenuModel>.error(onError);
    });
    // data.sideMenu.add(Menu(
    //     name: "Issue Management",
    //     icon: "",
    //     key: "issus_management",
    //     active: true));
    data.sideMenu
        .removeWhere((element) => element.key.toLowerCase() == 'campaign');
    if (data.userInfo.iRole.toLowerCase() != 'promoter') {
      data.sideMenu
          .removeWhere((element) => element.key.toLowerCase() == 'promoter');
    }
    if (AppStorage().userDetail?.companyName.toLowerCase() != "hul") {
      if (data.userInfo.iRole.toLowerCase() != 'fwp' && data.userInfo.iRole.toLowerCase() != "supervisor") {
        tabbarItems
            .removeWhere((element) => element == TabbarItemCase.schedule);
        tabbarItems
            .removeWhere((element) => element == TabbarItemCase.mystore);
      }
    } else {
      if (data.userInfo.iRole.toLowerCase() != 'fwp' &&
          data.userInfo.iRole.toLowerCase() != "supervisor") {
        tabbarItems
            .removeWhere((element) => element == TabbarItemCase.schedule);
        tabbarItems
            .removeWhere((element) => element == TabbarItemCase.mystore);
      }
    }
    data.bottomMenu.removeWhere((element) => element.active == false);
    if (!data.bottomMenu.any((element) =>
        element.key.trim().toLowerCase() == 'myschedule' ||
        element.key.trim().toLowerCase() == 'my-schedule')) {
      tabbarItems.removeWhere((element) => element == TabbarItemCase.schedule);
    }
    if (!data.bottomMenu.any((element) =>
        element.name.trim().toLowerCase() == 'campaign' ||
        element.key.trim().toLowerCase() == 'campaign')) {
      tabbarItems.removeWhere((element) => element == TabbarItemCase.campaign);
    }
    if (!data.bottomMenu.any((element) =>
        element.name.trim().toLowerCase() == 'learn' ||
        element.key.trim().toLowerCase() == 'learn')) {
      tabbarItems.removeWhere((element) => element == TabbarItemCase.learner);
    }
    if (!data.bottomMenu.any((element) =>
        element.name.trim().toLowerCase() == 'analytics' ||
        element.key.trim().toLowerCase() == 'analytics')) {
      tabbarItems.removeWhere((element) => element == TabbarItemCase.analytics);
    }
    if (!data.bottomMenu.any((element) =>
        element.name.trim().toLowerCase() == 'My Store'.trim().toLowerCase() ||
        element.key.trim().toLowerCase() == 'my_store')) {
      tabbarItems.removeWhere((element) => element == TabbarItemCase.mystore);
    }
    if (tabbarItems.isEmpty) {
      tabbarItems.add(TabbarItemCase.settings);
    }

    sideMenuData = data;
    AppStorage().markedInStoreId = data.userInfo.markInStoreId;
    AppStorage().isDutyStarted = data.userInfo.startDuty;
    AppStorage().homeInfo = sideMenuData;
    emit(state);
    if (AppStorage().userDetail?.resetpass == false) {
      add(ResetPassword());
    }
  }

  Future<void> _startDuty(StartDutyStatusTabbarEvent event, emit) async {
    if (AppStorage().markedInStoreId != null) {
      emit(TabbarSnackBarMessageState("Please mark-out from the store first"));
      return;
    }
 
    //  File? modifiedImage;
    if (AppStorage().userDetail?.configuration.requiredSelfieForStartDuty ??
        true) {
      if (event.file == null) {
        emit(TabbarSnackBarMessageState("Please add image"));
        return;
      }
    }
    emit(TabbarShowProgressHudState());
    try {
      final loc =
          await ContinuousLocationService.instance.resolveForSecureAction();
      List<String> latlong =
          AppStorage().userDetail?.userLatLong.split(",") ?? [];
      double distance=0.0;
      if (userDetail?.userConfiguration.requiredGeoFenceStartDuty ??
          false) {
        if (latlong.isEmpty) {
          {
            emit(TabbarSnackBarMessageState(
                "Missing required location,Please contact to support."));
            return;
          }
        }
         distance = distanceFromStore(
            loc, double.parse(latlong[0]), double.parse(latlong[1]));
        if (distance > AppConstant.storeRange) {
          emit(TabbarSnackBarMessageState('You are not in location range'));
          return;
        }
      }
      final response = await repo.startEndDuty(
          event.file,
          loc.latitude,
          loc.longitude,
          true,
          userDetail?.configuration.requiredSelfieForStartDuty ??
              false,
          event.context,userDetail?.userConfiguration.requiredGeoFenceStartDuty ??
          false,distance);
      AppStorage().isDutyStarted = true;
      emit(TabbarSnackBarMessageState(response));
      emit(OnlineStatusUpdateState());
    } catch (e) {
      emit(TabbarSnackBarMessageState(e.toString()));
      emit(OnlineStatusUpdateState());
    }
  }

  Future<void> _endDuty(EndDutyStatusTabbarEvent event, emit) async {
    if (AppStorage().markedInStoreId != null) {
      emit(TabbarSnackBarMessageState('Please Mark-out from store first'));
      return;
    }
    if (userDetail?.configuration.requiredSelfieForStartDuty ??
        true) {
      if (event.file == null) {
        emit(TabbarSnackBarMessageState("Please add image"));
        return;
      }
    }
    emit(TabbarShowProgressHudState());
    try {
      final loc =
          await ContinuousLocationService.instance.resolveForSecureAction();
      List<String> latlong=AppStorage().userDetail?.userLatLong.split(",") ?? [];
      double distance=0.0;
      if (userDetail?.userConfiguration.requiredGeoFenceStartDuty ??false) {
        if (latlong.isEmpty) {
          {
            emit(TabbarSnackBarMessageState("Missing required location,Please contact to support."));
            return;
          }
        }
         distance = distanceFromStore(loc, double.parse(latlong[0]),
         double.parse(latlong[1]));
        if (distance > AppConstant.storeRange) {
          emit(TabbarSnackBarMessageState('You are not in location range'));
          return;
        }
      }

      final response = await repo.startEndDuty(
          event.file,
          loc.latitude,
          loc.longitude,
          false,
          userDetail?.configuration.requiredSelfieForStartDuty ??false,
          event.context,userDetail?.userConfiguration.requiredGeoFenceStartDuty ??false,distance);
      AppStorage().isDutyStarted = false;
      emit(TabbarSnackBarMessageState(response));
      emit(OnlineStatusUpdateState());
    } catch (e) {
      emit(TabbarSnackBarMessageState(e.toString()));
      emit(OnlineStatusUpdateState());
    }
  }

  Future<void> submitToken() async {
    if (!(Platform.isAndroid || Platform.isIOS)) {
      return;
    }

    // Use cached FCM token set by PushNotificationManager
    final token = AppStorage().fcmToken;
    if (token == null || !AppStorage().isLoggedIn()) {
      return;
    }

    final pacageInfo = await PackageInfo.fromPlatform();
    final appVersion = pacageInfo.version;

    // Avoid unnecessary network calls if nothing changed
    if (token == AppStorage().lastFcmTokenSent &&
        appVersion == AppStorage().lastFcmAppVersionSent) {
      return;
    }

    final plateform = Platform.isAndroid
        ? "android"
        : Platform.isIOS
            ? 'ios'
            : 'other';

    final body = {
      "fcm": token,
      'appversion': appVersion,
      "device": plateform,
    };
    final response = await CustomHttpBaseClient.instance.put(
        Uri.parse(
            "${URLConstants.updatefcmtoken}/${AppStorage().userDetail?.id}"),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      AppStorage().lastFcmTokenSent = token;
      AppStorage().lastFcmAppVersionSent = appVersion;
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<void> logout(LogoutEvent event, Emitter<TabbarState> emit) async {
    final body = {"userId": AppStorage().userDetail?.id.toString()};
    final response = await CustomHttpBaseClient.instance.post(
        Uri.parse(URLConstants.logout),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'});
    _sessionExpiredHandled = false;
    if (response.statusCode == 200) {
      emit(LogoutSuccessfulState());
    } else if (response.statusCode == 401) {
      emit(LogoutSuccessfulState());
    } else if (response.statusCode == 404) {
      emit(LogoutSuccessfulState());
    } else {
      throw getErrorMessage(response);
    }
  }

  double distanceFromStore(
      Position userLocation, double latitude, double longitude) {
    return Geolocator.distanceBetween(
        latitude, longitude, userLocation.latitude, userLocation.longitude);
  }
}
