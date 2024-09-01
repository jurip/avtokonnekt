import 'package:flutter/material.dart';

import 'package:flutter_data/flutter_data.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttsec/main.data.dart';
import 'package:fluttsec/src/models/avtomobilRemote.dart';
import 'package:fluttsec/src/models/usluga.dart';
import 'package:fluttsec/src/models/uslugaSelect.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UslugaSelectScreen extends HookConsumerWidget {
  const UslugaSelectScreen({super.key, required this.avto});

  final AvtomobilRemote avto;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(repositoryInitializerProvider).when(

        error: (error, _) => Text(error.toString()),
        loading: () => const CircularProgressIndicator(),
        data: (_) {
          final stateUslugas = ref.uslugaSelects.watchAll(remote: false);

          List<UslugaSelect> ff = List.from(stateUslugas.model);
          ff.sort((a, b) => a.prioritet!.compareTo(b.prioritet!));
          final filteredUslugas = useState(ff);
          final selectedUslusas = useState(avto.performance_service.toList());

          final searchController = useTextEditingController(text: '');
          searchController.addListener(
            () {
              filteredUslugas.value = stateUslugas.model
                  .where(
                    (UslugaSelect element) {
                      String t = element.title!.toLowerCase().replaceAll(' ', '').replaceAll(' ', '');
                      List<String> s = searchController.value.text.toLowerCase().split(' ');
                      
                      bool r = s.every((element) => t.contains(element));
                        return r;
                    }
                  )
                  .toList();
                  print('|'+searchController.value.text+'|');
                  print(filteredUslugas.value);
            },
          );
          // TODO: implement build
          return Scaffold(
              appBar: AppBar(
                title: Row(children: [ 
                  Text('Выберите услугу'),
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
                    decoration: InputDecoration(hintText: 'фильтр'),
                  ),
                  for (UslugaSelect u in filteredUslugas.value)
                    ListTile(
                      leading: Checkbox(
                          value: selectedUslusas.value.any(
                            (element) => element.code == u.code,
                          ),
                          onChanged: (value) {
                            if (selectedUslusas.value.any(
                              (element) => element.code == u.code,
                            )) {
                              selectedUslusas.value
                                  .where(
                                    (element) => element.code == u.code,
                                  )
                                  .forEach(
                                    (element) => avto.performance_service
                                        .remove(element),
                                  );
                              selectedUslusas.value = [
                                ...selectedUslusas.value
                                  ..removeWhere(
                                    (element) => element.code == u.code,
                                  )
                              ];
                            } else {
                              Usluga newu = Usluga(
                                  title: u.title,
                                  code: u.code,
                                  avtomobil: BelongsTo<AvtomobilRemote>(avto));

                              
                              newu.saveLocal();

                              selectedUslusas.value = [
                                ...selectedUslusas.value..add(newu)
                              ];
                            }
                            avto.saveLocal();
                            
                          }),
                      title: Text('${u.title}',style: TextStyle(fontSize: 23)),
                    ),
                ],
              )));
        });
  }
}
