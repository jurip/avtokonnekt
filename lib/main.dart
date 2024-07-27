import 'dart:convert';
import 'dart:io';
import 'package:fluttsec/src/models/chekFoto.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttsec/src/models/calendarEvent.dart';
import 'package:fluttsec/src/models/chek.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttsec/src/models/avtomobilRemote.dart';
import 'package:fluttsec/src/models/foto.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:fluttsec/main.data.dart';
import 'package:fluttsec/src/models/oborudovanie.dart';
import 'package:fluttsec/src/models/usluga.dart';
import 'package:fluttsec/src/models/uslugaSelect.dart';
import 'package:fluttsec/src/models/zayavkaRemote.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:localstorage/localstorage.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

//const String site = "http://89.111.173.110:8080/";
late final ValueNotifier<String> notifier;
late final ValueNotifier<String> password;
late final ValueNotifier<String> token;

const String site = "http://95.84.221.108:2222/";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initLocalStorage();

  notifier = ValueNotifier(localStorage.getItem('user') ?? '');
  notifier.addListener(() {
    localStorage.setItem('user', notifier.value.toString());
  });
  password = ValueNotifier(localStorage.getItem('password') ?? '');
  password.addListener(() {
    localStorage.setItem('password', password.value.toString());
  });
  token = ValueNotifier(localStorage.getItem('token') ?? '');
  token.addListener(() {
    localStorage.setItem('token', token.value.toString());
  });

  runApp(
    ProviderScope(
      child: MaterialApp.router(
        routerConfig: __router,
      ),
      overrides: [configureRepositoryLocalStorage()],
    ),
  );
}

final GoRouter __router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return MyZayavkiPage();
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'zayavki',
            builder: (BuildContext context, GoRouterState state) {
              return MyZayavkiPage();
            },
          ),
          GoRoute(
            path: 'cheki',
            builder: (BuildContext context, GoRouterState state) {
              return CheckiPage();
            },
          ),
          GoRoute(
            path: 'login',
            builder: (BuildContext context, GoRouterState state) {
              return LoginPage();
            },
          ),
        ],
        redirect: (context, state) {
          final bool userAutheticated = notifier.value != '';

          final bool onloginPage = state.fullPath == '/login';

          if (!userAutheticated && !onloginPage) {
            return '/login';
          }
          if (userAutheticated && onloginPage) {
            return '/';
          }
          //you must include this. so if condition not meet, there is no redirect
          return null;
        }),
  ],
);

class CheckiPage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(child: ChekiScreen()),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) async {
          if (value == 0) {
            _launchUrl();
          } else if (value == 1) {
            context.go('/zayavki');
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_calendar_rounded),
            label: 'Календарь',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_business_rounded),
            label: 'Заявки',
          ),
        ],
      ),
    );
  }
}

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
            token.value = await getTokenFromServer();
            var mytoken = token.value;
            String t = loginController.text;
            if (t != "") {
              bool ok = await login(t, passwordController.text, mytoken);
              if (ok) {
                notifier.value = t;
                password.value = passwordController.text;
                context.go(MyZayavkiPage.routeName);
              }
            }
          },
          child: const Text('Войти'),
        ),
      ],
    )));
  }
}

class MyZayavkiPage extends HookConsumerWidget {
  static final routeName = "/zayavki";
  MyZayavkiPage({super.key}) {}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(child: TasksScreen()),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) async {
          if (value == 0) {
            _launchUrl();
          } else if (value == 1) {
            context.go('/cheki');
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_calendar_rounded),
            label: 'Календарь',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_post_office_rounded),
            label: 'Офис',
          ),
        ],
      ),
    );
  }
}

