import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttsec/avto_widget.dart';
import 'package:fluttsec/src/models/avtoFoto.dart';
import 'package:fluttsec/src/models/avtomobilLocal.dart';
import 'package:gal/gal.dart';
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
          zFiltered.sort((a, b) 
          
          { if(a.nachalo!=null && b.nachalo!=null) return b.nachalo!.compareTo(a.nachalo!);else return 0;});
          ref.duties.findAll();
          final stateDuty = ref.duties.watchAll();
          final stateCurrentUser = ref.currentUsers.watchAll();

          final stateAvtoLocal =
              ref.avtomobilRemotes.watchAll(remote: false // HTTP param
                  );

          return RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: () async {
                await ref.duties.findAll();
                ref.zayavkaRemotes.findAll();

                // sendToCalendar(ref);
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
                  Center(child: 
                    Container(
                        decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  offset: Offset(0, 4),
                  blurRadius: 8,
                  spreadRadius: 0)
              ],
            ),
                        margin: EdgeInsets.all(10),
                        child: Text(
                          '${u.firstName} ${u.lastName} ',
                          style: TextStyle(fontSize: 25),
                        ))),
                  for (final duty in stateDuty.model)
                  Center(child: 
                    Container(
                        decoration: BoxDecoration(
                          //color: Colors.grey.shade200,
                         
                          borderRadius: BorderRadius.circular(10),
                          
                        ),
                        margin: EdgeInsets.all(10),
                        child: Text(
                          '${duty.status}',
                          style: TextStyle(fontSize: 25, color: Colors.red),
                        ))),
                   
                  SizedBox(height: 10),

                  Container(
                     decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  offset: Offset(0, 4),
                  blurRadius: 8,
                  spreadRadius: 0)
              ],
            ),
                    child: Column(
                      children: [

                  Center(
                    child: Text(
                      'заявки',
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                  for (final ZayavkaRemote zayavka in zFiltered)
                    zayavkaWidget(zayavka, context),
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

  Container zayavkaWidget(ZayavkaRemote zayavka, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  offset: Offset(0, 4),
                  blurRadius: 8,
                  spreadRadius: 0)
              ],
            ),
      margin: EdgeInsets.all(10),
      child: ExpansionTile(
          trailing: SizedBox.shrink(),
          childrenPadding: EdgeInsets.all(5),
          collapsedBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
          collapsedShape: const ContinuousRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Row(
            children: [
              Expanded(
                child: Text('${zayavka.nomer}', style: TextStyle(fontSize: 18)),
              ),
              Expanded(
                child:
                    Text('${zayavka.client}', style: TextStyle(fontSize: 18)),
              ),
              Column(children: [
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ElevatedButton(
                        child: const Text('Закрыть'),
                        onPressed: () async {
                          showDeleteAlert(context, zayavka);
                        },
                      ),
                      ElevatedButton(
                        child: const Text('Отменилась'),
                        onPressed: () async {
                          showCancelAlert(context, zayavka);
                        },
                      ),
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
                                Text(
                                  '${zayavka.client}',
                                  style: TextStyle(
                                      fontSize: 20,
                                      ),
                                ),
                                GestureDetector(
                                  child: Text('${zayavka.adres}',
                                      style: TextStyle(fontSize: 23)),
                                  onTap: () =>
                                      MapsLauncher.launchQuery(zayavka.adres!),
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
                                Row(children: [
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
                                SelectableText(contextMenuBuilder:
                                        (context, editableTextState) {
                                  final TextEditingValue value =
                                      editableTextState.currentTextEditingValue;
                                  final List<ContextMenuButtonItem>
                                      buttonItems =
                                      editableTextState.contextMenuButtonItems;
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
                                    anchors:
                                        editableTextState.contextMenuAnchors,
                                    buttonItems: buttonItems,
                                  );
                                }, '${zayavka.message} ',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500)),
                              ])),
                      ExpansionTile(
                          childrenPadding: EdgeInsets.all(5),
                          title: Text('Автомобили'),
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  child: const Icon(Icons.car_repair),
                                  onPressed: () {
                                    novoeAvto(context, zayavka);
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
                                  in zayavka.avtomobili!.toList())
                                AvtoWidget(avto, zayavka)
                          ])
                    ],
                  ),
                ),
              ],
            )
          ]),
    );
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
               Container(padding: EdgeInsets.all(10),
                child: 
              TextFormField(
                inputFormatters: [
                  UpperCaseTextFormatter(),
                ],
                controller: nomerController,
                decoration: InputDecoration(hintText: 'номер'),
              ),),
              Container(padding: EdgeInsets.all(10),
                child:  TextFormField(
                controller: markaController,
                decoration: InputDecoration(hintText: 'марка'),
              ),),
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

                  AvtomobilLocal al = AvtomobilLocal(
                      id: uuid.v4(),
                      zayavka: BelongsTo<ZayavkaRemote>(zayavka),
                      nomer: nomer,
                      marka: marka,
                      status: "NOVAYA");
                  al.saveLocal();
                  zayavka.saveLocal();
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
          child: 
          Container(
            padding: EdgeInsets.all(10),
            child: 
          ListView(
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
          //style: TextStyle(color: Colors.blue.shade200),
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
