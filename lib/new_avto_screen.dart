import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:fluttsec/src/models/avtoFoto.dart';
import 'package:fluttsec/src/models/avtomobilRemote.dart';
import 'package:fluttsec/src/models/zayavkaRemote.dart';
import 'package:fluttsec/tasks_screen.dart';
import 'package:gal/gal.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class NewAvtoScreen extends HookConsumerWidget {
  final ZayavkaRemote zayavka;
  NewAvtoScreen(this.zayavka);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var nomerController;
    var markaController;
    return Scaffold(
        appBar: AppBar(
          title: Text('Новое авто'),
        ),
        body: ListView(
            shrinkWrap: true,
            children: [
              TextFormField(
                inputFormatters: [
                  UpperCaseTextFormatter(),
                ],
                controller: nomerController,
                decoration: InputDecoration(hintText: 'номер'),
              ),
              TextFormField(
                controller: markaController,
                decoration: InputDecoration(hintText: 'марка'),
              ),
              ElevatedButton(onPressed: () {
                 var uuid = Uuid();
                AvtomobilRemote a = AvtomobilRemote(
                    id: uuid.v4(),
                    zayavka: BelongsTo<ZayavkaRemote>(zayavka),
                    nomer: "ТС1",
                    marka: "",
                    status: "NOVAYA");
                a.saveLocal();
                addFoto(zayavka,a);
                Navigator.pop(context);
              }, child: Text("фото"))
            ],
          ));

  }
   addFoto(ZayavkaRemote zayavka, AvtomobilRemote avto) async {
  final ImagePicker _picker = ImagePicker();

  var pickedFile = await _picker.pickImage(
      source: ImageSource.camera, imageQuality: 30, maxHeight: 2000);
       if(pickedFile!=null)Gal.putImage(pickedFile.path);


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

  

  
}
