import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:fluttsec/main.dart';
import 'package:fluttsec/main.data.dart';
import 'package:fluttsec/src/remote/save_chek_with_photos.dart';
import 'package:fluttsec/src/models/chek.dart';
import 'package:fluttsec/src/models/chekFoto.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

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
                    username: user.value,
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
               Align(
  alignment: Alignment.topRight,
  child: IconButton(onPressed: () => context.go('/settings'), icon: Icon(Icons.settings)),
                 
),
ElevatedButton(onPressed: () => showChekDialog(context, ref), child: Text("Добавить отчет"))

,
for (var chek in chekState.model.toList(growable: true))
             ExpansionTile(
        trailing: SizedBox.shrink(),
        collapsedShape: const ContinuousRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        title: Row(children: [
          Expanded(
            flex: 2,
            child: Text(
                '${chek.comment}'),
          ),
          ElevatedButton(
              onPressed: chek.status != "NOVAYA"
                  ? null
                  : () => showDeleteAlertAvto(context, chek), //showDeleteAlertAvto(context, zayavka, avto),
              child: const Icon(Icons.cancel)),
        ]),
        collapsedBackgroundColor: chek.status != "NOVAYA"
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
              onPressed: chek.status != "NOVAYA"
                  ? null
                  : () {
                      addChekLocalFiles(chek);
                    },
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(
                    Colors.blue.shade100), // Change button color
              ),
              child: const Icon(Icons.add_a_photo),
              onPressed: chek.status != "NOVAYA"
                  ? null
                  : () {
                      addChekLocalFiles(chek);
                    },
            ),
          ]),
          if (!chek.fotos.isEmpty)
            CarouselSlider(
                options: CarouselOptions(autoPlay: true, height: 150.0),
                items: [
                  for (ChekFoto foto in chek.fotos.toList())
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
                            onPressed: chek.status != "NOVAYA"
                                ? null
                                : () {
                                    foto.deleteLocal();
                                    chek.saveLocal();
                                   
                                  },
                          ))
                    ])
                ]),
          
         
          
          ElevatedButton(
              onPressed: chek.status != "NOVAYA"
                  ? null
                  : () async {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: Text('Отправка чека'),
                            content: ListView(
                              shrinkWrap: true,
                              children: [
                                Text('Уверены что хотите отправить чек?')
                              ],
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Отмена'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  if(await checkConnection()){
                                      infoToast("Посылаем");
                                      
                                      chek.status = "TEMP";
                                      chek.saveLocal();
                                      bool ok = false;
                                      try{
                                        ok = 
                                      await saveChekWithPhotos(
                                          chek, ref, token.value);
                                      }catch(e){
                                            infoToast("Ошибка при отправке\n"+e.toString());
                                      }
                                      if (ok) {
                                        chek.status = "GOTOWAYA";
                                        chek.saveLocal();
                                        infoToast("Готово");
                                        context.pop();
                                      }else{
                                        infoToast("Не удалось отправить");
                                        chek.status = "NOVAYA";
                                      }
                                  }
                                },
                                child: Text('Отправить'),
                              ),
                            ],
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

void showDeleteAlertAvto(context, Chek avto) {
  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: Text('Удаление чека'),
        content: ListView(
          shrinkWrap: true,
          children: [Text('Уверены что хотите удалить чек?')],
        ),
        actions: [
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
      );
    },
  );
}
}
