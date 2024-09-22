import 'package:flutter_data/flutter_data.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttsec/avto_local_widget.dart';
import 'package:fluttsec/avto_widget.dart';
import 'package:fluttsec/cheki_screen.dart';
import 'package:fluttsec/src/models/avtomobilLocal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fluttsec/main.data.dart';
import 'package:fluttsec/src/models/avtomobilRemote.dart';
import 'package:fluttsec/src/models/zayavkaRemote.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class OtchetyScreen extends HookConsumerWidget {
  OtchetyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    

    return ref.watch(repositoryInitializerProvider).when(
        error: (error, _) => Text(error.toString()),
        loading: () => const CircularProgressIndicator(),
        data: (_) {
          final stateLocal =
              ref.avtomobilLocals.watchAll(remote: false
                  );
           List<AvtomobilLocal> zFiltered = List.from(stateLocal.model);
        
          return 
              
             
              // Pull from top to show refresh indicator.
             ListView(
                children: [

                   for(var a in zFiltered)
                   AvtoLocalWidget(a, a.zayavka!.value!)
        
                ],
              );
        });
  }





}


