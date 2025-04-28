import 'dart:convert';

import 'package:device_calendar/device_calendar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttsec/main.data.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../../send_zayavka_to_calendar.dart';
import '../models/avtomobilRemote.dart';
import '../models/zayavkaRemote.dart';

Future<bool> loadZayavkaFromPrefs(WidgetRef ref) async {
  var prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  // Do the staff
  var keys = prefs.getKeys();
  for (var key in keys) {
    if (key.startsWith("zayavka")) {
      String z = prefs.getString(key)!;
      var map = jsonDecode(z);
      newZayavkaFromMessageWithCalendar(ref, map);
      return await prefs.remove(key);
    }else
    if (key.startsWith("avtoUpdate")) {
      String z = prefs.getString(key)!;
      var map = jsonDecode(z);
      updateAvtoFromMessage(ref, map);
      return await prefs.remove(key);
    }
  }
  return false;
}
Future<AvtomobilRemote?> updateAvtoFromMessage(WidgetRef ref, Map data) async {
  var a = await ref.avtomobilRemotes.findOne(data['avtoId'], remote: false);

  a?.status = 'VYPOLNENA';
  a?.save(remote: false);
  a?.saveLocal();
  a!.zayavka?.value?.saveLocal();
  return a;
}

Future<ZayavkaRemote> newZayavkaFromMessageWithCalendar(WidgetRef ref, Map data) async {



  ZayavkaRemote z = await newZayavkaFromMessage(data, ref);
  sendZayavkaToCalendar(ref, z, getLocation('UTC'), myCal);
  return z;
}

Future<ZayavkaRemote> newZayavkaFromMessage( Map data,WidgetRef ref) async {
  var id = data["id"];
  var nomer = data["nomer"];
  var mes = data["message"];
  var adres = data["adres"];
  var nachalo = data["nachalo"];
  var format = new DateFormat("yyyy-MM-dd HH:mm:ss");

  DateTime nachalo_date =  nachalo==null?DateTime.now():format.parse(nachalo);
  DateTime end_date_time = format.parse(data["end_date_time"]);
  var comment_address = data["comment_address"];
  var service = data["service"];
  var client = data["client"];
  var contact_name = data["contact_name"];
  var contact_number = data["contact_number"];
  var manager_name = data["manager_name"];
  var manager_number = data["manager_number"];
  var lat = data["lat"];
  var lng = data["lng"];
  var status = data['status'];
  Set<AvtomobilRemote> avs = {};
  if (data["avtomobili"] != null) {
    List avtomobili = jsonDecode(data["avtomobili"]);
    for (var i in avtomobili) {
      var a = i["nomer_avto"];
      var s = i["marka_avto"];
      var ag = i["nomerAG"];
      var aid = i["id"];
      AvtomobilRemote ar = AvtomobilRemote(
          id: aid, nomer: a, marka: s, nomerAG: ag, status: "NOVAYA");
      avs.add(ar);
      ar.saveLocal();
    }
  }

  ZayavkaRemote? z = await  ref.zayavkaRemotes.findOne(data["id"]);
  if(z ==null){
    z = ZayavkaRemote(
        id: id,
        avtomobili: avs.asHasMany,
        adres: adres,
        client: client,
        comment_address: comment_address,
        contact_name: contact_name,
        contact_number: contact_number,
        nachalo: nachalo_date,
        end_date_time: end_date_time,
        service: service,
        manager_name: manager_name,
        manager_number: manager_number,
        nomer: nomer,
        message: mes,
        lat: lat,
        lng: lng,
        status: status);

    z.saveLocal();
  }else{
    z.status = status;


  }


  return z;
}
updateAvtoFromMessageZ( Map data) async {
  if(data['tip_soobsheniya']=='avto_update'){
    var avtoId = data['avtoId'];
    //TODO


  }
}

Future<ZayavkaRemote> newZayavkaFromMessageZ( Map data) async {

  var id = data["id"];
  var nomer = data["nomer"];
  var mes = data["message"];
  var adres = data["adres"];
  var nachalo = data["nachalo"];
  var format = new DateFormat("yyyy-MM-dd HH:mm:ss");

  DateTime nachalo_date =  nachalo==null?DateTime.now():format.parse(nachalo);
  DateTime end_date_time = format.parse(data["end_date_time"]);
  var comment_address = data["comment_address"];
  var service = data["service"];
  var client = data["client"];
  var contact_name = data["contact_name"];
  var contact_number = data["contact_number"];
  var manager_name = data["manager_name"];
  var manager_number = data["manager_number"];
  var lat = data["lat"];
  var lng = data["lng"];
  var status = data['status'];
  Set<AvtomobilRemote> avs = {};
  if (data["avtomobili"] != null) {
    List avtomobili = jsonDecode(data["avtomobili"]);
    for (var i in avtomobili) {
      var a = i["nomer_avto"];
      var s = i["marka_avto"];
      var ag = i["nomerAG"];
      var aid = i["id"];
      AvtomobilRemote ar = AvtomobilRemote(
          id: aid, nomer: a, marka: s, nomerAG: ag, status: "NOVAYA");
      avs.add(ar);
      ar.saveLocal();
    }
  }

  ZayavkaRemote? z;

  z = ZayavkaRemote(
      id: id,
      avtomobili: avs.asHasMany,
      adres: adres,
      client: client,
      comment_address: comment_address,
      contact_name: contact_name,
      contact_number: contact_number,
      nachalo: nachalo_date,
      end_date_time: end_date_time,
      service: service,
      manager_name: manager_name,
      manager_number: manager_number,
      nomer: nomer,
      message: mes,
      lat: lat,
      lng: lng,
      status: status);

  z.saveLocal();



  return z;
}
Future<bool> saveToPrefs(RemoteMessage message) async {
  print("\n\n\nobject пытаемся сохранить");
  var sp = await SharedPreferences.getInstance();
  print("\n\n\nobject получили схаред");
  String prefix;
  var ok;
  if(message.data['tip_soobsheniya']=='avto_update'){
    prefix = "avtoUpdate-";
    ok = await sp.setString(
        prefix + message.data["avtoId"], json.encode(message.data));
    print("\n\n\nobject сохранили");
    print(ok.toString());
  }else{
    prefix="zayavka-";
    ok = await sp.setString(
        prefix + message.data["id"], json.encode(message.data));
    print("\n\n\nobject сохранили");
    print(ok.toString());
  }


  return ok;
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null && !kIsWeb) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          // TODO add a proper drawable resource to android, for now using
          //      one that already exists in example app.
          icon: 'launch_background',
        ),
      ),
    );
  }
}