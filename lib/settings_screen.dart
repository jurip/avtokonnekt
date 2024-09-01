import 'dart:io';
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

class SettingsScreen extends HookConsumerWidget {
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return ref.watch(repositoryInitializerProvider).when(
        error: (error, _) => Text(error.toString()),
        loading: () => const CircularProgressIndicator(),
        data: (_) {
         
          return ListView(
            padding: EdgeInsets.all(20),
            children: [
              SizedBox(height: 100,),
               ElevatedButton(
                    child: const Text('Выйти из учетной записи'),
                    onPressed: () {
                      logout(ref);
                      
                      context.go('/login');
                      
                    },
                  ),
                  SizedBox(height: 300,),
                  Image(image: AssetImage("assets/images/logoblack.png")),
                  SizedBox(height: 20,),
                  Text('Разработано компанией IT Evolution LLC'),
                  Text('   2024 год')

            ]
          );
        });
  
}

void logout(WidgetRef ref) {
    user.value = '';
    password.value = '';
    ref.currentUsers.clear();
    ref.avtomobilRemotes.clear();
    ref.calendarEvents.clear();
    ref.chekFotos.clear();
    ref.cheks.clear();
    ref.duties.clear();
    ref.fotos.clear();
    ref.myTokens.clear();
    ref.myUsers.clear();
    ref.oborudovanieFotos.clear();
    ref.oborudovanies.clear();
    ref.zayavkaRemotes.clear();
    
  }
}
