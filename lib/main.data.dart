

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: directives_ordering, top_level_function_literal_block, depend_on_referenced_packages

import 'package:flutter_data/flutter_data.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fluttsec/src/models/avtoFoto.dart';
import 'package:fluttsec/src/models/avtomobilRemote.dart';
import 'package:fluttsec/src/models/calendarEvent.dart';
import 'package:fluttsec/src/models/chekFoto.dart';
import 'package:fluttsec/src/models/chek.dart';
import 'package:fluttsec/src/models/currentUser.dart';
import 'package:fluttsec/src/models/duty.dart';
import 'package:fluttsec/src/models/foto.dart';
import 'package:fluttsec/src/models/myToken.dart';
import 'package:fluttsec/src/models/myUser.dart';
import 'package:fluttsec/src/models/oborudovanieFoto.dart';
import 'package:fluttsec/src/models/oborudovanie.dart';
import 'package:fluttsec/src/models/pFoto.dart';
import 'package:fluttsec/src/models/pOborudovanie.dart';
import 'package:fluttsec/src/models/peremeshenieOborudovaniya.dart';
import 'package:fluttsec/src/models/userSelect.dart';
import 'package:fluttsec/src/models/user.dart';
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
  'avtoFotos': avtoFotosRepositoryProvider,
'avtomobilRemotes': avtomobilRemotesRepositoryProvider,
'calendarEvents': calendarEventsRepositoryProvider,
'chekFotos': chekFotosRepositoryProvider,
'cheks': cheksRepositoryProvider,
'currentUsers': currentUsersRepositoryProvider,
'duties': dutiesRepositoryProvider,
'fotos': fotosRepositoryProvider,
'myTokens': myTokensRepositoryProvider,
'myUsers': myUsersRepositoryProvider,
'oborudovanieFotos': oborudovanieFotosRepositoryProvider,
'oborudovanies': oborudovaniesRepositoryProvider,
'pFotos': pFotosRepositoryProvider,
'pOborudovanies': pOborudovaniesRepositoryProvider,
'peremesheniyeOborudovaniyas': peremesheniyeOborudovaniyasRepositoryProvider,
'userSelects': userSelectsRepositoryProvider,
'users': usersRepositoryProvider,
'uslugaSelects': uslugaSelectsRepositoryProvider,
'uslugas': uslugasRepositoryProvider,
'zayavkaRemotes': zayavkaRemotesRepositoryProvider
};

