import 'package:flutter/material.dart';
import 'package:device_policy_manager/device_policy_manager.dart';
import 'package:kiosk_mode/kiosk_mode.dart';

class DeviceAdminProvider extends ChangeNotifier {
  bool _hasAdminPermission = false;
  bool _isScreenLocked = false;
  bool _isKioskMode = false;

  bool get hasAdminPermission => _hasAdminPermission;
  bool get isScreenLocked => _isScreenLocked;
  bool get isKioskMode => _isKioskMode;

  Future<void> requestAdminPermission() async {
    try {
      _hasAdminPermission = await DevicePolicyManager.isPermissionGranted();
      if (!_hasAdminPermission) {
        _hasAdminPermission = await DevicePolicyManager.requestPermession("App needs admin rights");
      }
      notifyListeners();
    } catch (e) {
      _hasAdminPermission = false;
      notifyListeners();
    }
  }

  Future<void> lockScreen() async {
    if (_hasAdminPermission) {
      try {
        await DevicePolicyManager.lockNow();
        _isScreenLocked = true;
        notifyListeners();
      } catch (e) {
        // Handle error
      }
    }
  }

  Future<void> unlockScreen() async {
    if (_isScreenLocked) {
      try {
        // No direct unlock, but we can update state
        _isScreenLocked = false;
        notifyListeners();
      } catch (e) {
        // Handle error
      }
    }
  }

  Future<void> checkPermissions() async {
    _hasAdminPermission = await DevicePolicyManager.isPermissionGranted();
    notifyListeners();
  }

  Future<void> enableKioskMode() async {
    try {
      await startKioskMode();
      _isKioskMode = true;
      notifyListeners();
    } catch (e) {
      _isKioskMode = false;
      notifyListeners();
    }
  }

  Future<void> disableKioskMode() async {
    try {
      await stopKioskMode();
      _isKioskMode = false;
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }
} 