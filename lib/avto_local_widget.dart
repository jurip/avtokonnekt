import 'dart:convert';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:fluttsec/main.dart';
import 'package:fluttsec/main.data.dart';
import 'package:fluttsec/src/models/avtomobilLocal.dart';
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

class AvtoLocalWidget extends HookConsumerWidget {
  AvtomobilLocal avto;

  ZayavkaRemote zayavka;

  AvtoLocalWidget(AvtomobilLocal this.avto, ZayavkaRemote this.zayavka,
      {super.key});
  void _saveComment(String text) {}
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    avto = ref.avtomobilLocals.watch(avto);
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
                             
                            ],
                          );
                        },
                      );
                    },
              child: const Text("готово")),
        ]);
  }

 
  dynamic showError(e) {
    infoToast("На сервере произошла ошибка" + e);
    return null;
  }
}

void showDeleteAlertAvto(context, ZayavkaRemote zayavka, AvtomobilLocal avto) {
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

void showDeleteAlertAvtoLocal(context, ZayavkaRemote zayavka, AvtomobilLocal avto) {
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
