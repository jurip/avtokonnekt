

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: directives_ordering, top_level_function_literal_block, depend_on_referenced_packages

import 'package:flutter_data/flutter_data.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fluttsec/src/models/avtomobilRemote.dart';
import 'package:fluttsec/src/models/calendarEvent.dart';
import 'package:fluttsec/src/models/chekFoto.dart';
import 'package:fluttsec/src/models/chek.dart';
import 'package:fluttsec/src/models/duty.dart';
import 'package:fluttsec/src/models/foto.dart';
import 'package:fluttsec/src/models/myToken.dart';
import 'package:fluttsec/src/models/myUser.dart';
import 'package:fluttsec/src/models/oborudovanie.dart';
import 'package:fluttsec/src/models/uslugaSelect.dart';
import 'package:fluttsec/src/models/usluga.dart';
import 'package:fluttsec/src/models/zayavkaRemote.dart';

// ignore: prefer_function_declarations_over_variables
ConfigureRepositoryLocalStorage configureRepositoryLocalStorage = ({FutureFn<String>? baseDirFn, List<int>? encryptionKey, LocalStorageClearStrategy? clear}) {
  if (!kIsWeb) {
    baseDirFn ??= () => getApplicationDocumentsDirectory().then((dir) => dir.path);
  } else {
    baseDirFn ??= () => '';
  }
  
  return hiveLocalStorageProvider.overrideWith(
    (ref) => HiveLocalStorage(
      hive: ref.read(hiveProvider),
      baseDirFn: baseDirFn,
      encryptionKey: encryptionKey,
      clear: clear,
    ),
  );
};

final repositoryProviders = <String, Provider<Repository<DataModelMixin>>>{
  'avtomobilRemotes': avtomobilRemotesRepositoryProvider,
'calendarEvents': calendarEventsRepositoryProvider,
'chekFotos': chekFotosRepositoryProvider,
'cheks': cheksRepositoryProvider,
'duties': dutiesRepositoryProvider,
'fotos': fotosRepositoryProvider,
'myTokens': myTokensRepositoryProvider,
'myUsers': myUsersRepositoryProvider,
'oborudovanies': oborudovaniesRepositoryProvider,
'uslugaSelects': uslugaSelectsRepositoryProvider,
'uslugas': uslugasRepositoryProvider,
'zayavkaRemotes': zayavkaRemotesRepositoryProvider
};

