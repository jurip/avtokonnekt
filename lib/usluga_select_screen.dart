import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttsec/main.data.dart';
import 'package:fluttsec/src/models/uslugaSelect.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UslugaSelectScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return
    ref.watch(repositoryInitializerProvider).when(
        error: (error, _) => Text(error.toString()),
        loading: () => const CircularProgressIndicator(),
        data: (_) {
          final stateUslugas = ref.uslugaSelects.watchAll(remote: false);
          final filteredUslugas = useState(stateUslugas.model);
          final searchController = useTextEditingController(text: '');
          searchController.addListener(
            () {
              filteredUslugas.value = stateUslugas.model
                  .where(
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
           
         
        });
  }
}
