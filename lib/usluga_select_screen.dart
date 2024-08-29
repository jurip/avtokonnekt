import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttsec/main.data.dart';
=======
import 'package:flutter_data/flutter_data.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttsec/main.data.dart';
import 'package:fluttsec/src/models/avtomobilRemote.dart';
import 'package:fluttsec/src/models/usluga.dart';
>>>>>>> 3e1287e3a4deac239124337294a683c2956743ed
import 'package:fluttsec/src/models/uslugaSelect.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UslugaSelectScreen extends HookConsumerWidget {
<<<<<<< HEAD
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return
    ref.watch(repositoryInitializerProvider).when(
=======
  const UslugaSelectScreen({super.key, required this.avto});

  final AvtomobilRemote avto;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(repositoryInitializerProvider).when(
>>>>>>> 3e1287e3a4deac239124337294a683c2956743ed
        error: (error, _) => Text(error.toString()),
        loading: () => const CircularProgressIndicator(),
        data: (_) {
          final stateUslugas = ref.uslugaSelects.watchAll(remote: false);
<<<<<<< HEAD
          final filteredUslugas = useState(stateUslugas.model);
=======
          List<UslugaSelect> ff = List.from(stateUslugas.model);
          ff.sort((a, b) => a.prioritet!.compareTo(b.prioritet!));
          final filteredUslugas = useState(ff);
          final selectedUslusas = useState(avto.performance_service.toList());
>>>>>>> 3e1287e3a4deac239124337294a683c2956743ed
          final searchController = useTextEditingController(text: '');
          searchController.addListener(
            () {
              filteredUslugas.value = stateUslugas.model
                  .where(
<<<<<<< HEAD
                    (element) =>
                        element.title!.contains(searchController.value.text),
                  )
                  .toList();
            },
          );
          // TODO: implement build
          return  Scaffold(
      appBar: AppBar(
        title: const Text('Выберите услугу'),
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
                  ElevatedButton(
                    child: Text(u.title.toString()),
                    onPressed: () {
                    
                       Navigator.pop(context, u);
                    },
                  ),
              ],
            )
            )
            );
           
         
=======
                    (UslugaSelect element) {
                      String t = element.title!.toLowerCase().replaceAll(' ', '').replaceAll(' ', '');
                      String s = searchController.value.text.toLowerCase().replaceAll(' ', '');
                      bool r = t.contains(s);
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
                title: const Text('Выберите услугу'),
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
                                  avtomobil: BelongsTo(avto));

                              avto.performance_service.add(newu);
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
>>>>>>> 3e1287e3a4deac239124337294a683c2956743ed
        });
  }
}
