import 'dart:convert';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:fluttsec/avto_widget.dart';
import 'package:fluttsec/main.dart';
import 'package:fluttsec/main.data.dart';
import 'package:fluttsec/src/models/pFoto.dart';
import 'package:fluttsec/src/models/pOborudovanie.dart';
import 'package:fluttsec/src/models/peremeshenieOborudovaniya.dart';
import 'package:fluttsec/src/remote/login.dart';
import 'package:fluttsec/src/remote/save_with_photos.dart';
import 'package:gal/gal.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:uuid/uuid.dart';

class OborudovanieScreen extends HookConsumerWidget {
  void showChekDialog(context, ref) {
    showDialog(
      context: context,
      builder: (_) {
        var nomerController = TextEditingController();
        return Dialog(
          child: ListView(
            shrinkWrap: true,
            children: [
               Container(padding: EdgeInsets.all(10),
                child: TextFormField(
                controller: nomerController,
                decoration: InputDecoration(hintText: 'комментарий'),
              )),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Send them to your email maybe?
                  var nomer = nomerController.text;
                  PeremesheniyeOborudovaniya a = PeremesheniyeOborudovaniya(
                      id: Uuid().v4(),
                      comment: nomer,
                      status: "NOVAYA",
                      date: DateTime.now());
                  a.saveLocal();
                  Navigator.pop(context);
                },
                child: Text('Сохранить'),
              ),
            ],
          ),
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
          var chekState =
              ref.peremesheniyeOborudovaniyas.watchAll(remote: false);
          var sorted = chekState.model.toList(growable: true);
          sorted.sort((a, b) {
            if(a.date==null)
              return 1;
            if(b.date==null)
              return 1;
            return b.date!.compareTo(a.date!);
          },);

          return ListView(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                    onPressed: () => context.go('/settings'),
                    icon: Icon(Icons.settings)),
              ),
              ElevatedButton(
                  onPressed: () => showChekDialog(context, ref),
                  child: Text("Добавить перемещение")),
              for (var chek in sorted)
                ExpansionTile(
                    trailing: SizedBox.shrink(),
                    collapsedShape: const ContinuousRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    title: Row(children: [
                      Expanded(
                        flex: 2,
                        child: Text('${chek.comment}'),
                      ),
                       Expanded(
                        flex: 2,
                        child: Text('${DateFormat('dd.MM.yyyy kk:mm').format(chek.date!)}'),
                      ),
                      ElevatedButton(
                          onPressed: chek.status != "NOVAYA"
                              ? null
                              : () => showDeleteAlertAvto(context, chek),
                          child: const Icon(Icons.cancel)),
                    ]),
                    collapsedBackgroundColor: chek.status != "NOVAYA"
                        ? Colors.grey.shade200
                        : Color.fromARGB(255, 247, 130, 139),
                    children: <Widget>[
                      const SizedBox(width: 8),
                      const SizedBox(width: 8),
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
                        onPressed: chek.status != "NOVAYA"
                            ? null
                            : () async {
                                var res = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SimpleBarcodeScannerPage(),
                                    ));
                                if (res is String && res != '-1') {
                                  POborudovanie o = POborudovanie(
                                      peremeshenie:
                                          BelongsTo<PeremesheniyeOborudovaniya>(
                                              chek),
                                      code: res);

                                  o.saveLocal();
                                  chek.saveLocal();
                                }
                              },
                      ),
                      for (POborudovanie oborudovanie in chek.barcode.toList())
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
                                    onPressed: chek.status != "NOVAYA"
                                        ? null
                                        : () {
                                            oborudovanie.deleteLocal();
                                            chek.saveLocal();
                                          },
                                    child: Icon(Icons.cancel))
                              ],
                            ),
                          ),
                        ),
                      Text(
                        'Фотоотчет:',
                        style: TextStyle(fontSize: 20),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all<Color>(
                                    Colors
                                        .blue.shade100), // Change button color
                              ),
                              child: const Icon(Icons.attach_file_rounded),
                              onPressed: chek.status != "NOVAYA"
                                  ? null
                                  : () {
                                      addChekLocalFiles(chek);
                                    },
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all<Color>(
                                    Colors
                                        .blue.shade100), // Change button color
                              ),
                              child: const Icon(Icons.add_a_photo),
                              onPressed: chek.status != "NOVAYA"
                                  ? null
                                  : () {
                                      addChekFoto(chek);
                                    },
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all<Color>(
                                    Colors
                                        .blue.shade100), // Change button color
                              ),
                              child: const Icon(Icons.file_download),
                              onPressed: chek.status != "NOVAYA"
                                  ? null
                                  : () {
                                      addFiles(chek, context);
                                    },
                            ),
                          ]),
                      if (!chek.fotos.isEmpty)
                        CarouselSlider(
                            options:
                                CarouselOptions(autoPlay: true, height: 150.0),
                            items: [
                              for (PFoto foto in chek.fotos.toList())
                                carouselItem(foto.fileLocal, context, () {
                                  foto.deleteLocal();
                                  chek.saveLocal();
                                }, chek.status != "NOVAYA")
                            ]),
                      ElevatedButton(
                          onPressed: chek.status != "NOVAYA"
                              ? null
                              : () async {
                                  showDialog(
                                    context: context,
                                    builder: (_) {
                                      return Dialog(
                                        child: ListView(
                                          shrinkWrap: true,
                                          children: [
                                            Text(
                                                'Уверены что хотите отправить отчет?'),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text('Отмена'),
                                            ),
                                            ElevatedButton(
                                              onPressed: chek.status != "NOVAYA"
                                                  ? null
                                                  : () async {
                                                      Navigator.pop(context);
                                                      if (await checkConnection()) {
                                                        infoToast("Посылаем");
                                                        //chek.saveLocal();
                                                        //chek.status = "TEMP";
                                                        bool ok = false;
                                                        try {
                                                          ok =
                                                              await saveOborudovanie(
                                                                  chek,
                                                                  ref,
                                                                  token.value);
                                                        } catch (e) {
                                                        
                                                         
                                                        }
                                                        if (ok) {
                                                          chek.status =
                                                              "GOTOWAYA";
                                                          chek.saveLocal();
                                                          infoToast("Готово");
                                                        } else {
                                                          infoToast(
                                                              "Не удалось послать");
                                                          chek.status =
                                                              "NOVAYA";
                                                          chek.saveLocal();
                                                        }
                                                      }
                                                    },
                                              child: Text('Отправить'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                          child: const Text("готово")),
                    ]),
            ],
          );
        });
  }

  Future<bool> saveOborudovanie(
      PeremesheniyeOborudovaniya chek, WidgetRef ref, mytoken) async {
        bool ok = await login(getFullUsername, password.value);

    for (PFoto foto in chek.fotos.toList()) {
      bool ok = await login(getFullUsername, password.value);
      var headers = {
        'Content-Type': 'image/jpeg',
        'Authorization': 'Bearer $mytoken'
      };
      var data = File(foto.fileLocal!).readAsBytesSync();

      var dio = Dio();
      var n = foto.fileLocal!.lastIndexOf("/");
      var name = foto.fileLocal!.substring(n + 1);
      var response = await dio.request(
        '${site}rest/files?name=' + name,
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

  void addFiles(PeremesheniyeOborudovaniya chek, BuildContext context) async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result == null) return;
    List<File> files = result.paths.map((path) => File(path!)).toList();

    if (!files.isEmpty) {
      for (var pickedFile in files) {
        var fi = await pickedFile;
        PFoto f = PFoto(
            fileLocal: fi.path,
            peremeshenie: BelongsTo<PeremesheniyeOborudovaniya>(chek));
        f.saveLocal();
      }
      chek.saveLocal();
    } else {
      final snackBar = SnackBar(
        content: const Text('файлы не добавлены'),
      );
    }
  }
}

