import 'dart:convert';
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
import 'package:intl/intl.dart';
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
                      style: TextStyle(fontSize: 25),
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
                        title: Text('${zayavka.nomer}',
                            style: TextStyle(fontSize: 23)),
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
                                              if (zayavka.nachalo != null)
                                                Text(
                                                    '${DateFormat('MM.dd.yy – kk:mm').format(zayavka.nachalo!)}',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              Text('${zayavka.client}'),
                                              GestureDetector(
                                                child: Text('${zayavka.adres}',
                                                    style: TextStyle(
                                                        fontSize: 23)),
                                                onTap: () =>
                                                    MapsLauncher.launchQuery(
                                                        zayavka.adres!),
                                              ),
                                              ElevatedButton(
                                                  child: const Icon(
                                                      Icons.navigation),
                                                  onPressed: () {
                                                    if (zayavka.lat != "" &&
                                                        zayavka.lng != "")
                                                      MapsLauncher
                                                          .launchCoordinates(
                                                              double.parse(
                                                                  zayavka.lat!),
                                                              double.parse(
                                                                  zayavka
                                                                      .lng!));
                                                    else
                                                      MapsLauncher.launchQuery(
                                                          zayavka.adres!);
                                                  }),
                                              GestureDetector(
                                                child: Text(
                                                    '${zayavka.contact_number}',
                                                    style: TextStyle(
                                                        fontSize: 23)),
                                                onTap: () => launchUrlString(
                                                    "tel://${zayavka.contact_number}"),
                                              ),
                                              ElevatedButton(
                                                child: const Icon(Icons.phone),
                                                onPressed: () => launchUrlString(
                                                    "tel://${zayavka.contact_number}"),
                                              ),
                                              Text('${zayavka.contact_name}',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text('${zayavka.message} ',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w500)),
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
                                                          : () {
                                                              checkConnection();
                                                              bool ok = true;
                                                              Future<bool>
                                                                  resultOfSave =
                                                                  saveWithPhotos(
                                                                      avto,
                                                                      ref,
                                                                      token
                                                                          .value);
                                                              resultOfSave.then(
                                                                (value) {
                                                                  if (value) {
                                                                    avto.status =
                                                                        "GOTOWAYA";
                                                                    avto.saveLocal();
                                                                    zayavka
                                                                        .saveLocal();
                                                                    infoToast(
                                                                        "Сохранено в системе");
                                                                  } else {
                                                                    infoToast(
                                                                        "Ошибка при сохранении в системе");
                                                                  }
                                                                },
                                                              );

                                                              infoToast(
                                                                  "Отправлено");
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
                                                      onPressed: () =>
                                                          showDeleteAlertAvto(
                                                              context,
                                                              zayavka,
                                                              avto),
                                                      child: const Icon(
                                                          Icons.delete)),
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
                                                            addFotos(
                                                                zayavka, avto);
                                                          },
                                                  ),
                                                  ElevatedButton(
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          WidgetStateProperty
                                                              .all<Color>(Colors
                                                                  .blue), // Change button color
                                                    ),
                                                    child: const Text('камера'),
                                                    onPressed: avto.status !=
                                                            "NOVAYA"
                                                        ? null
                                                        : () {
                                                            addFoto(
                                                                zayavka, avto);
                                                          },
                                                  ),
                                                  CarouselSlider(
                                                      options: CarouselOptions(
                                                          height: 230.0),
                                                      items: [
                                                        for (Foto foto in avto
                                                            .fotos
                                                            .toList())
                                                          Stack(
                                                              children: <Widget>[
                                                                ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0),
                                                                    child:
                                                                        Image(
                                                                      image: FileImage(
                                                                          File(foto
                                                                              .fileLocal!)),
                                                                      height:
                                                                          180,
                                                                    )),
                                                                Positioned(
                                                                    right: -2,
                                                                    top: -9,
                                                                    child:
                                                                        IconButton(
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .cancel,
                                                                        color: Colors
                                                                            .black
                                                                            .withOpacity(0.5),
                                                                        size:
                                                                            50,
                                                                      ),
                                                                      onPressed:
                                                                          () {
                                                                        foto.deleteLocal();
                                                                        avto.saveLocal();
                                                                        zayavka
                                                                            .saveLocal();
                                                                      },
                                                                    ))
                                                              ])
                                                      ]),
                                                  ElevatedButton(
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          WidgetStateProperty
                                                              .all<Color>(Colors
                                                                  .blue), // Change button color
                                                    ),
                                                    child: const Text('услуга'),
                                                    onPressed:
                                                        avto.status != "NOVAYA"
                                                            ? null
                                                            : () async {
                                                                UslugaSelect?
                                                                    result =
                                                                    await Navigator
                                                                        .push(
                                                                  context,
                                                                  // Create the SelectionScreen in the next step.
                                                                  MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          UslugaSelectScreen(
                                                                              avto: avto)),
                                                                );
                                                                zayavka
                                                                    .saveLocal();
                                                              },
                                                  ),
                                                  for (Usluga usluga in avto
                                                      .performance_service
                                                      .toList())
                                                    Row(
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            style: TextStyle(
                                                                fontSize: 23),
                                                            '${usluga.title}',
                                                            overflow:
                                                                TextOverflow
                                                                    .fade,
                                                            softWrap: false,
                                                          ),
                                                        ),
                                                        ElevatedButton(
                                                            onPressed: () {
                                                              usluga
                                                                  .deleteLocal();
                                                              avto.saveLocal();
                                                              zayavka
                                                                  .saveLocal();
                                                            },
                                                            child: Icon(
                                                                Icons.delete))
                                                      ],
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
                                                    Row(
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            style: TextStyle(
                                                                fontSize: 23),
                                                            '${oborudovanie.code}',
                                                            overflow:
                                                                TextOverflow
                                                                    .fade,
                                                            softWrap: false,
                                                          ),
                                                        ),
                                                        ElevatedButton(
                                                            onPressed: () {
                                                              oborudovanie
                                                                  .deleteLocal();
                                                              avto.saveLocal();
                                                              zayavka
                                                                  .saveLocal();
                                                            },
                                                            child: Icon(
                                                                Icons.delete))
                                                      ],
                                                    )
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

  void infoToast(String text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Color.fromARGB(255, 54, 155, 244),
        textColor: Colors.white,
        fontSize: 16.0);
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

  void showDeleteAlertAvto(
      context, ZayavkaRemote zayavka, AvtomobilRemote avto) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Удаление автомобиля'),
          content: ListView(
            shrinkWrap: true,
            children: [Text('Уверены что хотите удалить авто?')],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                avto.deleteLocal();
                zayavka.saveLocal();
                Navigator.pop(context);
              },
              child: Text('Удалить'),
            ),
          ],
        );
      },
    );
  }

  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  addFotos(ZayavkaRemote zayavka, AvtomobilRemote avto) async {
    final ImagePicker _picker = ImagePicker();

    var pickedFiles = await _picker.pickMultiImage(imageQuality: 30);

    if (!pickedFiles.isEmpty) {
      for (var pickedFile in pickedFiles) {
        Foto f = Foto(fileLocal: pickedFile.path, avtomobil: BelongsTo(avto));
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

  addFoto(ZayavkaRemote zayavka, AvtomobilRemote avto) async {
    final ImagePicker _picker = ImagePicker();

    var pickedFile =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 30);

    if (pickedFile != null) {
      Foto f = Foto(fileLocal: pickedFile.path, avtomobil: BelongsTo(avto));
      avto.fotos.add(f);
      f.saveLocal();

      avto.saveLocal();
      zayavka.saveLocal();
    } else {
      final snackBar = SnackBar(
        content: const Text('фото не добавлено'),
      );
    }
  }

  void logout() {
    user.value = '';
    password.value = '';
  }
}
