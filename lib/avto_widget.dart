import 'dart:convert';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:fluttsec/main.dart';
import 'package:fluttsec/main.data.dart';
import 'package:fluttsec/src/models/avtomobilRemote.dart';
import 'package:fluttsec/src/models/foto.dart';
import 'package:fluttsec/src/models/oborudovanie.dart';
import 'package:fluttsec/src/models/oborudovanieFoto.dart';
import 'package:fluttsec/src/models/usluga.dart';
import 'package:fluttsec/src/models/uslugaSelect.dart';
import 'package:fluttsec/src/models/zayavkaRemote.dart';
import 'package:fluttsec/src/remote/save_with_photos.dart';
import 'package:fluttsec/usluga_select_screen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:workmanager/workmanager.dart';

class AvtoWidget extends HookConsumerWidget {
  AvtomobilRemote avto;

  ZayavkaRemote zayavka;

  AvtoWidget(AvtomobilRemote this.avto, ZayavkaRemote this.zayavka,
      {super.key});
  void _saveComment(String text) {}
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    avto = ref.avtomobilRemotes.watch(avto);
    zayavka = ref.zayavkaRemotes.watch(zayavka);
    var commentController = TextEditingController(text: avto.comment);

    return ExpansionTile(
        trailing: SizedBox.shrink(),
        collapsedShape: const ContinuousRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        title: Row(children: [
          Expanded(
            flex: 2,
            child: Text(
                '${avto.nomer}\n${avto.marka}${(avto.nomerAG == null || avto.nomerAG == "null"|| avto.nomerAG == "") ? '' : '\nАГ:' + avto.nomerAG!}'),
          ),
          ElevatedButton(
              onPressed: avto.status != "NOVAYA"
                  ? null
                  : () => showDeleteAlertAvto(context, zayavka, avto),
              child: const Icon(Icons.cancel)),
        ]),
        collapsedBackgroundColor: avto.status != "NOVAYA"
            ? Colors.grey.shade200
            : Color.fromARGB(255, 247, 130, 139),
        children: <Widget>[
          const SizedBox(width: 8),
          const SizedBox(width: 8),
          Text(
            'Фотоотчет:',
            style: TextStyle(fontSize: 20),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(
                    Colors.blue.shade100), // Change button color
              ),
              child: const Icon(Icons.attach_file_rounded),
              onPressed: avto.status != "NOVAYA"
                  ? null
                  : () {
                      addFotos(zayavka, avto);
                    },
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(
                    Colors.blue.shade100), // Change button color
              ),
              child: const Icon(Icons.add_a_photo),
              onPressed: avto.status != "NOVAYA"
                  ? null
                  : () {
                      addFoto(zayavka, avto);
                    },
            ),
          ]),
          if (!avto.fotos.isEmpty)
            CarouselSlider(
                options: CarouselOptions(autoPlay: true, height: 150.0),
                items: [
                  for (Foto foto in avto.fotos.toList())
                    Stack(children: <Widget>[
                      ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image(
                            image: FileImage(File(foto.fileLocal!)),
                            height: 180,
                          )),
                      Positioned(
                          right: -2,
                          top: -9,
                          child: IconButton(
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.black.withOpacity(0.5),
                              size: 50,
                            ),
                            onPressed: avto.status != "NOVAYA"
                                ? null
                                : () {
                                    foto.deleteLocal();
                                    avto.saveLocal();
                                    zayavka.saveLocal();
                                  },
                          ))
                    ])
                ]),
          Text(
            'Услуги:',
            style: TextStyle(fontSize: 20),
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(
                  Colors.blue.shade100), // Change button color
            ),
            child: const Icon(Icons.build_circle_rounded),
            onPressed: avto.status != "NOVAYA"
                ? null
                : () async {
                    UslugaSelect? result = await Navigator.push(
                      context,
                      // Create the SelectionScreen in the next step.
                      MaterialPageRoute(
                          builder: (context) => UslugaSelectScreen(avto: avto)),
                    );
                    zayavka.saveLocal();
                  },
          ),
          for (Usluga usluga in avto.performance_service.toList())
            Container(
              padding: EdgeInsets.all(0),
              child: Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blue.shade200,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Text(
                        style: TextStyle(fontSize: 17),
                        '${usluga.title}',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: avto.status != "NOVAYA"
                          ? null
                          : () {
                              usluga.dop = usluga.dop == "Y" ? "N" : "Y";
                              usluga.saveLocal();
                              avto.saveLocal();
                              zayavka.saveLocal();
                            },
                      child: usluga.dop == "Y"
                          ? Icon(Icons.timer)
                          : Icon(Icons.timer_outlined),
                    ),
                  ],
                ),
              ),
            ),
          Text(
            'Оборудование:',
            style: TextStyle(fontSize: 20),
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(
                  Colors.blue.shade100), // Change button color
            ),
            child: const Icon(Icons.barcode_reader),
            onPressed: avto.status != "NOVAYA"
                ? null
                : () async {
                    var res = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const SimpleBarcodeScannerPage(),
                        ));
                    if (res is String && res != '-1') {
                      Oborudovanie o = Oborudovanie(
                          avtomobil: BelongsTo<AvtomobilRemote>(avto),
                          code: res);

                      o.saveLocal();
                      avto.saveLocal();
                      zayavka.saveLocal();
                    }
                  },
          ),
          for (Oborudovanie oborudovanie in avto.barcode.toList())
            Container(
              padding: EdgeInsets.all(0),
              child: Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blue.shade200,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Text(
                        style: TextStyle(fontSize: 17),
                        '${oborudovanie.code}',
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          oborudovanie.deleteLocal();
                          avto.saveLocal();
                          zayavka.saveLocal();
                        },
                        child: Icon(Icons.cancel))
                  ],
                ),
              ),
            ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(
                    Colors.blue.shade100), // Change button color
              ),
              child: const Icon(Icons.attach_file),
              onPressed: avto.status != "NOVAYA"
                  ? null
                  : () {
                      addOborudovanieFotos(zayavka, avto);
                    },
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(
                    Colors.blue.shade100), // Change button color
              ),
              child: const Icon(Icons.add_a_photo),
              onPressed: avto.status != "NOVAYA"
                  ? null
                  : () {
                      addOborudovanieFoto(zayavka, avto);
                    },
            ),
          ]),
          if (!avto.oborudovanieFotos.isEmpty)
            CarouselSlider(options: CarouselOptions(height: 150.0), items: [
              for (OborudovanieFoto foto in avto.oborudovanieFotos.toList())
                Stack(children: <Widget>[
                  ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image(
                        image: FileImage(File(foto.fileLocal!)),
                        height: 180,
                      )),
                  Positioned(
                      right: -2,
                      top: -9,
                      child: IconButton(
                        icon: Icon(
                          Icons.cancel,
                          color: Colors.black.withOpacity(0.5),
                          size: 50,
                        ),
                        onPressed: () {
                          foto.deleteLocal();
                          avto.saveLocal();
                          zayavka.saveLocal();
                        },
                      ))
                ])
            ]),
          TextFormField(
            controller: commentController,
            decoration: InputDecoration(hintText: 'коммментарий'),
          ),
          ElevatedButton(
              onPressed: () {
                if (commentController.text.length > 199)
                  commentController.text =
                      commentController.text.substring(0, 199);
                avto.comment = commentController.text;
                avto.saveLocal();
                zayavka.saveLocal();
              },
              child: Icon(Icons.add)),
          ElevatedButton(
              onPressed: avto.status != "NOVAYA"
                  ? null
                  : () async {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: Text('Отправка отчета'),
                            content: ListView(
                              shrinkWrap: true,
                              children: [
                                Text('Уверены что хотите отправить отчет?')
                              ],
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Отмена'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  sendAvtoOtchet();
                                  Navigator.pop(context);
                                },
                                child: Text('Отправить'),
                              ),
                            ],
                          );
                        },
                      );
                    },
              child: const Text("готово")),
        ]);
  }

  Future<void> sendAvtoOtchet() async {
    avto.status = 'TEMP';
    avto.saveLocal();
    zayavka.saveLocal();
    bool r = false;
    if (avto.zayavka?.id == null) showError(avto.toString());
    try {
      r = await sendAvto(avto, token.value);
    } on Exception catch (e) {
      avto.status = "PENDING";
      avto.saveLocal();
      zayavka.saveLocal();

      var b = avto.barcode
          .map(
            (Oborudovanie p0) => p0.code!,
          )
          .toList();
      var f = avto.fotos.map((p0) => p0.fileLocal!).toList();
      var o = avto.oborudovanieFotos
          .map((OborudovanieFoto p0) => p0.fileLocal!)
          .toList();
      var p = avto.performance_service
          .where(
            (element) => element.dop == 'N',
          )
          .map(
            (p0) => p0.code!,
          )
          .toList();
      var pd = avto.performance_service
          .where(
            (element) => element.dop == 'Y',
          )
          .map((p0) => p0.code!)
          .toList();

      final prefs = await SharedPreferences.getInstance();

      prefs.setString(avto.id!, "Eee");

      Workmanager().  registerOneOffTask(
        avto.id!,
        rescheduledTaskKey,
        initialDelay: Duration(seconds: 10),
        existingWorkPolicy: ExistingWorkPolicy.keep,
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
        inputData: <String, dynamic>{
          'token': token.value,
          'barcode': b,
          'comment': avto.comment ?? '',
          'date': DateTime.now().toIso8601String(),
          'fotos': f,
          'marka': avto.marka ?? "",
          'nomer': avto.nomer ?? "",
          'nomerAG': avto.nomerAG ?? "",
          'oborudovanieFotos': o,
          'performance_service': p,
          'performance_service_dop': pd,
          'status': avto.status!,
          'id': avto.id.toString(),
          'zayavkaId': avto.zayavka!.id.toString()
        },
      );
    }

    if (r) {
      avto.status = "GOTOWAYA";
      avto.saveLocal();
      zayavka.saveLocal();
      infoToast("Сохранено в системе");
    } else {
      avto.status = "PENDING";
      avto.saveLocal();
      zayavka.saveLocal();

      infoToast("Не удалось отправить, добавляем в загрузки");
    }
  }

  addOborudovanieFotos(ZayavkaRemote zayavka, AvtomobilRemote avto) async {
    final ImagePicker _picker = ImagePicker();

    var pickedFiles =
        await _picker.pickMultiImage(imageQuality: 30, maxHeight: 2000);

    if (!pickedFiles.isEmpty) {
      for (var pickedFile in pickedFiles) {
        OborudovanieFoto f = OborudovanieFoto(
            fileLocal: pickedFile.path,
            avtomobil: BelongsTo<AvtomobilRemote>(avto));
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

  addOborudovanieFoto(ZayavkaRemote zayavka, AvtomobilRemote avto) async {
    final ImagePicker _picker = ImagePicker();

    var pickedFile = await _picker.pickImage(
        source: ImageSource.camera, imageQuality: 30, maxHeight: 2000);

    if (pickedFile != null) {
      OborudovanieFoto f = OborudovanieFoto(
          fileLocal: pickedFile.path,
          avtomobil: BelongsTo<AvtomobilRemote>(avto));
      f.saveLocal();
      avto.saveLocal();
      zayavka.saveLocal();
    } else {
      final snackBar = SnackBar(
        content: const Text('фото не добавлено'),
      );
    }
  }

  dynamic showError(e) {
    infoToast("На сервере произошла ошибка" + e);
    return null;
  }
}

void showDeleteAlertAvto(context, ZayavkaRemote zayavka, AvtomobilRemote avto) {
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

void addOborudovanieFotos(ZayavkaRemote zayavka, AvtomobilRemote avto) {}
addFoto(ZayavkaRemote zayavka, AvtomobilRemote avto) async {
  final ImagePicker _picker = ImagePicker();

  var pickedFile = await _picker.pickImage(
      source: ImageSource.camera, imageQuality: 30, maxHeight: 2000);

  if (pickedFile != null) {
    Foto f = Foto(
        fileLocal: pickedFile.path,
        avtomobil: BelongsTo<AvtomobilRemote>(avto));
    f.saveLocal();

    avto.saveLocal();
    zayavka.saveLocal();
  } else {
    final snackBar = SnackBar(
      content: const Text('фото не добавлено'),
    );
  }
}

addFotos(ZayavkaRemote zayavka, AvtomobilRemote avto) async {
  final ImagePicker _picker = ImagePicker();

  var pickedFiles =
      await _picker.pickMultiImage(imageQuality: 30, maxHeight: 2000);

  if (!pickedFiles.isEmpty) {
    for (var pickedFile in pickedFiles) {
      Foto f = Foto(
          fileLocal: pickedFile.path,
          avtomobil: BelongsTo<AvtomobilRemote>(avto));
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
