import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/helpers/console_log.dart';

class SharedPreferenceService {
  static final SharedPreferenceService _instance =
      SharedPreferenceService._internal();

  factory SharedPreferenceService() {
    return _instance;
  }

  SharedPreferenceService._internal();

  late SharedPreferences _preferences;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  Future<void> create({
    required String accessToken,
    required bool successStatus,
    required String tenantDomain,
    required String subBaseUrl,
  }) async {
    try {
      await _preferences.setString('access_token', accessToken);
      await _preferences.setBool('success_status', successStatus);
      await _preferences.setString('tenant_domain', tenantDomain);
      await _preferences.setString('sub_base_url', subBaseUrl);
    } catch (error) {
      ConsoleLog.error("SharedPreferenceService.create: $error");
    }
  }

  Future<void> setOnboardingStatus(bool status) async {
    try {
      await _preferences.setBool('onboarding_status', status);
    } catch (error) {
      ConsoleLog.error("SharedPreferenceService.setOnboardingStatus: $error");
    }
  }

  bool getSuccessStatus() =>
      _preferences.getBool('success_status') == null ||
          _preferences.getBool('success_status') == false
      ? false
      : true;
  String? getAccessToken() => _preferences.getString('access_token') == null
      ? ''
      : _preferences.getString('access_token');

  bool getOnboardingStatus() =>
      _preferences.getBool('onboarding_status') == null ? false : true;

  int getNotificationCount() =>
      _preferences.getInt('notification_count') == null
      ? 0
      : _preferences.getInt('notification_count')!;
  List<String> getNotificationList() =>
      _preferences.getStringList('notification_list') == null
      ? []
      : _preferences.getStringList('notification_list')!;

  String? getsubBaseUrl() => _preferences.getString('sub_base_url') == null
      ? ''
      : _preferences.getString('sub_base_url');

  String? getTenantDomain() => _preferences.getString('tenant_domain') == null
      ? ''
      : _preferences.getString('tenant_domain');

  Future<void> setTenantDomain(String domain) async {
    try {
      await _preferences.setString('tenant_domain', domain);
    } catch (error) {
      ConsoleLog.error("SharedPreferenceService.setTenantDomain: $error");
    }
  }

  void visualizar() {
    print("==========================");
    print("access_token: ${getAccessToken()}");
    print("sub_base_url: ${getsubBaseUrl()}");
    print("success_status: ${getSuccessStatus()}");
    print("onboarding_status: ${getOnboardingStatus()}");
    print("notification_count: ${getNotificationCount()}");
    print("notification_list: ${getNotificationList()}");
    print("tenant_domain: ${getTenantDomain()}");
    print("==========================");
  }

  Future<void> limparDados() async {
    try {
      await _preferences.clear();
    } catch (err) {
      ConsoleLog.error("shared-preference-service-limpar-dados: $err");
    }
  }

  Future<void> logoff() async {
    try {
      await _preferences.setString('access_token', '');
      await _preferences.setBool('success_status', false);
      await _preferences.setBool('onboarding_status', true);
      await _preferences.setInt('notification_count', 0);
      await _preferences.setStringList('notification_list', []);
    } catch (err) {
      ConsoleLog.error("shared-preference-service-logoff: $err");
    }
  }

  Future<void> pageRoute({required BuildContext ctx}) async {
    try {
      if (getSuccessStatus()) {
        Future.microtask(() {
          Navigator.pushReplacementNamed(ctx, '/home');
        });
        return;
      }
      if (getOnboardingStatus()) {
        Future.microtask(() {
          Navigator.pushReplacementNamed(ctx, '/login');
        });
        return;
      }
      Future.microtask(() {
        Navigator.pushReplacementNamed(ctx, '/onboarding');
      });
    } catch (error) {
      ConsoleLog.error("shared-preference-service-page-route: $error");
    }
  }
}
