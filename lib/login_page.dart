import 'package:device_calendar/device_calendar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluttsec/send_zayavka_to_calendar.dart';
import 'package:fluttsec/src/models/zayavkaRemote.dart';
import 'package:fluttsec/src/remote/get_token_from_server.dart';
import 'package:fluttsec/src/remote/login.dart';
import 'package:fluttsec/main.dart';
import 'package:fluttsec/main.data.dart';
import 'package:fluttsec/my_zayavki_page.dart';
import 'package:fluttsec/src/remote/update_user.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginPage extends HookConsumerWidget {
  static final routeName = "/login";
  TextEditingController loginController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        body: Center(
            child: ListView(
      shrinkWrap: true,
      children: [
        TextFormField(
          controller: loginController,
          decoration: const InputDecoration(hintText: 'Телефон'),
        ),
        TextFormField(
          obscureText: true,
          controller: passwordController,
          decoration: const InputDecoration(hintText: 'Пароль'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (!await checkConnection()) return;
            token.value = await getTokenFromServer();
            var mytoken = token.value;
            String t = loginController.text;
            if (t != "") {
              bool ok = await login(t, passwordController.text, mytoken);
              if (ok) {
                user.value = t;
                password.value = passwordController.text;
                ref.duties.clear();
                ref.duties.findAll();
                ref.uslugaSelects.findAll();
                List<ZayavkaRemote> zs = await ref.zayavkaRemotes.findAll();
                for (ZayavkaRemote z in zs) {
                  sendZayavkaToCalendar(z, getLocation('UTC'), myCal);
                }

                FirebaseMessaging.instance.getToken().then((value) {
                  String? token = value;
                  updateUser(user.value, token!, mytoken);
                });
                context.go(MyZayavkiPage.routeName);
              } else {
                Fluttertoast.showToast(
                    msg: "Не правильный логин/пароль",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
              }
            }else{
              Fluttertoast.showToast(
                    msg: "Введите логин/пароль логин/пароль",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
            }
          },
          child: const Text('Войти'),
        ),
      ],
    )));
  }
}