Future<bool> saveChek(PeremesheniyeOborudovaniya a, mytoken) async {
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };

  headers.addAll({'Authorization': 'Bearer $mytoken'});

  var date = DateTime.now().toIso8601String();
  var fotos = [];
  for (PFoto f in a.fotos.toList()) {
    if (f.file != null) fotos.add({"file": f.file});
  }
  var ob = [];
  for (POborudovanie f in a.barcode.toList()) {
    ob.add({"code": f.code});
  }

  var data = json.encode({
    "peremeshenie": {
      "date": "$date",
      "fotos": fotos,
      "barcode": ob,
      "comment": a.comment,
      "username": company.value + "|" + user.value,
      "tenantAttribute": company.value
    }
  });
  var dio = Dio();
  var response = await dio.request(
    '${site}rest/services/flutterService/savePeremeshenie',
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

addChekFoto(PeremesheniyeOborudovaniya chek) async {
  final ImagePicker _picker = ImagePicker();

  var pickedFile = await _picker.pickImage(
      source: ImageSource.camera, imageQuality: 30, maxHeight: 2000);
  if (pickedFile != null) Gal.putImage(pickedFile.path);

  if (pickedFile != null) {
    PFoto f = PFoto(
        fileLocal: pickedFile.path,
        peremeshenie: BelongsTo<PeremesheniyeOborudovaniya>(chek));
    f.saveLocal();
    chek.saveLocal();
  } else {
    final snackBar = SnackBar(
      content: const Text('фото не добавлено'),
    );
  }
}

addChekLocalFiles(PeremesheniyeOborudovaniya chek) async {
  var result = await FilePicker.platform.pickFiles(allowMultiple: true);

  if (result != null) {
    List<String?> files = result.paths.map((path) => path!).toList();
    for (var file in files) {
      PFoto f = PFoto(fileLocal: file, peremeshenie: BelongsTo(chek));

      f.saveLocal();
      chek.saveLocal();
    }
    chek.saveLocal();
  } else {
    final snackBar = SnackBar(
      content: const Text('файлы не добавлены'),
    );
  }
}

void showDeleteAlertAvto(context, PeremesheniyeOborudovaniya avto) {
  showDialog(
    context: context,
    builder: (_) {
      return Dialog(
        child: ListView(
          shrinkWrap: true,
          children: [
            Text('Уверены что хотите удалить перемещение?'),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                avto.deleteLocal();

                Navigator.pop(context);
              },
              child: Text('Удалить'),
            ),
          ],
        ),
      );
    },
  );
}
