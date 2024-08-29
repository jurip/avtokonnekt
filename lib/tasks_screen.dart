import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:fluttsec/usluga_select_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluttsec/main.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:fluttsec/main.data.dart';
import 'package:fluttsec/src/remote/save_with_photos.dart';
import 'package:fluttsec/send_zayavka_to_calendar.dart';
import 'package:fluttsec/src/models/avtomobilRemote.dart';
import 'package:fluttsec/src/models/foto.dart';
import 'package:fluttsec/src/models/oborudovanie.dart';
import 'package:fluttsec/src/models/usluga.dart';
import 'package:fluttsec/src/models/uslugaSelect.dart';
import 'package:fluttsec/src/models/zayavkaRemote.dart';
import 'package:fluttsec/src/remote/update_zayavka.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TasksScreen extends HookConsumerWidget {
  TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        ZayavkaRemote z = ZayavkaRemote(message.data["id"],
            nomer: message.data["nomer"], adres: message.data["adres"]);
        z.saveLocal();
        sendZayavkaToCalendar(z, getLocation('UTC'), myCal);
        if (kDebugMode) {
          print('Handling a foreground message: ${message.messageId}');
          print('Message data: ${message.data}');
          print('Message notification: ${message.notification?.title}');
          print('Message notification: ${message.notification?.body}');
        }
      });

      return null;
    });

    return ref.watch(repositoryInitializerProvider).when(
        error: (error, _) => Text(error.toString()),
        loading: () => const CircularProgressIndicator(),
        data: (_) {
          final stateLocal = ref.zayavkaRemotes.watchAll();
          final stateDuty = ref.duties.watchAll();
       
          return RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: () async {
                await ref.duties.findAll();
                List<ZayavkaRemote> zs = await ref.zayavkaRemotes.findAll();
                for (ZayavkaRemote z in zs) {
                  sendZayavkaToCalendar(z, getLocation('UTC'), myCal);
                }
              },
              // Pull from top to show refresh indicator.
              child: ListView(
                children: [
                  for (final duty in stateDuty.model)
                    Text(
                      '${duty.fio} - ${duty.status}',
                      style: TextStyle(fontSize: 20),
                    ),
                  ElevatedButton(
                    child: const Text('выйти'),
                    onPressed: () {
                      logout();
                      context.go('/login');
                    },
                  ),
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
                                        subtitle: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                  '${zayavka.nachalo}\n${zayavka.client}'),
                                              GestureDetector(
                                                child: Text(
                                                  '${zayavka.adres}',
                                                ),
                                                onTap: () =>
                                                    MapsLauncher.launchQuery(
                                                        zayavka.adres!),
                                              ),
                                              if(zayavka.lat!=null&&zayavka.lng!=null)
                                               GestureDetector(
                                                child: Icon(Icons.navigation),
                                                onTap: () =>  MapsLauncher.launchCoordinates(double.parse( zayavka.lat!), double.parse( zayavka.lng!)),
                                              ),
                                              GestureDetector(
                                                child: Text(
                                                  '${zayavka.contact_number}',
                                                ),
                                                onTap: () => launchUrlString(
                                                    "tel://${zayavka.contact_number}"),
                                              ),
                                              GestureDetector(
                                                child: Icon(Icons.phone),
                                                onTap: () => launchUrlString(
                                                    "tel://${zayavka.contact_number}"),
                                              ),
                                              Text(
                                                  '${zayavka.contact_name}\n${zayavka.message} '),
                                            ])),
                                    ExpansionTile(
                                        title: Text('Автомобили'),
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: <Widget>[
                                              const SizedBox(width: 8),
                                              ElevatedButton(
                                                child: const Text('авто+'),
                                                onPressed: () {
                                                  novoeAvto(context, zayavka);
                                                },
                                              ),
                                              const SizedBox(width: 8),
                                            ],
                                          ),
                                          for (AvtomobilRemote avto
                                              in zayavka.avtomobili.toList())
                                            ExpansionTile(
                                                title: Text('${avto.nomer}'),
                                                collapsedBackgroundColor:
                                                    avto.status != "NOVAYA"
                                                        ? Colors.grey
                                                        : Color.fromARGB(
                                                            255, 231, 40, 56),
                                                children: <Widget>[
                                                  ElevatedButton(
                                                      onPressed: avto.status !=
                                                              "NOVAYA"
                                                          ? null
                                                          : () async {
                                                              checkConnection();
                                                              bool ok =
                                                                  await saveWithPhotos(
                                                                      avto,
                                                                      ref,
                                                                      token
                                                                          .value);
                                                              if (ok) {
                                                                avto.status =
                                                                    "GOTOWAYA";
                                                                avto.saveLocal();
                                                                zayavka
                                                                    .saveLocal();
                                                                Fluttertoast.showToast(
                                                                    msg:
                                                                        "Отправлено",
                                                                    toastLength:
                                                                        Toast
                                                                            .LENGTH_SHORT,
                                                                    gravity: ToastGravity
                                                                        .CENTER,
                                                                    timeInSecForIosWeb:
                                                                        1,
                                                                    backgroundColor:
                                                                        Color.fromARGB(
                                                                            255,
                                                                            54,
                                                                            155,
                                                                            244),
                                                                    textColor:
                                                                        Colors
                                                                            .white,
                                                                    fontSize:
                                                                        16.0);
                                                              } else {
                                                                Fluttertoast.showToast(
                                                                    msg:
                                                                        "Не удалось послать",
                                                                    toastLength:
                                                                        Toast
                                                                            .LENGTH_SHORT,
                                                                    gravity: ToastGravity
                                                                        .CENTER,
                                                                    timeInSecForIosWeb:
                                                                        1,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .red,
                                                                    textColor:
                                                                        Colors
                                                                            .white,
                                                                    fontSize:
                                                                        16.0);
                                                              }
                                                            },
                                                      child:
                                                          const Text("готово")),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    avto.nomer ?? "-",
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(avto.marka ?? "-"),
                                                  ElevatedButton(
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          WidgetStateProperty
                                                              .all<Color>(Colors
                                                                  .blue), // Change button color
                                                    ),
                                                    child: const Text('фото+'),
                                                    onPressed: avto.status !=
                                                            "NOVAYA"
                                                        ? null
                                                        : () {
                                                            addLocalFiles(
                                                                zayavka, avto);
                                                          },
                                                  ),
                                                  CarouselSlider(
                                                    options: CarouselOptions(
                                                        height: 200.0),
                                                    items: [
                                                      for (Foto foto in avto
                                                          .fotos
                                                          .toList())
                                                        ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                            child: Image(
                                                              image: FileImage(
                                                                  File(foto
                                                                      .fileLocal!)),
                                                              height: 180,
                                                            ))
                                                    ],
                                                  ),
                                                  ElevatedButton(
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          WidgetStateProperty
                                                              .all<Color>(Colors
                                                                  .blue), // Change button color
                                                    ),
                                                    child: const Text('услуга'),
                                                    onPressed: avto.status !=
                                                            "NOVAYA"
                                                        ? null
                                                        : () async {
                                                            UslugaSelect? result =
                                                                await Navigator
                                                                    .push(
                                                              context,
                                                              // Create the SelectionScreen in the next step.
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          UslugaSelectScreen()),
                                                            );
                                                            if(result!=null){
                                                            Usluga newU = Usluga(
                                                                avtomobil:
                                                                    BelongsTo(
                                                                        avto),
                                                                title: result
                                                                    .title
                                                                    .toString());
                                                            avto.performance_service
                                                                .add(newU);
                                                            newU.saveLocal();
                                                            avto.saveLocal();
                                                            zayavka.saveLocal();
                                                            }

                                                          },
                                                  ),
                                                  for (Usluga usluga in avto
                                                      .performance_service
                                                      .toList())
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        usluga.deleteLocal();
                                                        avto.saveLocal();
                                                        zayavka.saveLocal();
                                                      },
                                                      child: Text(
                                                        '${usluga.title}',
                                                        overflow:
                                                            TextOverflow.fade,
                                                        softWrap: false,
                                                      ),
                                                    ),
                                                  ElevatedButton(
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          WidgetStateProperty
                                                              .all<Color>(Colors
                                                                  .blue), // Change button color
                                                    ),
                                                    child: const Text(
                                                        'оборудование'),
                                                    onPressed:
                                                        avto.status != "NOVAYA"
                                                            ? null
                                                            : () async {
                                                                var res =
                                                                    await Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              const SimpleBarcodeScannerPage(),
                                                                        ));
                                                                if (res is String &&
                                                                    res !=
                                                                        '-1') {
                                                                  Oborudovanie o = Oborudovanie(
                                                                      avtomobil:
                                                                          BelongsTo(
                                                                              avto),
                                                                      code:
                                                                          res);
                                                                  avto.barcode
                                                                      .add(o);
                                                                  o.saveLocal();
                                                                  avto.saveLocal();
                                                                  zayavka
                                                                      .saveLocal();
                                                                }
                                                              },
                                                  ),
                                                  for (Oborudovanie oborudovanie
                                                      in avto.barcode.toList())
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        oborudovanie
                                                            .deleteLocal();
                                                        avto.saveLocal();
                                                        zayavka.saveLocal();
                                                      },
                                                      child: Text(
                                                        '${oborudovanie.code}',
                                                        overflow:
                                                            TextOverflow.fade,
                                                        softWrap: false,
                                                      ),
                                                    ),
                                                ])
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

  void novoeAvto(context, ZayavkaRemote zayavka) {
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

  addLocalFiles(ZayavkaRemote zayavka, AvtomobilRemote avto) async {
    final ImagePicker _picker = ImagePicker();

    final List<XFile> pickedFileList = await _picker.pickMultiImage();

    if (!pickedFileList.isEmpty) {
      for (var file in pickedFileList) {
        Foto f = Foto(fileLocal: file.path, avtomobil: BelongsTo(avto));
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

  void logout() {
    user.value = '';
    password.value = '';
  }
}
