import 'package:device_calendar/device_calendar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluttsec/main.data.dart';
import 'package:fluttsec/send_zayavka_to_calendar.dart';
import 'package:fluttsec/src/models/currentUser.dart';
import 'package:fluttsec/src/models/zayavkaRemote.dart';
import 'package:fluttsec/src/remote/get_token_from_server.dart';
import 'package:fluttsec/src/remote/login.dart';
import 'package:fluttsec/main.dart';
import 'package:fluttsec/my_zayavki_page.dart';
import 'package:fluttsec/src/remote/update_user.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginPage extends HookConsumerWidget {
  static final routeName = "/login";
  TextEditingController companyController = TextEditingController();
  TextEditingController loginController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var isError = useState(false);
    return Scaffold(
        body: Container(
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
          
          image: DecorationImage(
            image: AssetImage("assets/images/11.jpg"),
            fit: BoxFit.fill,
          ),
        ),
          child: 
        Center(
            child: ListView(
            
      padding: EdgeInsets.all(15),
      shrinkWrap: true,
      children: [
        Center(child:Text('ЭвоМонтаж',style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),),),
        SizedBox(height: 100,),
        if (isError.value) Text('     ОШИБКА АВТОРИЗАЦИИ. Укажите верный логин/пароль', style: TextStyle(fontSize: 20),), 
        TextFormField(
          
          textAlign: TextAlign.center,
          controller: companyController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade200,
              contentPadding: const EdgeInsets.all(8.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              hintText: 'Компания'),
        ),
        TextFormField(
          
          textAlign: TextAlign.center,
          controller: loginController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade200,
              contentPadding: const EdgeInsets.all(8.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              hintText: 'Телефон'),
        ),
        SizedBox(height: 10,),
        TextField(
          
          textAlign: TextAlign.center,
          obscureText: true,
          controller: passwordController,
          decoration:  InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade200,
                     contentPadding: const EdgeInsets.all(8.0),
                     
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
    ),
            hintText: 'Пароль'),
        ),
        SizedBox(height: 5,),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 100),
          child: 
        ElevatedButton(
          onPressed: () async {
            if (!await checkConnection()){ 
              
              return;
            }

            try{
              token.value = await getTokenFromServer();
            }
            catch(e){
              return;
            }
            
            var mytoken = token.value;
            String t = loginController.text;
            if (t != "") {
              bool ok = await login(companyController.text+"|"+ t, passwordController.text, mytoken);
              if (ok) {
                company.value = companyController.text;
                user.value = t;
                password.value = passwordController.text;
                ref.duties.clear();
                ref.duties.findAll();
                ref.currentUsers.clear();
                ref.currentUsers.findAll();
                ref.uslugaSelects.clear();
                ref.uslugaSelects.findAll();
                ref.zayavkaRemotes.clear();
                var l =  await ref.zayavkaRemotes.findAll();
                

                 var fcm  = await FirebaseMessaging.instance.getToken();
                  
                  bool ok = await updateUser(company.value+"|"+ user.value, fcm!, mytoken);
                  if(!ok)
                    infoToast("Не удалось подписаться на пуш-уведомления");
               
                context.go(MyZayavkiPage.routeName);
              } else {
                isError.value = true;
                Fluttertoast.showToast(
                    msg: "Не правильный логин/пароль",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
              }
            } else {
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
        )
           ),
           SizedBox(height: 140,),
        Image(height: 70, image: AssetImage("assets/images/logoblack.png"),),
     
      ],
    ))));
  }
}