class ChekiScreen extends HookConsumerWidget {
  void showChekDialog(context, ref) {
    showDialog(
      context: context,
      builder: (_) {
        var nomerController = TextEditingController();
        return AlertDialog(
          title: Text('Чеки'),
          content: ListView(
            shrinkWrap: true,
            children: [
              TextFormField(
                controller: nomerController,
                decoration: InputDecoration(hintText: 'комментарий'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Send them to your email maybe?
                var nomer = nomerController.text;
                Chek a = Chek(
                    comment: nomer,
                    username: notifier.value,
                    date: DateTime.now());
                a.saveLocal();
                Navigator.pop(context);
              },
              child: Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(repositoryInitializerProvider).when(
        error: (error, _) => Text(error.toString()),
        loading: () => const CircularProgressIndicator(),
        data: (_) {
          var chekState = ref.cheks.watchAll(remote: false);

          return ListView(
            children: [
              ElevatedButton(
                child: const Text('Добавить отчет о покупках'),
                onPressed: () {
                  showChekDialog(context, ref);
                },
              ),
              for (var chek in chekState.model.toList(growable: true))
                Column(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          ElevatedButton(
                              onPressed: chek.status != "NOVAYA"
                                  ? null
                                  : () async {
                                      bool ok = await saveChekWithPhotos(
                                          chek, ref, token.value);
                                      if (ok) {
                                        chek.status = "GOTOWAYA";
                                        chek.saveLocal();
                                      }
                                    },
                              child: const Text("готово")),
                          const SizedBox(width: 8),
                          Text(
                            chek.comment ?? "-",
                            style: chek.status != "NOVAYA"
                                ? TextStyle(backgroundColor: Colors.grey)
                                : null,
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            child: const Text('фото+'),
                            onPressed: chek.status != "NOVAYA"
                                ? null
                                : () {
                                    addChekLocalFiles(chek);
                                  },
                          ),
                        ]),
                    Row(
                      children: [
                        const SizedBox(width: 8),
                        Column(children: [
                          for (ChekFoto foto in chek.fotos.toList())
                            Row(children: <Widget>[
                              Image(
                                image: FileImage(File(foto.fileLocal!)),
                                width: 40,
                              ),
                              const SizedBox(width: 8),
                            ])
                        ]),
                        const SizedBox(width: 8),
                      ],
                    ),
                    const SizedBox(width: 8),
                  ],
                )
            ],
          );
        });
  }
}

class TasksScreen extends HookConsumerWidget {
  TasksScreen({super.key});

  void showDialogWithFields(context, ZayavkaRemote zayavka) {
    showDialog(
      context: context,
      builder: (_) {
        var nomerController = TextEditingController();
        var markaController = TextEditingController();
        return AlertDialog(
          title: Text('авто'),
          content: ListView(
            shrinkWrap: true,
            children: [
              TextFormField(
                controller: nomerController,
                decoration: InputDecoration(hintText: 'номер'),
              ),
              TextFormField(
                controller: markaController,
                decoration: InputDecoration(hintText: 'марка'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                // Send them to your email maybe?
                var nomer = nomerController.text;
                var marka = markaController.text;
                AvtomobilRemote a = AvtomobilRemote(
                    zayavka: BelongsTo<ZayavkaRemote>(zayavka),
                    nomer: nomer,
                    marka: marka,
                    status: "NOVAYA");
                a.saveLocal();
                zayavka.saveLocal();
                Navigator.pop(context);
              },
              child: Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  void showUslugaSelect(
      context, ZayavkaRemote zayavka, AvtomobilRemote avto, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) {
        final stateUslugas = ref.uslugaSelects.watchAll(remote: false);
        return AlertDialog(
          title: Text('Выбрать услугу'),
          content: ListView(
            shrinkWrap: true,
            children: [
              for (UslugaSelect u in stateUslugas.model.toList(growable: true))
                GestureDetector(
                  child: Text(u.title.toString(), style: TextStyle(fontSize: 18),),
                  onLongPress: () {
                    Usluga newU = Usluga(
                        avtomobil: BelongsTo(avto), title: u.title.toString());
                    avto.performance_service.add(newU);
                    newU.saveLocal();
                    avto.saveLocal();
                    zayavka.saveLocal();
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Отмена'),
            ),
          ],
        );
      },
    );
  }

  void showBarcode(context, ZayavkaRemote zayavka, AvtomobilRemote avto) {
    showDialog(
      context: context,
      builder: (_) {
        var codeController = TextEditingController();

        return AlertDialog(
          title: Text('Добавить авто'),
          content: ListView(
            shrinkWrap: true,
            children: [
              TextFormField(
                controller: codeController,
                decoration: InputDecoration(hintText: 'штрихкод'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                // Send them to your email maybe?
                var kod = codeController.text;

                Oborudovanie o =
                    Oborudovanie(avtomobil: BelongsTo(avto), code: kod);
                avto.barcode.add(o);
                o.saveLocal();
                avto.saveLocal();
                zayavka.saveLocal();
                Navigator.pop(context);
              },
              child: Text('Готово'),
            ),
          ],
        );
      },
    );
  }

  void showDeleteAlert(context, ZayavkaRemote zayavka) {
    showDialog(
      context: context,
      builder: (_) {
        var codeController = TextEditingController();

        return AlertDialog(
          title: Text('Закрытие заявки'),
          content: ListView(
            shrinkWrap: true,
            children: [Text('Уверены что хотите закрыть заявку?')],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (await updateZayavka(zayavka, token.value))
                  zayavka.deleteLocal();
                Navigator.pop(context);
              },
              child: Text('Готово'),
            ),
          ],
        );
      },
    );
  }

  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController(text: '');
    return ref.watch(repositoryInitializerProvider).when(
        error: (error, _) => Text(error.toString()),
        loading: () => const CircularProgressIndicator(),
        data: (_) {
          final stateLocal = ref.zayavkaRemotes.watchAll();
          final stateDuty = ref.duties.watchAll();
          

          return RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: () async {
                token.value = await getTokenFromServer();
                await ref.uslugaSelects.findAll();
                await ref.duties.findAll();
                await loadZ(ref);
              },
              // Pull from top to show refresh indicator.
              child: ListView(
                children: [
                  for (final duty in stateDuty.model)
                    Text('${duty.fio} - ${duty.status}' ,style: TextStyle(fontSize: 20),),
                  for (final zayavka in stateLocal.model)
                    ExpansionTile(
                        title: Text('${zayavka.nomer}'),
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Card(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ElevatedButton(
                                      child: const Text('Закрыть'),
                                      onPressed: () async {
                                        showDeleteAlert(context, zayavka);
                                      },
                                    ),
                                    ListTile(
                                      isThreeLine: true,
                                      subtitle: Text(
                                          '${zayavka.nachalo}\n${zayavka.client}\n${zayavka.adres}\n${zayavka.contact_number} ${zayavka.contact_name}\n${zayavka.message} '),
                                    ),
                                    ExpansionTile(title: Text('Автомобили'),
                                    children: [ Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          child: const Text('авто+'),
                                          onPressed: () {
                                            showDialogWithFields(
                                                context, zayavka);
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                    ),
                                    for (AvtomobilRemote avto
                                        in zayavka.avtomobili.toList())
                                        ExpansionTile(title: Text('${avto.nomer}' ),
                                        
                                        collapsedBackgroundColor: 
                                         avto.status != "NOVAYA"
                                              ? Colors.grey
                                              : Colors.green,
                                        children: [
                                      
                                        Container(
                                        
                                          child: 
                                      Column(
                                        children: [
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              ElevatedButton(
                                                  onPressed: avto.status !=
                                                          "NOVAYA"
                                                      ? null
                                                      : () async {
                                                          bool ok =
                                                              await saveWithPhotos(
                                                                  avto,
                                                                  ref,
                                                                  token.value);
                                                          if (ok) {
                                                            avto.status =
                                                                "GOTOWAYA";
                                                            avto.saveLocal();
                                                            zayavka.saveLocal();
                                                          }
                                                        },
                                                  child: const Text("готово")),
                                              const SizedBox(width: 8),
                                              Text(
                                                avto.nomer ?? "-",
                                               
                                              ),
                                              const SizedBox(width: 8),
                                              Text(avto.marka ?? "-"),
                                              ElevatedButton(
                                                child: const Text('фото+'),
                                                onPressed:
                                                    avto.status != "NOVAYA"
                                                        ? null
                                                        : () {
                                                            addLocalFiles(
                                                                zayavka, avto);
                                                          },
                                              ),
                                            ]),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            for (Foto foto
                                                in avto.fotos.toList())
                                              Image(
                                                image: FileImage(
                                                    File(foto.fileLocal!)),
                                                width: 40,
                                              )
                                          ],
                                        ),
                                        ElevatedButton(
                                          child: const Text('услуга'),
                                          onPressed: avto.status != "NOVAYA"
                                              ? null
                                              : () {
                                                  showUslugaSelect(context,
                                                      zayavka, avto, ref);
                                                },
                                        ),
                                       
                                           
                                              for (Usluga usluga in avto
                                                  .performance_service
                                                  .toList())
                                                Row(
                                                  children: <Widget>[
                                                  Text('${usluga.title}' ,overflow: TextOverflow.fade, softWrap: false,),
                                                  
                                                ]),
                                            
                                        ElevatedButton(
                                          child: const Text('оборудование'),
                                          onPressed: avto.status != "NOVAYA"
                                              ? null
                                              : () async {
                                                  var res =
                                                      await Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                const SimpleBarcodeScannerPage(),
                                                          ));
                                                  if (res is String) {
                                                    Oborudovanie o =
                                                        Oborudovanie(
                                                            avtomobil:
                                                                BelongsTo(avto),
                                                            code: res);
                                                    avto.barcode.add(o);
                                                    o.saveLocal();
                                                    avto.saveLocal();
                                                    zayavka.saveLocal();
                                                  }
                                                },
                                        ),
                                       
                                              for (Oborudovanie oborudovanie
                                                  in avto.barcode.toList())
                                                Row(children: <Widget>[
                                                  Text('${oborudovanie.code}')
                                                ])
                                          
                                      ]),
                                        )])
                                        ])
                                  ],
                                ),
                              ),
                            ],
                          )
                        ])
                ],
              ));
        });
  }
}

