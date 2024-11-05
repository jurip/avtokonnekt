import 'package:flutter/material.dart';

import 'package:flutter_data/flutter_data.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttsec/main.data.dart';
import 'package:fluttsec/src/models/avtomobilRemote.dart';
import 'package:fluttsec/src/models/user.dart';
import 'package:fluttsec/src/models/userSelect.dart';
import 'package:fluttsec/src/models/usluga.dart';
import 'package:fluttsec/src/models/uslugaSelect.dart';
import 'package:fluttsec/src/models/zayavkaRemote.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

class UserSelectScreen extends HookConsumerWidget {
  const UserSelectScreen({super.key, required this.avto, required this.zayavka});

  final AvtomobilRemote avto;
  final ZayavkaRemote zayavka;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(repositoryInitializerProvider).when(

        error: (error, _) => Text(error.toString()),
        loading: () => const CircularProgressIndicator(),
        data: (_) {
          final stateUsers = ref.userSelects.watchAll(remote: false);

          List<UserSelect> ff = List.from(stateUsers.model);
          ff.sort((a, b) => a.lastName!.compareTo(b.lastName!));
          final filteredUsers = useState(ff);
          final selectedUsers = useState(avto.users.toList());

          final searchController = useTextEditingController(text: '');
          searchController.addListener(
            () {
              filteredUsers.value = stateUsers.model
                  .where(
                    (UserSelect element) {
                      String t = element.lastName!;
                      List<String> s = searchController.value.text.toLowerCase().split(' ');
                      
                      bool r = s.every((element) => t.contains(element));
                        return r;
                    }
                  )
                  .toList();
                  print('|'+searchController.value.text+'|');
                  print(filteredUsers.value);
            },
          );
          // TODO: implement build
          return Scaffold(
              appBar: AppBar(
                title: Row(children: [ 
                  Text('Выберите сопользователя'),
                  Spacer(),
                  IconButton(onPressed: () => context.pop(),
                   icon: Icon(Icons.check))
                  ]
                ),
              ),
              body: Center(
                  child: ListView(
                shrinkWrap: true,
                children: [
                  TextFormField(
                    controller: searchController,
                    decoration: InputDecoration(hintText: 'поиск'),
                   
                  ),
                   const Icon( Icons.search),
                  for (UserSelect u in filteredUsers.value)
                    ListTile(
                      leading: Checkbox(
                          value: selectedUsers.value.any(
                            (element) => element.username == u.username,
                          ),
                          onChanged: (value) {
                            if (selectedUsers.value.any(
                              (element) => element.username == u.username,
                            )) {
                              selectedUsers.value
                                  .where(
                                    (element) => element.username == u.username,
                                  )
                                  .forEach(
                                    (element) {
                                      
                                        element.deleteLocal();

                                    },
                                  );
                              selectedUsers.value = [
                                ...selectedUsers.value
                                  ..removeWhere(
                                    (element) => element.username == u.username,
                                  )
                              ];
                            } else {
                              User newu = User(
                                 id:Uuid().v4(),
                                  firstName: u.firstName,
                                  lastName: u.lastName,
                                  username: u.username,
                                  
                                  avtomobil: BelongsTo<AvtomobilRemote>(avto));

                              
                              newu.saveLocal();

                              selectedUsers.value = [
                                ...selectedUsers.value..add(newu)
                              ];
                            }
                            avto.saveLocal();
                            zayavka.saveLocal();
                            
                          }),

                          
                          
                      title: Text('${u.lastName} ${u.firstName}(${u.username}) ',style: TextStyle(fontSize: 23)),
                      
                    ),
                ],
              )));
        });
  }
}
