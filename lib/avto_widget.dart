import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttsec/image_screen.dart';
import 'package:fluttsec/main.dart';
import 'package:fluttsec/main.data.dart';
import 'package:fluttsec/src/models/avtomobilRemote.dart';
import 'package:fluttsec/src/models/foto.dart';
import 'package:fluttsec/src/models/oborudovanie.dart';
import 'package:fluttsec/src/models/oborudovanieFoto.dart';
import 'package:fluttsec/src/models/user.dart';
import 'package:fluttsec/src/models/userSelect.dart';
import 'package:fluttsec/src/models/usluga.dart';
import 'package:fluttsec/src/models/uslugaSelect.dart';
import 'package:fluttsec/src/models/zayavkaRemote.dart';
import 'package:fluttsec/src/remote/save_with_photos.dart';
import 'package:fluttsec/user_select_screen.dart';
import 'package:fluttsec/usluga_select_screen.dart';
import 'package:gal/gal.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:uuid/uuid.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

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

    var _speechToText = useState(SpeechToText());
    useEffect(
      () {
        _speechToText.value.initialize();
        return null;
      },
    );

    return ExpansionTile(
        trailing: SizedBox.shrink(),
        collapsedShape: const ContinuousRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        title: Row(children: [
          for (var image in avto.avtoFoto.toList())
            GestureDetector(
                onTap: () {
                  Navigator.push<Widget>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageScreen(image.fileLocal!),
                    ),
                  );
                },
                child: Image(
                  image: FileImage(
                    File(image.fileLocal!),
                  ),
                  height: 50,
                )),
          Expanded(
            flex: 2,
            child: Text(
                '${avto.nomer}\n${avto.marka}${(avto.nomerAG == null || avto.nomerAG == "null" || avto.nomerAG == "") ? '' : '\nАГ:' + avto.nomerAG!}'),
          ),
          if (avto.status == "TEMP")
            ElevatedButton(
                onPressed: () => {avto.status = "NOVAYA", avto.saveLocal()},
                child: const Icon(Icons.refresh)),
          ElevatedButton(
              onPressed: notNew
                  ? null
                  : () => showDeleteAlertAvto(context, zayavka, avto),
              child: const Icon(Icons.cancel)),
        ]),
        collapsedBackgroundColor:
            notNew ? Colors.grey.shade200 : Color.fromARGB(255, 247, 130, 139),
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
              onPressed: notNew
                  ? null
                  : () {
                      addFotos(zayavka, avto, context);
                    },
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(
                    Colors.blue.shade100), // Change button color
              ),
              child: const Icon(Icons.add_a_photo),
              onPressed: notNew
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
                        child: GestureDetector(
                            onTap: () {
                              Navigator.push<Widget>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ImageScreen(foto.fileLocal!),
                                ),
                              );
                            },
                            child: Image(
                              image: FileImage(File(foto.fileLocal!)),
                              height: 180,
                            )),
                      ),
                      Positioned(
                          right: -2,
                          top: -9,
                          child: IconButton(
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.black.withOpacity(0.5),
                              size: 50,
                            ),
                            onPressed: notNew
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
            onPressed: notNew
                ? null
                : () async {
                    UslugaSelect? result = await Navigator.push(
                      context,
                      // Create the SelectionScreen in the next step.
                      MaterialPageRoute(
                          builder: (context) =>
                              UslugaSelectScreen(avto: avto, zayavka: zayavka)),
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
                child: Column(children: [
                  Row(
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
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                          onPressed: notNew
                              ? null
                              : () {
                                  usluga.kolichestvo = usluga.kolichestvo + 1;
                                  usluga.saveLocal();
                                  avto.saveLocal();
                                  zayavka.saveLocal();
                                },
                          child: Text("+")),
                      Text(usluga.kolichestvo.toString()),
                      Icon(Icons.timer_outlined),
                      ElevatedButton(
                          onPressed: notNew
                              ? null
                              : () {
                                  usluga.kolichestvo = usluga.kolichestvo - 1;
                                  usluga.saveLocal();
                                  avto.saveLocal();
                                  zayavka.saveLocal();
                                },
                          child: Text("-"))
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                          onPressed: notNew
                              ? null
                              : () {
                                  usluga.sverh = usluga.sverh + 1;
                                  usluga.saveLocal();
                                  avto.saveLocal();
                                  zayavka.saveLocal();
                                },
                          child: Text("+")),
                      Text(usluga.sverh.toString()),
                      Icon(Icons.timer),
                      ElevatedButton(
                          onPressed: notNew
                              ? null
                              : () {
                                  usluga.sverh = usluga.sverh - 1;
                                  usluga.saveLocal();
                                  avto.saveLocal();
                                  zayavka.saveLocal();
                                },
                          child: Text("-")),
                    ],
                  ),
                ]),
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
            onPressed: notNew
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
              onPressed: notNew
                  ? null
                  : () {
                      addOborudovanieFotos(zayavka, avto, context);
                    },
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(
                    Colors.blue.shade100), // Change button color
              ),
              child: const Icon(Icons.add_a_photo),
              onPressed: notNew
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
            onPressed: notNew
                ? null
                : () {
                    if (_speechToText.value.isNotListening) {
                      _speechToText.value.listen(
                        onResult: (result) {
                          avto.comment = result.recognizedWords;
                          avto.saveLocal();
                          zayavka.saveLocal();

                          //infoToast("речь сохранена");
                        },
                      );
                    } else {
                      _speechToText.value.stop();
                    }
                  },
            child: Icon(
                _speechToText.value.isNotListening ? Icons.mic_off : Icons.mic),
          ),
          ElevatedButton(
              onPressed: notNew
                  ? null
                  : () {
                      if (commentController.text.length > 199)
                        commentController.text =
                            commentController.text.substring(0, 199);
                      avto.comment = commentController.text;
                      avto.saveLocal();
                      zayavka.saveLocal();
                      infoToast("комментарий сохранен");
                    },
              child: Text("сохранить комментарий")),
          Text(
            'Соисполнители:',
            style: TextStyle(fontSize: 20),
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(
                  Colors.blue.shade100), // Change button color
            ),
            child: const Icon(Icons.supervised_user_circle_outlined),
            onPressed: notNew
                ? null
                : () async {
                    UserSelect? result = await Navigator.push(
                      context,
                      // Create the SelectionScreen in the next step.
                      MaterialPageRoute(
                          builder: (context) =>
                              UserSelectScreen(avto: avto, zayavka: zayavka)),
                    );
                    zayavka.saveLocal();
                  },
          ),
          for (User usluga in avto.users.toList())
            Container(
              padding: EdgeInsets.all(0),
              child: Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blue.shade200,
                ),
                child: Column(children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          style: TextStyle(fontSize: 17),
                          '${usluga.username}',
                        ),
                      ),
                    ],
                  ),
                 
                ]),
              ),
            ),
          ElevatedButton(
              onPressed: notNew
                  ? null
                  : () async {
                      showSendAvtoDialog(context);
                    },
              child: const Text("готово")),
        ]);
  }

  Future<dynamic> showSendAvtoDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          child: 
          Container(
            padding: EdgeInsets.all(10),
            child: 
          ListView(
            shrinkWrap: true,
            children: [
              Text('Уверены что хотите отправить отчет?'),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (await checkConnection()) {
                    infoToast("Отправляем");
                    sendAvtoOtchet();
                    //ref.avtomobilRemotes.save(avto);
                    Navigator.pop(context);
                  }
                },
                child: Text('Отправить'),
              ),
            ],
          ),
          ),
        );
      },
    );
  }

  bool get notNew => avto.status != "NOVAYA";

  Future<void> sendAvtoOtchet() async {
    avto.status = 'TEMP';
    avto.saveLocal();
    zayavka.saveLocal();
    bool r = false;
    try {
      r = await sendAvto(avto, token.value);
    } catch (e) {
      infoToast("Ошибка при отправке\n" + e.toString());
      /*
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
*/
      //final prefs = await SharedPreferences.getInstance();

      //prefs.setString(avto.id!, "Eee");
      /*
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

      */
    }

    if (r) {
      avto.status = "VYPOLNENA";
      avto.saveLocal();
      zayavka.saveLocal();
      infoToast("отправлено на проверку");
    } else {
      infoToast("Не удалось отправить, попробуйте еще");
      avto.status = "NOVAYA";
      avto.saveLocal();
      zayavka.saveLocal();
    }
  }

  addOborudovanieFotos(
      ZayavkaRemote zayavka, AvtomobilRemote avto, context) async {
    final ImagePicker _picker = ImagePicker();

    var pickedFiles =
        //await AssetPicker.pickAssets(
        //context,
        //pickerConfig: const AssetPickerConfig(maxAssets:60, ),
//);
        await _picker.pickMultiImage(imageQuality: 30, maxHeight: 2000);

    if (!pickedFiles.isEmpty) {
      for (var pickedFile in pickedFiles) {
        var fi = await pickedFile;

        OborudovanieFoto f = OborudovanieFoto(
            id: Uuid().v4(),
            fileLocal: fi.path,
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
    if (pickedFile != null) Gal.putImage(pickedFile.path);

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
      return Dialog(
        child: 
        Container(
          padding: EdgeInsets.all(10),
          child: 
        ListView(
          shrinkWrap: true,
          children: [
            Text('Уверены что хотите удалить авто?'),
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
        ),
        )
      );
    },
  );
}

void addOborudovanieFotos(ZayavkaRemote zayavka, AvtomobilRemote avto) {}
addFoto(ZayavkaRemote zayavka, AvtomobilRemote avto) async {
  final ImagePicker _picker = ImagePicker();

  var pickedFile = await _picker.pickImage(
      source: ImageSource.camera, imageQuality: 30, maxHeight: 2000);
  if (pickedFile != null) Gal.putImage(pickedFile.path);

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

addFotos(ZayavkaRemote zayavka, AvtomobilRemote avto, context) async {
  final ImagePicker _picker = ImagePicker();

  var pickedFiles =
      //await AssetPicker.pickAssets(
      //context,
      // pickerConfig: const AssetPickerConfig(maxAssets:60, ),
//);
      await _picker.pickMultiImage(imageQuality: 30, maxHeight: 2000);

  if (!pickedFiles.isEmpty) {
    for (var pickedFile in pickedFiles) {
      var fi = await pickedFile;
      Foto f =
          Foto(fileLocal: fi.path, avtomobil: BelongsTo<AvtomobilRemote>(avto));
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