addLocalFiles(ZayavkaRemote zayavka, AvtomobilRemote avto) async {
  var result = await FilePicker.platform.pickFiles(allowMultiple: true);

  if (result != null) {
    List<String?> files = result.paths.map((path) => path!).toList();
    for (var file in files) {
      Foto f = Foto(fileLocal: file, avtomobil: BelongsTo(avto));
      avto.fotos.add(f);
      f.saveLocal();
    }
    avto.saveLocal();
    zayavka.saveLocal();
  } else {
    final snackBar = SnackBar(
      content: const Text('файлы не добавлены'),
    );
  }
}

Future<bool> saveWithPhotos(
    AvtomobilRemote avto, WidgetRef ref, mytoken) async {
  for (Foto foto in avto.fotos.toList()) {
    var headers = {
      'Content-Type': 'image/jpeg',
      'Authorization': 'Bearer $mytoken'
    };
    var data = File(foto.fileLocal!).readAsBytesSync();

    var dio = Dio();
    var response = await dio.request(
      '${site}rest/files?name=cat-via-direct-request.jpg',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: data,
    );

    if (response.statusCode == 201) {
      print(response.data);
      String f = response.data['fileRef'];
      foto.file = f;
    } else {
      return false;
    }
  }
  return saveAvto(avto, mytoken);
}

