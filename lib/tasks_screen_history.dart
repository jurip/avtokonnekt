import 'package:flutter_data/flutter_data.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttsec/avto_widget.dart';
import 'package:fluttsec/cheki_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fluttsec/main.data.dart';
import 'package:fluttsec/src/models/avtomobilRemote.dart';
import 'package:fluttsec/src/models/zayavkaRemote.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TasksScreenHistory extends HookConsumerWidget {
  TasksScreenHistory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

var avtos = useState([]);
    
    useEffect(() {
      Future<void>.microtask(() async {

        SharedPreferences.getInstance().then((prefs) => {
  prefs.reload().then((_) {
    // Do the staff
     avtos.value = prefs.getKeys().toList();
//todo
     prefs.clear();
  })
});

       
        
       
      });
      return null;
    });

    return ref.watch(repositoryInitializerProvider).when(
        error: (error, _) => Text(error.toString()),
        loading: () => const CircularProgressIndicator(),
        data: (_) {
          final stateLocal =
              ref.zayavkaRemotes.watchAll(remote: false
                  );
           List<ZayavkaRemote> zFiltered = List.from(stateLocal.model);
          zFiltered = zFiltered.where((element) => element.status=='VYPOLNENA',).toList();
          zFiltered.sort((a, b) => b.nachalo!.compareTo(a.nachalo!));
         
          return 
              
             
              // Pull from top to show refresh indicator.
             ListView(
                children: [

                   for(var a in avtos.value)
                  Container(
                    color: Colors.amber,
      margin: EdgeInsets.all(10),
      child:
      GestureDetector(
        onTap: () async{
          AvtomobilRemote? ar = await ref.avtomobilRemotes.findOne(a);
          ar!.status = "NOVAYA";
          ar.saveLocal();
        },
        child: 
      Text("Отчет "+ a+" "))),
            
                  for (final ZayavkaRemote zayavka in zFiltered)
                    zayavkaWidget(zayavka, context),
                ],
              );
        });
  }

  Container zayavkaWidget(ZayavkaRemote zayavka, BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: ExpansionTile(
          trailing: SizedBox.shrink(),
          childrenPadding: EdgeInsets.all(5),
          collapsedBackgroundColor: Colors.grey.shade200,
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
                Text('${DateFormat('dd.MM.yyyy').format(zayavka.nachalo!)}',
                    style: TextStyle(fontSize: 15)),
                Text('${DateFormat('kk:mm').format(zayavka.nachalo!)}',
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
                    
                      ListTile(
                          isThreeLine: true,
                          subtitle: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                if (zayavka.nachalo != null)
                                  Text(
                                      '${DateFormat('dd.MM.yy kk:mm').format(zayavka.nachalo!)}',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                Text(
                                  '${zayavka.client}',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontStyle: FontStyle.italic),
                                ),
                             
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
                                    onPressed: () => launchUrlString(
                                        "tel://${zayavka.contact_number}"),
                                  ),
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




}