final repositoryInitializerProvider =
  FutureProvider<RepositoryInitializer>((ref) async {
    DataHelpers.setInternalType<AvtomobilRemote>('avtomobilRemotes');
    DataHelpers.setInternalType<CalendarEvent>('calendarEvents');
    DataHelpers.setInternalType<ChekFoto>('chekFotos');
    DataHelpers.setInternalType<Chek>('cheks');
    DataHelpers.setInternalType<Duty>('duties');
    DataHelpers.setInternalType<Foto>('fotos');
    DataHelpers.setInternalType<MyToken>('myTokens');
    DataHelpers.setInternalType<MyUser>('myUsers');
    DataHelpers.setInternalType<Oborudovanie>('oborudovanies');
    DataHelpers.setInternalType<UslugaSelect>('uslugaSelects');
    DataHelpers.setInternalType<Usluga>('uslugas');
    DataHelpers.setInternalType<ZayavkaRemote>('zayavkaRemotes');
    final adapters = <String, RemoteAdapter>{'avtomobilRemotes': ref.watch(internalAvtomobilRemotesRemoteAdapterProvider), 'calendarEvents': ref.watch(internalCalendarEventsRemoteAdapterProvider), 'chekFotos': ref.watch(internalChekFotosRemoteAdapterProvider), 'cheks': ref.watch(internalCheksRemoteAdapterProvider), 'duties': ref.watch(internalDutiesRemoteAdapterProvider), 'fotos': ref.watch(internalFotosRemoteAdapterProvider), 'myTokens': ref.watch(internalMyTokensRemoteAdapterProvider), 'myUsers': ref.watch(internalMyUsersRemoteAdapterProvider), 'oborudovanies': ref.watch(internalOborudovaniesRemoteAdapterProvider), 'uslugaSelects': ref.watch(internalUslugaSelectsRemoteAdapterProvider), 'uslugas': ref.watch(internalUslugasRemoteAdapterProvider), 'zayavkaRemotes': ref.watch(internalZayavkaRemotesRemoteAdapterProvider)};
    final remotes = <String, bool>{'avtomobilRemotes': true, 'calendarEvents': true, 'chekFotos': true, 'cheks': true, 'duties': true, 'fotos': true, 'myTokens': true, 'myUsers': true, 'oborudovanies': true, 'uslugaSelects': true, 'uslugas': true, 'zayavkaRemotes': true};

    await ref.watch(graphNotifierProvider).initialize();

    // initialize and register
    for (final type in repositoryProviders.keys) {
      final repository = ref.read(repositoryProviders[type]!);
      repository.dispose();
      await repository.initialize(
        remote: remotes[type],
        adapters: adapters,
      );
      internalRepositories[type] = repository;
    }

    return RepositoryInitializer();
});
extension RepositoryWidgetRefX on WidgetRef {
  Repository<AvtomobilRemote> get avtomobilRemotes => watch(avtomobilRemotesRepositoryProvider)..remoteAdapter.internalWatch = watch;
  Repository<CalendarEvent> get calendarEvents => watch(calendarEventsRepositoryProvider)..remoteAdapter.internalWatch = watch;
  Repository<ChekFoto> get chekFotos => watch(chekFotosRepositoryProvider)..remoteAdapter.internalWatch = watch;
  Repository<Chek> get cheks => watch(cheksRepositoryProvider)..remoteAdapter.internalWatch = watch;
  Repository<Duty> get duties => watch(dutiesRepositoryProvider)..remoteAdapter.internalWatch = watch;
  Repository<Foto> get fotos => watch(fotosRepositoryProvider)..remoteAdapter.internalWatch = watch;
  Repository<MyToken> get myTokens => watch(myTokensRepositoryProvider)..remoteAdapter.internalWatch = watch;
  Repository<MyUser> get myUsers => watch(myUsersRepositoryProvider)..remoteAdapter.internalWatch = watch;
  Repository<Oborudovanie> get oborudovanies => watch(oborudovaniesRepositoryProvider)..remoteAdapter.internalWatch = watch;
  Repository<UslugaSelect> get uslugaSelects => watch(uslugaSelectsRepositoryProvider)..remoteAdapter.internalWatch = watch;
  Repository<Usluga> get uslugas => watch(uslugasRepositoryProvider)..remoteAdapter.internalWatch = watch;
  Repository<ZayavkaRemote> get zayavkaRemotes => watch(zayavkaRemotesRepositoryProvider)..remoteAdapter.internalWatch = watch;
}

extension RepositoryRefX on Ref {

  Repository<AvtomobilRemote> get avtomobilRemotes => watch(avtomobilRemotesRepositoryProvider)..remoteAdapter.internalWatch = watch as Watcher;
  Repository<CalendarEvent> get calendarEvents => watch(calendarEventsRepositoryProvider)..remoteAdapter.internalWatch = watch as Watcher;
  Repository<ChekFoto> get chekFotos => watch(chekFotosRepositoryProvider)..remoteAdapter.internalWatch = watch as Watcher;
  Repository<Chek> get cheks => watch(cheksRepositoryProvider)..remoteAdapter.internalWatch = watch as Watcher;
  Repository<Duty> get duties => watch(dutiesRepositoryProvider)..remoteAdapter.internalWatch = watch as Watcher;
  Repository<Foto> get fotos => watch(fotosRepositoryProvider)..remoteAdapter.internalWatch = watch as Watcher;
  Repository<MyToken> get myTokens => watch(myTokensRepositoryProvider)..remoteAdapter.internalWatch = watch as Watcher;
  Repository<MyUser> get myUsers => watch(myUsersRepositoryProvider)..remoteAdapter.internalWatch = watch as Watcher;
  Repository<Oborudovanie> get oborudovanies => watch(oborudovaniesRepositoryProvider)..remoteAdapter.internalWatch = watch as Watcher;
  Repository<UslugaSelect> get uslugaSelects => watch(uslugaSelectsRepositoryProvider)..remoteAdapter.internalWatch = watch as Watcher;
  Repository<Usluga> get uslugas => watch(uslugasRepositoryProvider)..remoteAdapter.internalWatch = watch as Watcher;
  Repository<ZayavkaRemote> get zayavkaRemotes => watch(zayavkaRemotesRepositoryProvider)..remoteAdapter.internalWatch = watch as Watcher;
}