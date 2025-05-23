import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttsec/image_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';
import 'package:multiple_image_camera/camera_file.dart';
import 'package:multiple_image_camera/multiple_image_camera.dart';
import 'package:fluttsec/main.dart';
import 'package:fluttsec/src/models/avtoFoto.dart';
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
import 'package:path_provider/path_provider.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:uuid/uuid.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class AvtoWidget extends HookConsumerWidget {
  AvtomobilRemote avto;
  Position? position;
  

  ZayavkaRemote zayavka;

  AvtoWidget(AvtomobilRemote this.avto, ZayavkaRemote this.zayavka,
      {super.key});
  void _saveComment(String text) {}
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var commentController = TextEditingController(text: avto.comment);

    var _speechToText = useState(SpeechToText());
     ValueNotifier<ExpansionTileController> controller  = useState(ExpansionTileController());
     var resend = useState(false);
    useEffect(
      () {
        _speechToText.value.initialize();

        return null;
      },
    );

    return ExpansionTile(
      controller: controller.value,
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
                child: ClipRRect(
    borderRadius: BorderRadius.circular(8.0),
    child: Image(
                  image: FileImage(
                    File(image.fileLocal!),
                  ),
                  height: 70,
                ))),
                SizedBox(width: 15,),
          Expanded(
            flex: 2,
            child: Text(
                '${avto.nomer}\n${avto.marka}${(avto.nomerAG == null || avto.nomerAG == "null" || avto.nomerAG == "") ? '' : '\nАГ:' + avto.nomerAG!}'),
          ),
          if (notNew && avto.status != AvtomobilRemote.VYPOLNENA)
          ValueListenableBuilder(
              valueListenable: resend,
              builder: (context, value, child) {
                return ElevatedButton(
                
                onPressed:!value?null: () => {
                  resend.value = false,
                  resendFromServer(avto.id)},
                child: const Icon(Icons.refresh,));
              },
            ),
            
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
          if (avto.nomerAG==null) ElevatedButton(
            style: ButtonStyle(
             // backgroundColor: WidgetStateProperty.all<Color>(
             //     Colors.blue.shade100), // Change button color
            ),
            child: const Icon(Icons.add_a_photo),
            onPressed: notNew
                ? null
                : () {
                    addAvtoFoto(zayavka, avto);
                  },
          )else Text("") ,
          Text(
            'Oтчет:',
            style: TextStyle(fontSize: 20),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              style: ButtonStyle(
           
              ),
              child: const Icon(Icons.attach_file_rounded),
              onPressed: notNew
                  ? null
                  : () {
                      addFotos(zayavka, avto, context);
                    },
            ),
            SizedBox(width: 5,),
            ElevatedButton(
              style: ButtonStyle(
           
              ),
              child: const Icon(Icons.add_a_photo),
              onPressed: notNew
                  ? null
                  : () {
                      addFoto(zayavka, avto, context);
                    },
            ),
            SizedBox(width: 5,),
            ElevatedButton(
              style: ButtonStyle(
              ),
              child: const Icon(Icons.file_download),
              onPressed: notNew
                  ? null
                  : () {
                      addFiles(zayavka, avto, context);
                    },
            ),
          ]),
          if (!avto.fotos.isEmpty)
            CarouselSlider(
                options: CarouselOptions(autoPlay: true, height: 150.0),
                items: [
                  for (Foto foto in avto.fotos.toList())
                    carouselItem(foto.fileLocal, context, () {
                      foto.deleteLocal();
                      avto.saveLocal();
                      zayavka.saveLocal();
                    }, notNew)
                ]),
          Text(
            'Услуги:',
            style: TextStyle(fontSize: 20),
          ),
          ElevatedButton(
            style: ButtonStyle(
              //backgroundColor: WidgetStateProperty.all<Color>(
              //    Colors.blue.shade100), // Change button color
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
               
                child:Column(children: [
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
                                        usluga.kolichestvo =
                                            usluga.kolichestvo + 1;
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
                                        usluga.kolichestvo =
                                            usluga.kolichestvo - 1;
                                        usluga.saveLocal();
                                        avto.saveLocal();
                                        zayavka.saveLocal();
                                      },
                                child: Text("-"))
                          ],
                        ),
                         (company.value == "avtokonnekt")
                    ? Row(
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
                                Text("Сверхурочные")
                          ],
                        ):Row(),
                      ])
                    
              ),
            ),
          Text(
            'Оборудование:',
            style: TextStyle(fontSize: 20),
          ),
          ElevatedButton(
            style: ButtonStyle(
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
          
              ),
              child: const Icon(Icons.attach_file),
              onPressed: notNew
                  ? null
                  : () {
                      addOborudovanieFotos(zayavka, avto, context);
                    },
            ),
            SizedBox(width: 5,),
            ElevatedButton(
              style: ButtonStyle(
           
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
                carouselItem(foto.fileLocal, context, () {
                  foto.deleteLocal();
                  avto.saveLocal();
                  zayavka.saveLocal();
                }, notNew)
            ]),
          TextFormField(
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 10,
            
            controller: commentController,
            decoration: InputDecoration(hintText: 'нажмите один раз для записи'),
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
          for (User u in avto.users.toList())
            Container(
              padding: EdgeInsets.all(0),
              child: Container(
                margin: EdgeInsets.all(10),
               
                child: Column(children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          style: TextStyle(fontSize: 17),
                          '${u.lastName} ${u.firstName}',
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
                      //initPosition(avto);
                      Position? p = await Geolocator.getLastKnownPosition();
                      if(p!=null){
                        avto.lat = p.latitude.toString();
                        avto.lng = p.longitude.toString();
                        avto.saveLocal();
                        
                      }
                      showSendAvtoDialog(context, controller, commentController, resend);
                    },
              child: const Text("готово")),
        ]);
  }

  Future<dynamic> showSendAvtoDialog(BuildContext context, controller, TextEditingController commentController, var resend) {
    return showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(10),
            child: ListView(
              shrinkWrap: true,
              children: [
                Text('Уверены что хотите отправить отчет?'),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed:  () async {
                    if (await checkConnection()) {
                      infoToast("Отправляем");
                      avto.comment = commentController.text;
                      avto.saveLocal();
                      sendAvtoOtchet(context, controller);
                      Timer(
        Duration(seconds: 60),
            () => resend.value = true);
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

  addFiles(ZayavkaRemote zayavka, AvtomobilRemote avto, context) async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result == null) return;
    List<File> files = result.paths.map((path) => File(path!)).toList();

    if (!files.isEmpty) {
      for (var pickedFile in files) {
        var fi = await pickedFile;
        Foto f = Foto(
            fileLocal: fi.path, avtomobil: BelongsTo<AvtomobilRemote>(avto));
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

  bool get notNew => avto.status != "NOVAYA";

  Future<void> sendAvtoOtchet(BuildContext context, ValueNotifier<ExpansionTileController> controller) async {
    avto.status = 'TEMP';
    avto.saveLocal();
    zayavka.saveLocal();
    String? r = null;
    try {
      r = await sendAvto(avto);
    } catch (e) {
      infoToast("Ошибка при отправке\n" + e.toString());

    }
    avto.status = r;
    avto.saveLocal();
      zayavka.saveLocal();
      controller.value.collapse();
 if (r==AvtomobilRemote.VYPOLNENA) {
      //
 }else
    if (r==AvtomobilRemote.POSLANA_V_BIPIUM) {
      infoToast("отправляется в бипиум на проверку");
      
      
    } else {
      infoToast("Не удалось отправить, попробуйте еще");
      avto.status = "NOVAYA";
      avto.saveLocal();
      zayavka.saveLocal();
    }
  }

  addAvtoFoto(ZayavkaRemote zayavka, AvtomobilRemote avto) async {
    final ImagePicker _picker = ImagePicker();

    var pickedFile = await _picker.pickImage(
        source: ImageSource.camera, imageQuality: 30, maxHeight: 2000);
    if (pickedFile != null) Gal.putImage(pickedFile.path);

    if (pickedFile != null) {
      AvtoFoto f = AvtoFoto(
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

  addOborudovanieFotos(
      ZayavkaRemote zayavka, AvtomobilRemote avto, context) async {
    var pickedFiles =
        //await AssetPicker.pickAssets(
        //context,
        //pickerConfig: const AssetPickerConfig(maxAssets:60, ),
//);
        await pickMulti(context);

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
  
  resendFromServer(String? id) async {
    var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };

  headers.addAll({'Authorization': 'Bearer ${token.value}'});
  

  var data = json.encode({
      "id": id
  });
  var dio = Dio();
  var response = await dio.request(
    '${site}rest/services/flutterService/resendAvto',
    options: Options(
      method: 'POST',
      headers: headers,
    ),
    data: data,
  );

  if (response.statusCode == 200) {
    print(json.encode(response.data));
    
    return response.data;
  } 
  return response.statusCode.toString();
  }
}


void showDeleteAlertAvto(context, ZayavkaRemote zayavka, AvtomobilRemote avto) {
  showDialog(
    context: context,
    builder: (_) {
      return Dialog(
          child: Container(
        padding: EdgeInsets.all(10),
        child: ListView(
          shrinkWrap: true,
          children: [
            Text('Уверены что хотите удалить отчет?'),
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
      ));
    },
  );
}

initPosition(AvtomobilRemote avto) {
  if (avto.nachaloRabot == null) {
    avto.nachaloRabot = DateTime.now();
  }
  
    _determinePosition().then(
      (value) {
        Position p = value;
        avto.lat = p.latitude.toString();
        avto.lng = p.longitude.toString();
      },
    );
}

Future<List<XFile>> pickMultiC(context) async {
  var files = await MultipleImageCamera.capture(
    context: context,
    customDoneButton: Center( child: ElevatedButton(style: ButtonStyle(
      
        // backgroundColor: WidgetStateProperty<Color>.fromMap(
        //  <WidgetStatesConstraint, Color>{
        //    WidgetState.focused: Colors.blueAccent,
        //    WidgetState.pressed | WidgetState.hovered: Colors.blue,
        //    WidgetState.any: Colors.white,
        //  },
        //),
        ), onPressed: null, child: Text("Готово",style: TextStyle(fontSize: 40))))
  );

  List<XFile> r = [];
  for (MediaModel f in files) {
    File? fa = await f.file;
    var paf = fa.path;

    final lastIndex = paf.lastIndexOf(RegExp(r'/'));
    final end = paf.substring(lastIndex + 1, paf.length);

    var dir = await getTemporaryDirectory();
    var targetPath = dir.absolute.path + "/temp" + Uuid().v4() + end;

    XFile? result = await FlutterImageCompress.compressAndGetFile(
      paf,
      targetPath,
      minWidth: 2300,
      minHeight: 1500,
      quality: 30,
    );
    if (result != null) r.add(result);
  }
  return r;
}

Future<List<Asset>> pickMultiCamera() async {
  List<Asset> resultList = await MultiImagePicker.pickImages(
    iosOptions: IOSOptions(
      doneButton: UIBarButtonItem(title: 'Подтвердить'),
      cancelButton: UIBarButtonItem(title: 'Отмена'),
    ),
    androidOptions: AndroidOptions(
      actionBarTitle: "Выбрать фото",
      allViewTitle: "Все фото",
      useDetailsView: false,
      hasCameraInPickerPage: true,
    ),
  );
  return resultList;
}

addFoto(ZayavkaRemote zayavka, AvtomobilRemote avto, context) async {
  //initPosition(avto);

  // final ImagePicker _picker = ImagePicker();

  List<XFile> pickedFiles = await pickMultiC(context);
  //await _picker.pickImage(
  // source: ImageSource.camera, imageQuality: 30, maxHeight: 2000);
  //if (pickedFile != null) Gal.putImage(pickedFile.path);
  for (var pickedFile in pickedFiles) {
    Gal.putImage(pickedFile.path);
    Foto f = Foto(
        fileLocal: pickedFile.path,
        avtomobil: BelongsTo<AvtomobilRemote>(avto));

    f.saveLocal();

    avto.saveLocal();
    zayavka.saveLocal();
  }
}

addFotos(ZayavkaRemote zayavka, AvtomobilRemote avto, context) async {
  //initPosition(avto);
  //final ImagePicker _picker = ImagePicker();

  var pickedFiles =
      //await AssetPicker.pickAssets(
      //context,
      // pikerConfig: const AssetPickerConfig(maxAssets:60, ),
//);
      await pickMulti(context);

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

Future<List<XFile>> pickMulti(context) async {
  //final ImagePicker _picker = ImagePicker();
  //List<XFile> images =   await _picker.pickMultiImage(imageQuality: 30,maxHeight: 1500, maxWidth: 2000);
  //return images;

  List<AssetEntity>? pickedFiles = await AssetPicker.pickAssets(
    context,
    pickerConfig: const AssetPickerConfig(
      maxAssets: 60,
    ),
  );

  List<XFile> r = [];
  for (AssetEntity f in pickedFiles!) {
    File? fa = await f.file;
    var paf = fa!.path;

    final lastIndex = paf.lastIndexOf(RegExp(r'/'));
    final end = paf.substring(lastIndex + 1, paf.length);

    var dir = await getTemporaryDirectory();
    var targetPath = dir.absolute.path + "/temp" + Uuid().v4() + end;

    XFile? result = await FlutterImageCompress.compressAndGetFile(
      paf,
      targetPath,
      minWidth: 2300,
      minHeight: 1500,
      quality: 30,
    );
    if (result != null) r.add(result);
  }

  return r;
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      Geolocator.openLocationSettings();
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

Stack carouselItem(file, BuildContext context, delete, notNew) {
  return Stack(children: <Widget>[
    ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: filePicture(file!, context),
    ),
    Positioned(
        right: -2,
        top: -9,
        child: IconButton(
          icon: Icon(
            Icons.cancel,
           // color: Colors.black.withOpacity(0.5),
            size: 50,
          ),
          onPressed: notNew ? null : delete,
        ))
  ]);
}

GestureDetector filePicture(String file, BuildContext context) {
  return file.endsWith(".jpg") ||
          file.endsWith(".jpeg") ||
          file.endsWith(".png")
      ? GestureDetector(
          onTap: () {
            Navigator.push<Widget>(
              context,
              MaterialPageRoute(
                builder: (context) => ImageScreen(file),
              ),
            );
          },
          child: Image(
            image: FileImage(File(file)),
            height: 180,
          ))
      : GestureDetector(
          onTap: () {
          },
          child: Image(
            image: AssetImage("assets/images/file.png"),
            height: 180,
          ));
}