Future<bool> saveAvto(AvtomobilRemote a, mytoken) async {
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };

  headers.addAll({'Authorization': 'Bearer $mytoken'});
  var marka = a.marka;
  var nomer = a.nomer;
  var date = DateTime.now().toIso8601String();
  var status = "VYPOLNENA";
  var zayavkaId = a.zayavka.value?.id;
  var fotos = [];
  for (Foto f in a.fotos.toList()) {
    if (f.file != null) fotos.add({"file": f.file});
  }
  var performance_service = [];
  for (Usluga f in a.performance_service.toList()) {
    performance_service.add({"title": f.title});
  }
  var barcode = [];
  for (Oborudovanie f in a.barcode.toList()) {
    barcode.add({"code": f.code});
  }

  var data = json.encode({
    "avto": {
      "zayavka": {"id": "$zayavkaId"},
      "marka": "$marka",
      "nomer": "$nomer",
      "date": "$date",
      "fotos": fotos,
      "barcode": barcode,
      "performance_service": performance_service,
      "status": status
    }
  });
  var dio = Dio();
  var response = await dio.request(
    '${site}rest/services/flutterService/saveAvto',
    options: Options(
      method: 'POST',
      headers: headers,
    ),
    data: data,
  );

  if (response.statusCode == 200) {
    print(json.encode(response.data));
  } else {
    return false;
  }
  return true;
}

addChekLocalFiles(Chek chek) async {
  var result = await FilePicker.platform.pickFiles(allowMultiple: true);

  if (result != null) {
    List<String?> files = result.paths.map((path) => path!).toList();
    for (var file in files) {
      ChekFoto f = ChekFoto(fileLocal: file, chek: BelongsTo(chek));
      chek.fotos.add(f);
      f.saveLocal();
    }
    chek.saveLocal();
  } else {
    final snackBar = SnackBar(
      content: const Text('файлы не добавлены'),
    );
  }
}

