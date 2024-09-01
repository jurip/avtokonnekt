import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:fluttsec/src/models/oborudovanieFoto.dart';
import 'package:fluttsec/usluga_select_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_data/flutter_data.dart';
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
          final stateLocal = ref.zayavkaRemotes.watchAll( remote: false// HTTP param
         );
          final zFiltered = List.from(stateLocal.model);
          zFiltered.sort((a, b) => b.nachalo!.compareTo(a.nachalo!));
          final stateDuty = ref.duties.watchAll();
          final stateCurrentUser = ref.currentUsers.watchAll();

          return RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: () async {
                await ref.duties.findAll();
                List<ZayavkaRemote> zs = await ref.zayavkaRemotes.findAll( // HTTP param
       );
                for (ZayavkaRemote z in zs) {
                  sendZayavkaToCalendar(z, getLocation('UTC'), myCal);
                }
              },
              // Pull from top to show refresh indicator.
              child: ListView(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                        onPressed: () => context.go('/settings'),
                        icon: Icon(Icons.settings)),
                  ),
                  for (final u in stateCurrentUser.model)
                    Text(
                      '${u.firstName} ${u.lastName} ',
                      style: TextStyle(fontSize: 25),
                    ),
                  for (final duty in stateDuty.model)
                    Text(
                      '${duty.status}',
                      style: TextStyle(fontSize: 25),
                    ),
                  SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Мои заявки',
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                  for (final ZayavkaRemote zayavka in zFiltered)
                    Container(
                      margin: EdgeInsets.all(10),
                      child: ExpansionTile(
                          trailing: SizedBox.shrink(),
                          childrenPadding: EdgeInsets.all(5),
                          collapsedBackgroundColor: Colors.grey.shade200,
                          collapsedShape: const ContinuousRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text('${zayavka.nomer}',
                                    style: TextStyle(fontSize: 18)),
                              ),
                              Column(children: [
                                Text(
                                    '${DateFormat('dd.MM.yyyy').format(zayavka.nachalo!)}',
                                    style: TextStyle(fontSize: 15)),
                                Text(
                                    '${DateFormat('kk:mm').format(zayavka.nachalo!)}',
                                    style: TextStyle(fontSize: 15)),
                              ]),
                            ],
                          ),
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
                                                      '${DateFormat('dd.MM.yy kk:mm').format(zayavka.nachalo!)}',
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                Text(
                                                  '${zayavka.client}',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontStyle:
                                                          FontStyle.italic),
                                                ),
                                                GestureDetector(
                                                  child: Text(
                                                      '${zayavka.adres}',
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
                                                                    zayavka
                                                                        .lat!),
                                                                double.parse(
                                                                    zayavka
                                                                        .lng!));
                                                      else
                                                        MapsLauncher
                                                            .launchQuery(
                                                                zayavka.adres!);
                                                    }),
                                                Row(children: [
                                                  Expanded(
                                                    child: Text(
                                                        '${zayavka.contact_name}',
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ),
                                                  SizedBox(
                                                    width: 20,
                                                  ),
                                                  ElevatedButton(
                                                    child:
                                                        const Icon(Icons.phone),
                                                    onPressed: () =>
                                                        launchUrlString(
                                                            "tel://${zayavka.contact_number}"),
                                                  ),
                                                ]),
                                                SelectableText(
                                                    contextMenuBuilder:
                                                        (context,
                                                            editableTextState) {
                                                  final TextEditingValue value =
                                                      editableTextState
                                                          .currentTextEditingValue;
                                                  final List<
                                                          ContextMenuButtonItem>
                                                      buttonItems =
                                                      editableTextState
                                                          .contextMenuButtonItems;
                                                  buttonItems.insert(
                                                    0,
                                                    ContextMenuButtonItem(
                                                      label: 'Звони!',
                                                      onPressed: () {
                                                        String s = value.text
                                                            .substring(
                                                                value.selection
                                                                    .start,
                                                                value.selection
                                                                    .end);
                                                        if (s.startsWith('7'))
                                                          s = '+' + s;
                                                        launchUrlString(
                                                            "tel://${s}");
                                                      },
                                                    ),
                                                  );
                                                  return AdaptiveTextSelectionToolbar
                                                      .buttonItems(
                                                    anchors: editableTextState
                                                        .contextMenuAnchors,
                                                    buttonItems: buttonItems,
                                                  );
                                                }, '${zayavka.message} ',
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                              ])),
                                      ExpansionTile(
                                          childrenPadding: EdgeInsets.all(5),
                                          title: Text('Автомобили'),
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: <Widget>[
                                                const SizedBox(width: 8),
                                                ElevatedButton(
                                                  child: const Icon(
                                                      Icons.car_repair),
                                                  onPressed: () {
                                                    novoeAvto(context, zayavka);
                                                  },
                                                ),
                                                const SizedBox(width: 8),
                                              ],
                                            ),
                                            if(zayavka.avtomobili!=null)
                                            for (AvtomobilRemote avto
                                                in zayavka.avtomobili!.toList())
                                              ExpansionTile(
                                                  trailing: SizedBox.shrink(),
                                                  collapsedShape:
                                                      const ContinuousRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          20))),
                                                  title: Row(children: [
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                          '${avto.nomer}\n${avto.marka}${avto.nomerAG==null?'':'\nАГ:'}${avto.nomerAG??''}'),
                                                    ),
                                                    
                                                    ElevatedButton(
                                                        onPressed: () =>
                                                            showDeleteAlertAvto(
                                                                context,
                                                                zayavka,
                                                                avto),
                                                        child: const Icon(
                                                            Icons.cancel)),
                                                  ]),
                                                  collapsedBackgroundColor:
                                                      avto.status != "NOVAYA"
                                                          ? Colors.grey.shade200
                                                          : Color.fromARGB(255,
                                                              247, 130, 139),
                                                  children: <Widget>[
                                                    const SizedBox(width: 8),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      'Фотоотчет:',
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                    Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          ElevatedButton(
                                                            style: ButtonStyle(
                                                              backgroundColor:
                                                                  WidgetStateProperty.all<
                                                                          Color>(
                                                                      Colors
                                                                          .blue
                                                                          .shade100), // Change button color
                                                            ),
                                                            child: const Icon(Icons
                                                                .attach_file_rounded),
                                                            onPressed:
                                                                avto.status !=
                                                                        "NOVAYA"
                                                                    ? null
                                                                    : () {
                                                                        addFotos(
                                                                            zayavka,
                                                                            avto);
                                                                      },
                                                          ),
                                                          ElevatedButton(
                                                            style: ButtonStyle(
                                                              backgroundColor:
                                                                  WidgetStateProperty.all<
                                                                          Color>(
                                                                      Colors
                                                                          .blue
                                                                          .shade100), // Change button color
                                                            ),
                                                            child: const Icon(
                                                                Icons
                                                                    .add_a_photo),
                                                            onPressed:
                                                                avto.status !=
                                                                        "NOVAYA"
                                                                    ? null
                                                                    : () {
                                                                        addFoto(
                                                                            zayavka,
                                                                            avto);
                                                                      },
                                                          ),
                                                        ]),
                                                    if (!avto.fotos.isEmpty)
                                                      CarouselSlider(
                                                          options:
                                                              CarouselOptions(
                                                                  autoPlay:
                                                                      true,
                                                                  height:
                                                                      150.0),
                                                          items: [
                                                            for (Foto foto
                                                                in avto.fotos
                                                                    .toList())
                                                              Stack(
                                                                  children: <Widget>[
                                                                    ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                8.0),
                                                                        child:
                                                                            Image(
                                                                          image:
                                                                              FileImage(File(foto.fileLocal!)),
                                                                          height:
                                                                              180,
                                                                        )),
                                                                    Positioned(
                                                                        right:
                                                                            -2,
                                                                        top: -9,
                                                                        child:
                                                                            IconButton(
                                                                          icon:
                                                                              Icon(
                                                                            Icons.cancel,
                                                                            color:
                                                                                Colors.black.withOpacity(0.5),
                                                                            size:
                                                                                50,
                                                                          ),
                                                                          onPressed:
                                                                              () {
                                                                            foto.deleteLocal();
                                                                            avto.saveLocal();
                                                                            zayavka.saveLocal();
                                                                          },
                                                                        ))
                                                                  ])
                                                          ]),
                                                    Text(
                                                      'Услуги:',
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                    ElevatedButton(
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            WidgetStateProperty
                                                                .all<Color>(Colors
                                                                    .blue
                                                                    .shade100), // Change button color
                                                      ),
                                                      child: const Icon(Icons
                                                          .build_circle_rounded),
                                                      onPressed:
                                                          avto.status !=
                                                                  "NOVAYA"
                                                              ? null
                                                              : () async {
                                                                  UslugaSelect?
                                                                      result =
                                                                      await Navigator
                                                                          .push(
                                                                    context,
                                                                    // Create the SelectionScreen in the next step.
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                UslugaSelectScreen(avto: avto)),
                                                                  );
                                                                  zayavka
                                                                      .saveLocal();
                                                                },
                                                    ),
                                                    for (Usluga usluga in avto
                                                        .performance_service
                                                        .toList())
                                                      Container(
                                                        padding:
                                                            EdgeInsets.all(0),
                                                        child: Container(
                                                          margin:
                                                              EdgeInsets.all(
                                                                  10),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            color: Colors
                                                                .blue.shade200,
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          17),
                                                                  '${usluga.title}',
                                                                ),
                                                              ),
                                                              ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    usluga
                                                                        .deleteLocal();
                                                                    avto.saveLocal();
                                                                    zayavka
                                                                        .saveLocal();
                                                                  },
                                                                  child: Icon(Icons
                                                                      .cancel))
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    Text(
                                                      'Оборудование:',
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                    ElevatedButton(
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            WidgetStateProperty
                                                                .all<Color>(Colors
                                                                    .blue
                                                                    .shade100), // Change button color
                                                      ),
                                                      child: const Icon(
                                                          Icons.barcode_reader),
                                                      onPressed: avto.status !=
                                                              "NOVAYA"
                                                          ? null
                                                          : () async {
                                                              var res =
                                                                  await Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                const SimpleBarcodeScannerPage(),
                                                                      ));
                                                              if (res is String &&
                                                                  res != '-1') {
                                                                Oborudovanie o =
                                                                    Oborudovanie(
                                                                        avtomobil:
                                                                            BelongsTo<AvtomobilRemote>(
                                                                                avto),
                                                                        code:
                                                                            res);
                                                                
                                                                o.saveLocal();
                                                                avto.saveLocal();
                                                                zayavka
                                                                    .saveLocal();
                                                              }
                                                            },
                                                    ),
                                                    for (Oborudovanie oborudovanie
                                                        in avto.barcode
                                                            .toList())
                                                      Container(
                                                        padding:
                                                            EdgeInsets.all(0),
                                                        child: Container(
                                                          margin:
                                                              EdgeInsets.all(
                                                                  10),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            color: Colors
                                                                .blue.shade200,
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          17),
                                                                  '${oborudovanie.code}',
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  softWrap:
                                                                      false,
                                                                ),
                                                              ),
                                                              ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    oborudovanie
                                                                        .deleteLocal();
                                                                    avto.saveLocal();
                                                                    zayavka
                                                                        .saveLocal();
                                                                  },
                                                                  child: Icon(Icons
                                                                      .cancel))
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          ElevatedButton(
                                                            style: ButtonStyle(
                                                              backgroundColor:
                                                                  WidgetStateProperty.all<
                                                                          Color>(
                                                                      Colors
                                                                          .blue
                                                                          .shade100), // Change button color
                                                            ),
                                                            child: const Icon(
                                                                Icons
                                                                    .attach_file),
                                                            onPressed:
                                                                avto.status !=
                                                                        "NOVAYA"
                                                                    ? null
                                                                    : () {
                                                                        addOborudovanieFotos(
                                                                            zayavka,
                                                                            avto);
                                                                      },
                                                          ),
                                                          ElevatedButton(
                                                            style: ButtonStyle(
                                                              backgroundColor:
                                                                  WidgetStateProperty.all<
                                                                          Color>(
                                                                      Colors
                                                                          .blue
                                                                          .shade100), // Change button color
                                                            ),
                                                            child: const Icon(
                                                                Icons
                                                                    .add_a_photo),
                                                            onPressed:
                                                                avto.status !=
                                                                        "NOVAYA"
                                                                    ? null
                                                                    : () {
                                                                        addOborudovanieFoto(
                                                                            zayavka,
                                                                            avto);
                                                                      },
                                                          ),
                                                        ]),
                                                    if (!avto.oborudovanieFotos
                                                        .isEmpty)
                                                      CarouselSlider(
                                                          options:
                                                              CarouselOptions(
                                                                  height:
                                                                      150.0),
                                                          items: [
                                                            for (OborudovanieFoto foto
                                                                in avto
                                                                    .oborudovanieFotos
                                                                    .toList())
                                                              Stack(
                                                                  children: <Widget>[
                                                                    ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                8.0),
                                                                        child:
                                                                            Image(
                                                                          image:
                                                                              FileImage(File(foto.fileLocal!)),
                                                                          height:
                                                                              180,
                                                                        )),
                                                                    Positioned(
                                                                        right:
                                                                            -2,
                                                                        top: -9,
                                                                        child:
                                                                            IconButton(
                                                                          icon:
                                                                              Icon(
                                                                            Icons.cancel,
                                                                            color:
                                                                                Colors.black.withOpacity(0.5),
                                                                            size:
                                                                                50,
                                                                          ),
                                                                          onPressed:
                                                                              () {
                                                                            foto.deleteLocal();
                                                                            avto.saveLocal();
                                                                            zayavka.saveLocal();
                                                                          },
                                                                        ))
                                                                  ])
                                                          ]),
                                                    ElevatedButton(
                                                        onPressed:
                                                            avto.status !=
                                                                    "NOVAYA"
                                                                ? null
                                                                : () async {
                                                                    if (await checkConnection()) {
                                                                      avto.status =
                                                                          'TEMP';
                                                                      avto.saveLocal();
                                                                      zayavka
                                                                          .saveLocal();
                                                                          bool r = false;
                                                                          if(avto.zayavka?.id==null)
                                                                          showError(avto.toString());
                                                                      try {
                                                                         r = await saveWithPhotos(
                                                                            avto,
                                                                            ref,
                                                                            token.value);
                                                                      } on Exception catch (e) {
                                                                        avto.status = "NOVAYA";
                                                                        avto.saveLocal();
                                                                        zayavka.saveLocal();
                                                                        showError(
                                                                            e.toString());
                                                                        // make it explicit that this function can throw exceptions
                                                                        rethrow;
                                                                      }

                                                                      if (r) {
                                                                        avto.status =
                                                                            "GOTOWAYA";
                                                                        avto.saveLocal();
                                                                        zayavka
                                                                            .saveLocal();
                                                                        infoToast(
                                                                            "Сохранено в системе");
                                                                      } else {
                                                                        avto.status =
                                                                            "NOVAYA";
                                                                        avto.saveLocal();
                                                                        zayavka
                                                                            .saveLocal();

                                                                        infoToast(
                                                                            "Ошибка при сохранении в системе");
                                                                      }

                                                                      infoToast(
                                                                          "Отправлено");
                                                                    }
                                                                  },
                                                        child: const Text(
                                                            "готово")),
                                                  ])
                                          ])
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ]),
                    ),
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
                var uuid = Uuid();
                AvtomobilRemote a = AvtomobilRemote(
                  id:uuid.v1(),
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
                    Oborudovanie(avtomobil: BelongsTo<AvtomobilRemote>(avto), code: kod);
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

  List<Widget> phones(String? string) {
    List<Widget> r = [];
    int st = 0;
    String s = '';
    if (string != null) s = string;

    RegExp regExp = new RegExp(r'[0-9]{11}');
    for (RegExpMatch element in regExp.allMatches(s)) {
      r.add(Text(s.substring(st, element.start)));
      r.add(GestureDetector(
        child: Text(
          s.substring(element.start, element.end),
          style: TextStyle(color: Colors.blue.shade200),
        ),
      ));
      st = element.end;
    }
    return r;
  }

  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  addFotos(ZayavkaRemote zayavka, AvtomobilRemote avto) async {
    final ImagePicker _picker = ImagePicker();

    var pickedFiles = await _picker.pickMultiImage(imageQuality: 30, maxHeight: 2000);

    if (!pickedFiles.isEmpty) {
      for (var pickedFile in pickedFiles) {
        Foto f = Foto(fileLocal: pickedFile.path, avtomobil: BelongsTo<AvtomobilRemote>(avto));
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
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 30, maxHeight: 2000);

    if (pickedFile != null) {
      Foto f = Foto(fileLocal: pickedFile.path, avtomobil: BelongsTo<AvtomobilRemote>(avto));
      f.saveLocal();

      avto.saveLocal();
      zayavka.saveLocal();
    } else {
      final snackBar = SnackBar(
        content: const Text('фото не добавлено'),
      );
    }
  }

  addOborudovanieFotos(ZayavkaRemote zayavka, AvtomobilRemote avto) async {
    final ImagePicker _picker = ImagePicker();

    var pickedFiles = await _picker.pickMultiImage(imageQuality: 30, maxHeight: 2000);

    if (!pickedFiles.isEmpty) {
      for (var pickedFile in pickedFiles) {
        OborudovanieFoto f = OborudovanieFoto(
            fileLocal: pickedFile.path, avtomobil: BelongsTo<AvtomobilRemote>(avto));
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

    var pickedFile =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 30, maxHeight: 2000);

    if (pickedFile != null) {
      OborudovanieFoto f = OborudovanieFoto(
          fileLocal: pickedFile.path, avtomobil: BelongsTo<AvtomobilRemote>(avto));
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
class UpperCaseTextFormatter extends TextInputFormatter {
  
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}