final repositoryInitializerProvider =
  FutureProvider<RepositoryInitializer>((ref) async {
    DataHelpers.setInternalType<AvtoFoto>('avtoFotos');
    DataHelpers.setInternalType<AvtomobilRemote>('avtomobilRemotes');
    DataHelpers.setInternalType<CalendarEvent>('calendarEvents');
    DataHelpers.setInternalType<ChekFoto>('chekFotos');
    DataHelpers.setInternalType<Chek>('cheks');
    DataHelpers.setInternalType<CurrentUser>('currentUsers');
    DataHelpers.setInternalType<Duty>('duties');
    DataHelpers.setInternalType<Foto>('fotos');
    DataHelpers.setInternalType<MyToken>('myTokens');
    DataHelpers.setInternalType<MyUser>('myUsers');
    DataHelpers.setInternalType<OborudovanieFoto>('oborudovanieFotos');
    DataHelpers.setInternalType<Oborudovanie>('oborudovanies');
    DataHelpers.setInternalType<PFoto>('pFotos');
    DataHelpers.setInternalType<POborudovanie>('pOborudovanies');
    DataHelpers.setInternalType<PeremesheniyeOborudovaniya>('peremesheniyeOborudovaniyas');
    DataHelpers.setInternalType<UserSelect>('userSelects');
    DataHelpers.setInternalType<User>('users');
    DataHelpers.setInternalType<UslugaSelect>('uslugaSelects');
    DataHelpers.setInternalType<Usluga>('uslugas');
    DataHelpers.setInternalType<ZayavkaRemote>('zayavkaRemotes');
    final adapters = <String, RemoteAdapter>{'avtoFotos': ref.watch(internalAvtoFotosRemoteAdapterProvider), 'avtomobilRemotes': ref.watch(internalAvtomobilRemotesRemoteAdapterProvider), 'calendarEvents': ref.watch(internalCalendarEventsRemoteAdapterProvider), 'chekFotos': ref.watch(internalChekFotosRemoteAdapterProvider), 'cheks': ref.watch(internalCheksRemoteAdapterProvider), 'currentUsers': ref.watch(internalCurrentUsersRemoteAdapterProvider), 'duties': ref.watch(internalDutiesRemoteAdapterProvider), 'fotos': ref.watch(internalFotosRemoteAdapterProvider), 'myTokens': ref.watch(internalMyTokensRemoteAdapterProvider), 'myUsers': ref.watch(internalMyUsersRemoteAdapterProvider), 'oborudovanieFotos': ref.watch(internalOborudovanieFotosRemoteAdapterProvider), 'oborudovanies': ref.watch(internalOborudovaniesRemoteAdapterProvider), 'pFotos': ref.watch(internalPFotosRemoteAdapterProvider), 'pOborudovanies': ref.watch(internalPOborudovaniesRemoteAdapterProvider), 'peremesheniyeOborudovaniyas': ref.watch(internalPeremesheniyeOborudovaniyasRemoteAdapterProvider), 'userSelects': ref.watch(internalUserSelectsRemoteAdapterProvider), 'users': ref.watch(internalUsersRemoteAdapterProvider), 'uslugaSelects': ref.watch(internalUslugaSelectsRemoteAdapterProvider), 'uslugas': ref.watch(internalUslugasRemoteAdapterProvider), 'zayavkaRemotes': ref.watch(internalZayavkaRemotesRemoteAdapterProvider)};
    final remotes = <String, bool>{'avtoFotos': true, 'avtomobilRemotes': true, 'calendarEvents': true, 'chekFotos': true, 'cheks': true, 'currentUsers': true, 'duties': true, 'fotos': true, 'myTokens': true, 'myUsers': true, 'oborudovanieFotos': true, 'oborudovanies': true, 'pFotos': true, 'pOborudovanies': true, 'peremesheniyeOborudovaniyas': true, 'userSelects': true, 'users': true, 'uslugaSelects': true, 'uslugas': true, 'zayavkaRemotes': true};

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
  Repository<AvtoFoto> get avtoFotos => watch(avtoFotosRepositoryProvider)..remoteAdapter.internalWatch = watch;
  Repository<AvtomobilRemote> get avtomobilRemotes => watch(avtomobilRemotesRepositoryProvider)..remoteAdapter.internalWatch = watch;
  Repository<CalendarEvent> get calendarEvents => watch(calendarEventsRepositoryProvider)..remoteAdapter.internalWatch = watch;
  Repository<ChekFoto> get chekFotos => watch(chekFotosRepositoryProvider)..remoteAdapter.internalWatch = watch;
  Repository<Chek> get cheks => watch(cheksRepositoryProvider)..remoteAdapter.internalWatch = watch;
  Repository<CurrentUser> get currentUsers => watch(currentUsersRepositoryProvider)..remoteAdapter.internalWatch = watch;
  Repository<Duty> get duties => watch(dutiesRepositoryProvider)..remoteAdapter.internalWatch = watch;
  Repository<Foto> get fotos => watch(fotosRepositoryProvider)..remoteAdapter.internalWatch = watch;
  Repository<MyToken> get myTokens => watch(myTokensRepositoryProvider)..remoteAdapter.internalWatch = watch;
  Repository<MyUser> get myUsers => watch(myUsersRepositoryProvider)..remoteAdapter.internalWatch = watch;
  Repository<OborudovanieFoto> get oborudovanieFotos => watch(oborudovanieFotosRepositoryProvider)..remoteAdapter.internalWatch = watch;
  Repository<Oborudovanie> get oborudovanies => watch(oborudovaniesRepositoryProvider)..remoteAdapter.internalWatch = watch;
  Repository<PFoto> get pFotos => watch(pFotosRepositoryProvider)..remoteAdapter.internalWatch = watch;
  Repository<POborudovanie> get pOborudovanies => watch(pOborudovaniesRepositoryProvider)..remoteAdapter.internalWatch = watch;
  Repository<PeremesheniyeOborudovaniya> get peremesheniyeOborudovaniyas => watch(peremesheniyeOborudovaniyasRepositoryProvider)..remoteAdapter.internalWatch = watch;
  Repository<UserSelect> get userSelects => watch(userSelectsRepositoryProvider)..remoteAdapter.internalWatch = watch;
  Repository<User> get users => watch(usersRepositoryProvider)..remoteAdapter.internalWatch = watch;
  Repository<UslugaSelect> get uslugaSelects => watch(uslugaSelectsRepositoryProvider)..remoteAdapter.internalWatch = watch;
  Repository<Usluga> get uslugas => watch(uslugasRepositoryProvider)..remoteAdapter.internalWatch = watch;
  Repository<ZayavkaRemote> get zayavkaRemotes => watch(zayavkaRemotesRepositoryProvider)..remoteAdapter.internalWatch = watch;
}

extension RepositoryRefX on Ref {

  Repository<AvtoFoto> get avtoFotos => watch(avtoFotosRepositoryProvider)..remoteAdapter.internalWatch = watch as Watcher;
  Repository<AvtomobilRemote> get avtomobilRemotes => watch(avtomobilRemotesRepositoryProvider)..remoteAdapter.internalWatch = watch as Watcher;
  Repository<CalendarEvent> get calendarEvents => watch(calendarEventsRepositoryProvider)..remoteAdapter.internalWatch = watch as Watcher;
  Repository<ChekFoto> get chekFotos => watch(chekFotosRepositoryProvider)..remoteAdapter.internalWatch = watch as Watcher;
  Repository<Chek> get cheks => watch(cheksRepositoryProvider)..remoteAdapter.internalWatch = watch as Watcher;
  Repository<CurrentUser> get currentUsers => watch(currentUsersRepositoryProvider)..remoteAdapter.internalWatch = watch as Watcher;
  Repository<Duty> get duties => watch(dutiesRepositoryProvider)..remoteAdapter.internalWatch = watch as Watcher;
  Repository<Foto> get fotos => watch(fotosRepositoryProvider)..remoteAdapter.internalWatch = watch as Watcher;
  Repository<MyToken> get myTokens => watch(myTokensRepositoryProvider)..remoteAdapter.internalWatch = watch as Watcher;
  Repository<MyUser> get myUsers => watch(myUsersRepositoryProvider)..remoteAdapter.internalWatch = watch as Watcher;
  Repository<OborudovanieFoto> get oborudovanieFotos => watch(oborudovanieFotosRepositoryProvider)..remoteAdapter.internalWatch = watch as Watcher;
  Repository<Oborudovanie> get oborudovanies => watch(oborudovaniesRepositoryProvider)..remoteAdapter.internalWatch = watch as Watcher;
  Repository<PFoto> get pFotos => watch(pFotosRepositoryProvider)..remoteAdapter.internalWatch = watch as Watcher;
  Repository<POborudovanie> get pOborudovanies => watch(pOborudovaniesRepositoryProvider)..remoteAdapter.internalWatch = watch as Watcher;
  Repository<PeremesheniyeOborudovaniya> get peremesheniyeOborudovaniyas => watch(peremesheniyeOborudovaniyasRepositoryProvider)..remoteAdapter.internalWatch = watch as Watcher;
  Repository<UserSelect> get userSelects => watch(userSelectsRepositoryProvider)..remoteAdapter.internalWatch = watch as Watcher;
  Repository<User> get users => watch(usersRepositoryProvider)..remoteAdapter.internalWatch = watch as Watcher;
  Repository<UslugaSelect> get uslugaSelects => watch(uslugaSelectsRepositoryProvider)..remoteAdapter.internalWatch = watch as Watcher;
  Repository<Usluga> get uslugas => watch(uslugasRepositoryProvider)..remoteAdapter.internalWatch = watch as Watcher;
  Repository<ZayavkaRemote> get zayavkaRemotes => watch(zayavkaRemotesRepositoryProvider)..remoteAdapter.internalWatch = watch as Watcher;
}