// Copyright 2019 The rhyme_lph Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

class RUpgrade {
  static MethodChannel __methodChannel;

  /// single
  static MethodChannel get _methodChannel {
    if (__methodChannel == null) {
      __methodChannel = MethodChannel('com.rhyme/r_upgrade_method');
      __methodChannel.setMethodCallHandler(_methodCallHandler);
    }
    return __methodChannel;
  }

  /// handle download info call back.
  static Future _methodCallHandler(MethodCall call) async {
    if (call.method == 'update') {
      _downloadInfo.add(DownloadInfo.formMap(call.arguments));
    }
    return null;
  }

  /// [isDebug] is true will print log.
  static Future<void> setDebug(bool isDebug) async {
    return _methodChannel.invokeMethod('setDebug', {
      'isDebug': isDebug,
    });
  }

  ///  Android and IOS
  ///
  /// if you want to upgrade in your website
  ///
  ///  [url] your website url
  ///
  static Future<bool> upgradeFromUrl(String url) async {
    return await _methodChannel.invokeMethod("upgradeFromUrl", {
      'url': url,
    });
  }

  ///  Android
  ///
  /// if you want to upgrade form your store.
  ///
  ///  [stores] if null,show all store list
  ///
  static Future<bool> upgradeFromAndroidStore(AndroidStore store) async {
    assert(Platform.isAndroid, 'This method only support android application');
    return await _methodChannel.invokeMethod("upgradeFromAndroidStore", {
      'stores': store?._packageName,
    });
  }

  /// Android
  ///
  /// download broadcast
  ///
  static StreamController<DownloadInfo> _downloadInfo = StreamController.broadcast();

  /// Android
  ///
  /// Download info stream . this will listen your upgrade progress and more info.
  ///
  static Stream<DownloadInfo> get stream {
    assert(Platform.isAndroid, 'This method only support android application');
    return _downloadInfo.stream;
  }

  /// Android
  ///
  /// You can use this method upgrade your android application.If your application is ios. Oh,so sorry...
  ///
  /// * [url] download url.
  /// * [header] download  request header.
  /// * [fileName] download  filename and notification title name.
  /// * [notificationVisibility] download running notification visibility mode.
  /// * [notificationStyle] download notification show style about content text, only support [useDownloadManager]==false.
  /// * [isAutoRequestInstall] download completed will install apk.
  /// * [useDownloadManager] if true will use DownloadManager,false will use my service ,
  /// *         if true will no use [pause] , [upgradeWithId] , [getDownloadStatus] , [getLastUpgradedId] methods.
  /// * [upgradeFlavor] you can use [RUpgradeFlavor.normal] , [RUpgradeFlavor.hotUpgrade] flavor
  static Future<int> upgrade(
    String url, {
    Map<String, String> header,
    String fileName,
    NotificationVisibility notificationVisibility = NotificationVisibility.VISIBILITY_VISIBLE,
    NotificationStyle notificationStyle = NotificationStyle.planTime,
    bool isAutoRequestInstall = true,
    bool useDownloadManager = false,
    RUpgradeFlavor upgradeFlavor = RUpgradeFlavor.normal,
  }) {
    assert(Platform.isAndroid, 'This method only support android application');
    return _methodChannel.invokeMethod('upgrade', {
      'url': url,
      "header": header,
      "fileName": fileName,
      "notificationVisibility": notificationVisibility?.value,
      "notificationStyle": notificationStyle?.index,
      "isAutoRequestInstall": isAutoRequestInstall,
      "useDownloadManager": useDownloadManager,
      "upgradeFlavor": upgradeFlavor?.index,
    });
  }

  /// Android
  ///
  /// Cancel by the [id] download task .
  ///
  static Future<bool> cancel(int id) {
    assert(Platform.isAndroid, 'This method only support android application');
    return _methodChannel.invokeMethod('cancel', {
      'id': id,
    });
  }

  /// Android
  ///
  /// Install your apk by [id].
  ///
  static Future<bool> install(int id) async {
    assert(Platform.isAndroid, 'This method only support android application');
    return await _methodChannel.invokeMethod("install", {
      'id': id,
    });
  }