Future<bool> saveChekWithPhotos(Chek chek, WidgetRef ref, mytoken) async {
  for (ChekFoto foto in chek.fotos.toList()) {
    var headers = {
      'Content-Type': 'image/jpeg',
      'Authorization': 'Bearer $mytoken'
    };
    var data = File(foto.fileLocal!).readAsBytesSync();

    var dio = Dio();
    var response = await dio.request(
      '${site}rest/files?name=chek.jpg',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: data,
    );

    if (response.statusCode == 201) {
      print(response.data);
      String f = response.data['fileRef'];
      foto.file = f;
    } else {
      return false;
    }
  }
  return saveChek(chek, mytoken);
}

Future<bool> saveChek(Chek a, mytoken) async {
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };

  headers.addAll({'Authorization': 'Bearer $mytoken'});

  var date = DateTime.now().toIso8601String();
  var fotos = [];
  for (ChekFoto f in a.fotos.toList()) {
    if (f.file != null) fotos.add({"file": f.file});
  }

  var data = json.encode({
    "chek": {
      "date": "$date",
      "fotos": fotos,
      "comment": a.comment,
      "username": a.username
    }
  });
  var dio = Dio();
  var response = await dio.request(
    '${site}rest/services/flutterService/saveChek',
    options: Options(
      method: 'POST',
      headers: headers,
    ),
    data: data,
  );

  if (response.statusCode == 200) {
    print(json.encode(response.data));
  } else {
    return false;
  }
  return true;
}

Future<bool> login(String username, String password, String mytoken) async {
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };

  headers.addAll({'Authorization': 'Bearer ${mytoken}'});

  var data =
      json.encode({"username": "${username}", "password": "${password}"});
  var dio = Dio();
  var response = await dio.request(
    '${site}rest/services/flutterService/login',
    options: Options(
      method: 'POST',
      headers: headers,
    ),
    data: data,
  );

  if (response.statusCode == 200) {
    print(json.encode(response.data));
    if (response.data != "ok") {
      return false;
    }
  } else {
    return false;
  }
  return true;
}

Future<bool> updateZayavka(ZayavkaRemote zayavka, String mytoken) async {
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };

  headers.addAll({'Authorization': 'Bearer $mytoken'});

  var data = json.encode({
    "zayavka": {"id": "${zayavka.id}", "status": "VYPOLNENA"}
  });
  var dio = Dio();
  var response = await dio.request(
    '${site}rest/services/flutterService/sendZayavkaUpdate',
    options: Options(
      method: 'POST',
      headers: headers,
    ),
    data: data,
  );

  if (response.statusCode == 200) {
    print(json.encode(response.data));
  } else {
    return false;
  }
  return true;
}

final Uri _url = Uri.parse('content://com.android.calendar/time/');
Future<void> _launchUrl() async {
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}

Future<String> getTokenFromServer() async {
  String username = 'my-client';
  String password = 'my-secret';
  String basicAuth =
      'Basic ${base64.encode(utf8.encode('$username:$password'))}';
  print(basicAuth);
  var dio = Dio();
  var data = "grant_type=client_credentials";
  var headers = {
    'Content-Type': 'application/x-www-form-urlencoded',
    'Authorization': basicAuth
  };
  var response = await dio.request('${site}oauth2/token',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: data);

  return response.data['access_token'];
}

loadZ(WidgetRef ref) async {
  String? myCal;
  var cs = await _deviceCalendarPlugin.retrieveCalendars();
  var cx = cs.data!.firstWhere(
    (element) => element.name == 'bpium2',
    orElse: () => Calendar(id: null),
  );
  if (cx.id == null) {
    var r = await _deviceCalendarPlugin.createCalendar("bpium2");
    myCal = r.data;
  } else {
    myCal = cx.id;
  }

  List<ZayavkaRemote> zs = await ref.zayavkaRemotes.findAll();

  Location _currentLocation = getLocation('UTC');
  for (ZayavkaRemote z in zs) {
    if (z.events.isEmpty) {
      if (z.nachalo != null) {
        Event event = Event(myCal, title: z.nomer);

        event.end = TZDateTime.from(z.nachalo!, _currentLocation);
        event.start = TZDateTime.from(z.nachalo!, _currentLocation);

        event.description = z.message;
        event.eventId = z.id;
        Result<String>? r =
            await _deviceCalendarPlugin.createOrUpdateEvent(event);
        CalendarEvent ce =
            CalendarEvent(zayavka: BelongsTo(z), calId: r!.data!);
        z.events.add(ce);
        ce.saveLocal();
        z.saveLocal();
      }
    }
  }
}

DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
