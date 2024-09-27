import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttsec/main.dart';
import 'package:fluttsec/main.data.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfisScreen extends HookConsumerWidget {
  
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
                    child: const Text('Чеки'),
                    onPressed: () {
                      context.go('/cheki');
                      
                    },
                  ),
                   ElevatedButton(
                    child: const Text('Перемещение оборудования'),
                    onPressed: () {
                      context.go('/peremeshenie');
                      
                    },
                  ),
                 

            ]
          );
        });
  
}


}
