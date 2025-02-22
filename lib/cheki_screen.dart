import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:fluttsec/avto_widget.dart';
import 'package:fluttsec/main.dart';
import 'package:fluttsec/main.data.dart';
import 'package:fluttsec/src/remote/save_chek_with_photos.dart';
import 'package:fluttsec/src/models/chek.dart';
import 'package:fluttsec/src/models/chekFoto.dart';
import 'package:gal/gal.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:uuid/uuid.dart';

class ChekiScreen extends HookConsumerWidget {
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
                child:  TextFormField(
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
                Chek a = Chek(
                    id:Uuid().v4(),
                    comment: nomer,
                    username: user.value,
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
          Expanded(
            flex: 2,
            child: Text(
                '${DateFormat('yyyy.MM.dd kk:mm').format(chek.date!)}'),
          ),
          ElevatedButton(
              onPressed: chek.status != "NOVAYA"
                  ? null
                  : () => showDeleteAlertAvto(context, chek), //showDeleteAlertAvto(context, ayavka, avto),
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
                      addChekLocalFiles(chek, context);
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
                      addChekFoto(chek);
                    },
            ),
              ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(
                    Colors.blue.shade100), // Change button color
              ),
              child: const Icon(Icons.file_download),
              onPressed: chek.status != "NOVAYA"
                  ? null
                  : () {
                    addFiles(chek, context);
                    },
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
                     chek.qr = res;
                    }
                  },
          ),
          ]),
          (chek.qr!=null)?
          Text(chek.qr!):Text(""),
          if (!chek.fotos.isEmpty)
            CarouselSlider(
                options: CarouselOptions(autoPlay: true, height: 150.0),
                items: [
                  for (ChekFoto foto in chek.fotos.toList())
                    carouselItem(foto.fileLocal, context,  () {
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
                                Text('Уверены что хотите отправить чек?'),
                                 ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Отмена'),
                              ),
                              ElevatedButton(
                                onPressed: chek.status!="NOVAYA"?null:() async {
                                  if(await checkConnection()){
                                    Navigator.pop(context);
                                      infoToast("Посылаем");
                                      
                                      chek.status = "TEMP";
                                      
                                      chek.saveLocal();
                                      bool ok = false;
                                      try{
                                        ok = 
                                      await saveChekWithPhotos(
                                          chek, ref, token.value);
                                      }catch(e){
                                            
                                           
                                      }
                                      if (ok) {
                                        chek.status = "GOTOWAYA";
                                        chek.saveLocal();
                                        infoToast("Готово");
                                        
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
   addChekFoto(Chek chek) async {
    final ImagePicker _picker = ImagePicker();

    var pickedFile = await _picker.pickImage(
        source: ImageSource.camera, imageQuality: 30, maxHeight: 2000);
    if (pickedFile != null) Gal.putImage(pickedFile.path);

    if (pickedFile != null) {
      ChekFoto f = ChekFoto(
          fileLocal: pickedFile.path,
          chek: BelongsTo<Chek>(chek));
      f.saveLocal();
      chek.saveLocal();
     
    } else {
      final snackBar = SnackBar(
        content: const Text('фото не добавлено'),
      );
    }
  }
  addChekLocalFiles(Chek chek, context) async {
   var files = await pickMulti(context);
  //var result = await FilePicker.platform.pickFiles(allowMultiple: true);

  if (!files.isEmpty) {
    //List<String?> files = result.paths.map((path) => path!).toList();
    for (var file in files) {
      var fl = await file;
      ChekFoto f = ChekFoto(fileLocal: fl.path, chek: BelongsTo(chek));
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
      return Dialog(
       child: ListView(
          shrinkWrap: true,
          children: [Text('Уверены что хотите удалить чек?'),
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

  void addFiles(Chek chek, BuildContext context) async{

    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);

if (result == null) 
return;
  List<File> files = result.paths.map((path) => File(path!)).toList();


 if (!files.isEmpty) {
    for (var pickedFile in files) {
      var fi = await pickedFile;
      ChekFoto f =
          ChekFoto(fileLocal: fi.path, chek: BelongsTo<Chek>(chek));
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