  /// Android
  ///
  /// Pause by the [id] download task ,only use to [upgrade] params [useDownloadManager] is false.
  ///
  static Future<bool> pause(int id) {
    assert(Platform.isAndroid, 'This method only support android application');
    return _methodChannel.invokeMethod('pause', {
      'id': id,
    });
  }

  /// Android
  ///
  /// Upgrade with ID ,only use to [upgrade] params [useDownloadManager] is false.
  ///
  /// * if download status is [STATUS_PAUSED] or [STATUS_FAILED] or [STATUS_CANCEL], will restart running.
  /// * if download status is [STATUS_RUNNING] or [STATUS_PENDING], nothing happened.
  /// * if download status is [STATUS_SUCCESSFUL] , will install apk.
  ///
  /// * if not found the id , will return [false].
  static Future<bool> upgradeWithId(
    int id, {
    NotificationVisibility notificationVisibility = NotificationVisibility.VISIBILITY_VISIBLE,
    bool isAutoRequestInstall = true,
  }) async {
    assert(Platform.isAndroid, 'This method only support android application');
    return await _methodChannel.invokeMethod("upgradeWithId", {
      "id": id,
      "notificationVisibility": notificationVisibility.value,
      "isAutoRequestInstall": isAutoRequestInstall,
    });
  }

  /// Android
  ///
  /// Get download status by ID , only use to [upgrade] params [useDownloadManager] is false.
  ///
  static Future<DownloadStatus> getDownloadStatus(int id) async {
    assert(Platform.isAndroid, 'This method only support android application');
    int result = await _methodChannel.invokeMethod("getDownloadStatus", {
      "id": id,
    });
    return result == null ? null : DownloadStatus._internal(result);
  }

  /// Android
  ///
  /// Get the ID of the last upgrade by version name and version code , only use to [upgrade] params [useDownloadManager] is false.
  ///
  static Future<int> getLastUpgradedId() async {
    assert(Platform.isAndroid, 'This method only support android application');
    return await _methodChannel.invokeMethod('getLastUpgradedId');
  }

  /// IOS
  ///
  /// [appId] your appId in appStore
  ///
  static Future<bool> upgradeFromAppStore(String appId) async {
    assert(Platform.isIOS, 'This method only support ios application');
    return await _methodChannel.invokeMethod("upgradeFromAppStore", {
      'appId': appId,
    });
  }

  /// IOS
  ///
  /// [id] your appId in appStore
  ///
  static Future<String> getVersionFromAppStore(String appId) async {
    assert(Platform.isIOS, 'This method only support ios application');
    return await _methodChannel.invokeMethod("getVersionFromAppStore", {
      'appId': appId,
    });
  }
}

///
/// A model class is download info
///
/// * [maxLength] download max bytes length
/// * [currentLength] download current bytes length
/// * [status] download status . you can watch [DownloadStatus]
/// * [planTime] download plan time /s
/// * [path] download file path
/// * [percent] download percent 0-100
/// * [id] download id
/// * [speed] download speed kb/s
///
class DownloadInfo {
  final int maxLength;
  final int currentLength;
  final String path;
  final double planTime;
  final double percent;
  final int id;
  final double speed;
  final DownloadStatus status;

  DownloadInfo({this.maxLength, this.path, this.planTime, this.currentLength, this.percent, this.id, this.status, this.speed});

  factory DownloadInfo.formMap(dynamic map) => DownloadInfo(
        maxLength: map['max_length'],
        currentLength: map['current_length'],
        path: map['path'],
        planTime: map['plan_time'],
        percent: map['percent'],
        id: map['id'],
        status: DownloadStatus._internal(map['status']),
        speed: map['speed'],
      );

  @override
  String toString() {
    return 'DownloadInfo{total: $maxLength, address: $path, planTime: $planTime, progress: $currentLength, percent: $percent, id: $id, speed: $speed, status: $status}';
  }
}

