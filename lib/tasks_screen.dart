import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttsec/avto_widget.dart';
import 'package:fluttsec/otchet_widget.dart';
import 'package:fluttsec/src/models/avtoFoto.dart';
import 'package:fluttsec/src/models/currentUser.dart';
import 'package:fluttsec/src/notifications/app_notifications.dart';
import 'package:gal/gal.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/uuid.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:fluttsec/main.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:fluttsec/main.data.dart';
import 'package:fluttsec/send_zayavka_to_calendar.dart';
import 'package:fluttsec/src/models/avtomobilRemote.dart';
import 'package:fluttsec/src/models/oborudovanie.dart';
import 'package:fluttsec/src/models/zayavkaRemote.dart';
import 'package:fluttsec/src/remote/update_zayavka.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TasksScreen extends HookConsumerWidget {
  TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useOnAppLifecycleStateChange((previous, current) async {
      String s = current.name;
      if (s == 'resumed') {
        if (await loadZayavkaFromPrefs(ref)) {}
      }
    });

    useEffect(() {
      loadZayavkaFromPrefs(ref);
      _determinePosition();
      return () => {};
    }, []);

    return ref.watch(repositoryInitializerProvider).when(
        error: (error, _) => Text(error.toString()),
        loading: () => const CircularProgressIndicator(),
        data: (_) {
          final stateLocal =
              ref.zayavkaRemotes.watchAll(remote: false // HTTP param
                  );
          List<ZayavkaRemote> zFiltered = List.from(stateLocal.model);
          zFiltered = zFiltered
              .where(
                (element) => element.status == 'NOVAYA',
              )
              .toList();
          zFiltered.sort((a, b) {
            if (a.nachalo != null && b.nachalo != null) {
              if (b.nachalo!.year != a.nachalo!.year)
                return b.nachalo!.year.compareTo(a.nachalo!.year);
              if (b.nachalo!.month != a.nachalo!.month)
                return b.nachalo!.month.compareTo(a.nachalo!.month);
              if (b.nachalo!.day != a.nachalo!.day)
                return b.nachalo!.day.compareTo(a.nachalo!.day);
              if (b.nachalo!.hour != a.nachalo!.hour)
                return a.nachalo!.hour.compareTo(b.nachalo!.hour);
              if (b.nachalo!.minute != a.nachalo!.minute)
                return a.nachalo!.minute.compareTo(b.nachalo!.minute);
              if (b.nachalo!.second != a.nachalo!.second)
                return a.nachalo!.second.compareTo(b.nachalo!.second);

              return a.nachalo!.microsecond.compareTo(b.nachalo!.microsecond);
            } else
              return 0;
          });
          ref.duties.findAll(
            onError: (e, label, adapter) {
              //infoToast("Нет связи");
              return List.empty();
            },
          );
          final stateDuty = ref.duties.watchAll();
          final stateCurrentUser = ref.currentUsers.watchAll();

          final stateAvtoLocal =
              ref.avtomobilRemotes.watchAll(remote: false // HTTP param
                  );

          return RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: () async {
                await ref.duties.findAll(
                  onError: (e, label, adapter) {
                    return List.empty();
                  },
                );
                ref.zayavkaRemotes.findAll(
                  onError: (e, label, adapter) {
                    return List.empty();
                  },
                );

                // sendToCalendar(ref);
              },
              // Pull from top to show refresh indicator.
              child: ListView(
                children: [
                  Container(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () {
                        context.go('/settings');
                      },
                      icon: Icon(Icons.settings),
                    ),
                  ),
                  Row(children: [
                    for (final u in stateCurrentUser.model)
                      Flexible(
                          child: Center(
                              child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Theme.of(context).colorScheme.surface
                                  ),
                                  margin: EdgeInsets.all(10),
                                  child: Text(
                                    '${u.firstName} ${u.lastName} ',
                                    softWrap: true,
                                    style: TextStyle(fontSize: 25),
                                  )))),
                    for (final duty in stateDuty.model)
                      Center(
                          child: Container(
                              decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Theme.of(context).colorScheme.surface
                                  ),
                              margin: EdgeInsets.all(10),
                              child: Text(
                                '${duty.status}',
                                style:
                                    TextStyle(fontSize: 25, color: Colors.red),
                              ))),
                  ]),
                  SizedBox(height: 10),
                  Container(
                       decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Theme.of(context).colorScheme.surface
                                  ),
                      child: Column(children: [
                        Center(
                          child: Text(
                            'заявки',
                            style: TextStyle(fontSize: 30),
                          ),
                        ),
                        for (final ZayavkaRemote zayavka in zFiltered)
                          zayavkaWidget(
                              zayavka, context, stateCurrentUser.model),
                      ]))
                ],
              ));
        });
  }

  void sendToCalendar(WidgetRef ref) {
    ref.zayavkaRemotes.findAll().asStream().forEach(
      (element) {
        for (var z in element) {
          sendZayavkaToCalendar(ref, z, getLocation('UTC'), myCal);
        }
      },
    );
  }

  Container zayavkaWidget(
      ZayavkaRemote zayavka, BuildContext context, List<CurrentUser> model) {
    return Container(
      
      margin: EdgeInsets.all(10),
      child: ExpansionTile(
          trailing: SizedBox.shrink(),
          childrenPadding: EdgeInsets.all(5),
          collapsedShape: const ContinuousRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Row(
            children: [
              Expanded(
                child: Text('${zayavka.nomer}', style: TextStyle(fontSize: 18)),
              ),
              Expanded(
                child:
                    Text('${zayavka.client}', style: TextStyle(fontSize: 12)),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                if (zayavka.nachalo != null)
                  Text('${DateFormat('dd.MM.yyyy').format(zayavka.nachalo!)}',
                      style: TextStyle(fontSize: 15)),
                if (zayavka.nachalo != null)
                  Text('${DateFormat('HH:mm').format(zayavka.nachalo!)}',
                      style: TextStyle(fontSize: 15)),
              ]),
            ],
          ),
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Card(
                  elevation: 10,
                  child: Container(
                    color: Theme.of(context).colorScheme.surface,
                    padding: EdgeInsets.all(5),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(children: <Widget>[
                          ElevatedButton(
                            child: const Text('Закрыть'),
                            onPressed: () async {
                              showDeleteAlert(context, zayavka);
                            },
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          ElevatedButton(
                            child: const Text('Отменилась'),
                            onPressed: () async {
                              showCancelAlert(context, zayavka);
                            },
                          ),
                        ]),
                        ListTile(
                            isThreeLine: true,
                            subtitle: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  if (zayavka.nachalo != null)
                                    Text(
                                        '${DateFormat('dd.MM.yy HH:mm').format(zayavka.nachalo!)}',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                  Container(
                                   
                                    child: Text(
                                      '${zayavka.client}',
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  Row(children: <Widget>[
                                    Flexible(
                                      child: GestureDetector(
                                        child: Text('${zayavka.adres}',
                                            style: TextStyle(fontSize: 23)),
                                        onTap: () => MapsLauncher.launchQuery(
                                            zayavka.adres!),
                                      ),
                                    ),
                                    ElevatedButton(
                                        child: const Icon(Icons.navigation),
                                        onPressed: () {
                                          if (zayavka.lat != "" &&
                                              zayavka.lng != "")
                                            MapsLauncher.launchCoordinates(
                                                double.parse(zayavka.lat!),
                                                double.parse(zayavka.lng!));
                                          else
                                            MapsLauncher.launchQuery(
                                                zayavka.adres!);
                                        }),
                                  ]),
                                  Container(
              
                                    child: Row(children: [
                                      Expanded(
                                        child: Text('${zayavka.contact_name}',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      ElevatedButton(
                                          child: const Icon(Icons.phone),
                                          onPressed: () {
                                            var s = zayavka.contact_number!;
                                            if (s.startsWith('7')) s = '+' + s;
                                            launchUrlString("tel://${s}");
                                          }),
                                    ]),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                   
                                    child: SelectableText(contextMenuBuilder:
                                            (context, editableTextState) {
                                      final TextEditingValue value =
                                          editableTextState
                                              .currentTextEditingValue;
                                      final List<ContextMenuButtonItem>
                                          buttonItems = editableTextState
                                              .contextMenuButtonItems;
                                      buttonItems.insert(
                                        0,
                                        ContextMenuButtonItem(
                                          label: 'Звони!',
                                          onPressed: () {
                                            String s = value.text.substring(
                                                value.selection.start,
                                                value.selection.end);
                                            if (s.startsWith('7')) s = '+' + s;
                                            launchUrlString("tel://${s}");
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
                                            fontWeight: FontWeight.w500)),
                                  ),
                                ])),
                        ExpansionTile(
                            childrenPadding: EdgeInsets.all(5),
                            title: Text(
                              '              Отчеты',
                              style: TextStyle(fontSize: 22),
                            ),
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      elevation: WidgetStatePropertyAll(5),
                                    ),
                                    child: const Text(
                                      "Добавить Объект",
                                      style: TextStyle(fontSize: 24),
                                    ),
                                    onPressed: () {
                                      if (model.elementAt(0).tip == 'OTCHET') {
                                        novyjOtchet(context, zayavka);
                                      } else {
                                        novoeAvto(context, zayavka);
                                      }
                                      //  Navigator.push<Widget>(
                                      //context,
                                      //MaterialPageRoute(
                                      //   builder: (context) => NewAvtoScreen(zayavka),
                                      //  ),
                                      // );
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                              if (zayavka.avtomobili != null)
                                for (AvtomobilRemote avto
                                    in sortedAvto(zayavka.avtomobili!.toList()))
                                  for (CurrentUser u in model)
                                    Container(
                                        padding: EdgeInsets.only(bottom: 5),
                                        child: u.tip == 'OTCHET'
                                            ? OtchetWidget(avto, zayavka)
                                            : AvtoWidget(avto, zayavka))
                            ])
                      ],
                    ),
                  ),
                ),
              ],
            )
          ]),
    );
  }

  List sortedAvto(List<AvtomobilRemote> avtos) {
    avtos.sort((a, b) {
      if (a.date == null) return 1;
      if (b.date == null) return 1;

      return a.date!.compareTo(b.date!);
    });
    return avtos;
  }

  void novoeAvto(context, ZayavkaRemote zayavka) {
    showDialog(
      context: context,
      builder: (_) {
        var nomerController = TextEditingController();

        var markaController = TextEditingController();

        return Dialog(
          child: ListView(
            shrinkWrap: true,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                  inputFormatters: [
                    UpperCaseTextFormatter(),
                  ],
                  controller: nomerController,
                  decoration: InputDecoration(hintText: 'номер'),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                  controller: markaController,
                  decoration: InputDecoration(hintText: 'марка'),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    var uuid = Uuid();

                    var n = zayavka.avtomobili?.length ?? 0;

                    AvtomobilRemote a = AvtomobilRemote(
                        id: uuid.v4(),
                        zayavka: BelongsTo<ZayavkaRemote>(zayavka),
                        nomer: "ТС" + (n + 1).toString(),
                        marka: "",
                        status: "NOVAYA");
                    initPosition(a);
                    a.saveLocal();
                    addFoto(zayavka, a);
                    Navigator.pop(context);
                  },
                  child: Text("фото")),
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
                      id: uuid.v4(),
                      zayavka: BelongsTo<ZayavkaRemote>(zayavka),
                      nomer: nomer,
                      marka: marka,
                      status: "NOVAYA");
                  a.saveLocal();
                  initPosition(a);
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

  void novyjOtchet(context, ZayavkaRemote zayavka) {
    showDialog(
      context: context,
      builder: (_) {
        var nomerController = TextEditingController();

        return Dialog(
          child: ListView(
            shrinkWrap: true,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                  inputFormatters: [
                    UpperCaseTextFormatter(),
                  ],
                  controller: nomerController,
                  decoration: InputDecoration(hintText: 'объект'),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Send them to your email maybe?
                  var nomer = nomerController.text;
                  var uuid = Uuid();
                  AvtomobilRemote a = AvtomobilRemote(
                      id: uuid.v4(),
                      zayavka: BelongsTo<ZayavkaRemote>(zayavka),
                      nomer: nomer,
                      marka: "",
                      status: "NOVAYA");
                  a.saveLocal();
                  initPosition(a);
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

  addFoto(ZayavkaRemote zayavka, AvtomobilRemote avto) async {
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

  void showBarcode(context, ZayavkaRemote zayavka, AvtomobilRemote avto) {
    showDialog(
      context: context,
      builder: (_) {
        var codeController = TextEditingController();

        return Dialog(
          child: ListView(
            shrinkWrap: true,
            children: [
              TextFormField(
                controller: codeController,
                decoration: InputDecoration(hintText: 'штрихкод'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Send them to your email maybe?
                  var kod = codeController.text;

                  Oborudovanie o = Oborudovanie(
                      avtomobil: BelongsTo<AvtomobilRemote>(avto), code: kod);
                  o.saveLocal();
                  avto.saveLocal();
                  zayavka.saveLocal();
                  Navigator.pop(context);
                },
                child: Text('Готово'),
              ),
            ],
          ),
        );
      },
    );
  }

  void showDeleteAlert(context, ZayavkaRemote zayavka) {
    showDialog(
      context: context,
      builder: (_) {
        var codeController = TextEditingController();
        var hasnoopendAvtos =
            zayavka.avtomobili?.where((p0) => p0.isOpen()).isEmpty;

        var text = hasnoopendAvtos == false
            ? "У вас остались незакрытые отчеты"
            : 'Уверены что хотите закрыть заявку?';

        return Dialog(
          child: Container(
            padding: EdgeInsets.all(10),
            child: ListView(
              shrinkWrap: true,
              children: [
                Text(text),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: hasnoopendAvtos == true
                      ? () async {
                          if (await updateZayavka(
                              zayavka, token.value, "VYPOLNENA"))
                            zayavka.status = "VYPOLNENA";
                          zayavka.saveLocal();

                          Navigator.pop(context);
                        }
                      : null,
                  child: Text('Готово'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showCancelAlert(context, ZayavkaRemote zayavka) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          child: ListView(
            shrinkWrap: true,
            children: [
              Text('Уверены что хотите отменить заявку?'),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (await updateZayavka(zayavka, token.value, "OTMENA"))
                    zayavka.status = "OTMENA";
                  zayavka.saveLocal();

                  Navigator.pop(context);
                },
                child: Text('Готово'),
              ),
            ],
          ),
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
          
        ),
      ));
      st = element.end;
    }
    return r;
  }

  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
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
