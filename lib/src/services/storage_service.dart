import 'package:flutter/cupertino.dart';
import 'package:localstorage/localstorage.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../main.dart';

Future<void> initUserSession() async {
  company = ValueNotifier(localStorage.getItem('company') ?? '');
  company.addListener(() {
    localStorage.setItem('company', company.value.toString());
  });
  user = ValueNotifier(localStorage.getItem('user') ?? '');
  user.addListener(() {
    localStorage.setItem('user', user.value.toString());
  });
  password = ValueNotifier(localStorage.getItem('password') ?? '');
  password.addListener(() {
    localStorage.setItem('password', password.value.toString());
  });
  token = ValueNotifier(localStorage.getItem('token') ?? '');
  token.addListener(() {
    localStorage.setItem('token', token.value.toString());
  });

  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  String? version = localStorage.getItem('version');
  String newVersion = packageInfo.version;
  if (version != null) {
    if (version != newVersion) {
      user.value = '';
      password.value = '';
    }
  }
  localStorage.setItem("version", newVersion);
}