///
/// A model class is download status
///
/// * [STATUS_PAUSED] download paused
/// * [STATUS_PENDING] download pending
/// * [STATUS_RUNNING] download running
/// * [STATUS_SUCCESSFUL] download successful
/// * [STATUS_FAILED] download failed
/// * [STATUS_CANCEL] download cancel
///
class DownloadStatus {
  final int _value;

  int get value => _value;

  const DownloadStatus._internal(this._value);

  static DownloadStatus from(int value) => DownloadStatus._internal(value);

  static const STATUS_PAUSED = const DownloadStatus._internal(0);
  static const STATUS_PENDING = const DownloadStatus._internal(1);
  static const STATUS_RUNNING = const DownloadStatus._internal(2);
  static const STATUS_SUCCESSFUL = const DownloadStatus._internal(3);
  static const STATUS_FAILED = const DownloadStatus._internal(4);
  static const STATUS_CANCEL = const DownloadStatus._internal(5);

  get hashCode => _value;

  operator ==(status) => status._value == this._value;

  toString() => 'DownloadStatus($_value)';
}

///
/// A model class is Notification Visibility
///
/// * [VISIBILITY_VISIBLE] This download is visible but only shows in the notifications
/// * [VISIBILITY_VISIBLE_NOTIFY_COMPLETED] This download is visible and shows in the notifications while
/// * [VISIBILITY_HIDDEN] This download doesn't show in the UI or in the notifications.
/// * [VISIBILITY_VISIBLE_NOTIFY_ONLY_COMPLETION] This download shows in the notifications after completion ONLY.
///
class NotificationVisibility {
  final int _value;

  const NotificationVisibility._internal(this._value);

  int get value => _value;

  get hashCode => _value;

  operator ==(status) => status._packageName == this._value;

  toString() => 'NotificationVisibility($_value)';

  static NotificationVisibility from(int value) => NotificationVisibility._internal(value);

  /// This download is visible but only shows in the notifications
  /// while it's in progress.
  static const VISIBILITY_VISIBLE = const NotificationVisibility._internal(0);

  /// This download is visible and shows in the notifications while
  /// in progress and after completion.
  static const VISIBILITY_VISIBLE_NOTIFY_COMPLETED = const NotificationVisibility._internal(1);

  /// This download doesn't show in the UI or in the notifications.
  static const VISIBILITY_HIDDEN = const NotificationVisibility._internal(2);

  ///
  /// This download shows in the notifications after completion ONLY.
  ///
  static const VISIBILITY_VISIBLE_NOTIFY_ONLY_COMPLETION = const NotificationVisibility._internal(3);
}

/// Notification show style about content text
enum NotificationStyle {
  speechAndPlanTime,
  planTimeAndSpeech,
  speech,
  planTime,
  none,
}

/// Upgrade Flavor
enum RUpgradeFlavor {
  normal,
  hotUpgrade,
}

///
/// Android application store.
///
/// [packageName] store package name.
class AndroidStore {
  final String _packageName;

  String get packageName => _packageName;

  const AndroidStore.internal(this._packageName);

  //google play
  static const GOOGLE_PLAY = const AndroidStore.internal('com.android.vending');

  //应用宝
  static const TENCENT = const AndroidStore.internal('com.tencent.android.qqdownloader');

  //360手机助手
  static const QIHOO = const AndroidStore.internal('com.qihoo.appstore');

  //百度手机助手
  static const BAIDU = const AndroidStore.internal('com.baidu.appsearch');

  //小米应用商店
  static const XIAOMI = const AndroidStore.internal('com.xiaomi.market');

  //豌豆荚
  static const WANDOU = const AndroidStore.internal('com.wandoujia.phoenix2');

  //华为应用市场
  static const HUAWEI = const AndroidStore.internal('com.huawei.appmarket');

  //淘宝手机助手
  static const TAOBAO = const AndroidStore.internal('com.taobao.appcenter');

  //安卓市场
  static const HIAPK = const AndroidStore.internal('com.hiapk.marketpho');

  //安智市场
  static const GOAPK = const AndroidStore.internal('cn.goapk.market');

  //酷安
  static const COOLAPK = const AndroidStore.internal('com.coolapk.market');
}
