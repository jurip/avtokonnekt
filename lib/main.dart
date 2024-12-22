import 'dart:convert';
import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluttsec/checki_page.dart';
import 'package:fluttsec/historyPage.dart';
import 'package:fluttsec/login_page.dart';
import 'package:fluttsec/my_zayavki_page.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:fluttsec/oborudovanie_page.dart';
import 'package:fluttsec/ofis_page.dart';
import 'package:fluttsec/send_zayavka_to_calendar.dart';
import 'package:fluttsec/settings_page.dart';
import 'package:fluttsec/src/models/avtomobilRemote.dart';
import 'package:fluttsec/src/models/zayavkaRemote.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttsec/main.data.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ota_update/ota_update.dart';

const String site = "http://178.140.233.205:2222/";
//const String site = "http://89.111.173.110:8080/";
//const String site = "http://193.227.240.27:8080/";
//const String site = "http://10.0.2.2:8080/";
//const String site = "http://80.78.242.102:8080/";


late final ValueNotifier<String> company;

late final ValueNotifier<String> user;
late final ValueNotifier<String> password;
late final ValueNotifier<String> token;

void main() async {



  WidgetsFlutterBinding.ensureInitialized();
  await initLocalStorage();


  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  
   FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };



  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    await setupFlutterNotifications();
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //saveToPrefs(message);
    newZayavkaFromMessageZ(message.data);
    if (kDebugMode) {
      print('Handling a foreground message: ${message.messageId}');
      print('Message data: ${message.data}');
      print('Message notification: ${message.notification?.title}');
      print('Message notification: ${message.notification?.body}');
    }

    _messageStreamController.sink.add(message);
  });

  DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
  var cs = await _deviceCalendarPlugin.retrieveCalendars();
  var cx = cs.data?.firstWhere(
    (element) => element.name == 'bpium2',
    orElse: () => Calendar(id: null),
  );
  if (cx?.id == null) {
    var r = await _deviceCalendarPlugin.createCalendar("bpium2");
    myCal = r.data;
  } else {
    myCal = cx?.id;
  }
   company = ValueNotifier(localStorage.getItem('company') ?? '');
  company.addListener(() {
    localStorage.setItem('company', company.value.toString());
  });
  user = ValueNotifier(localStorage.getItem('user') ?? '');
  user.addListener(() {
    localStorage.setItem('user', user.value.toString());
  });
  password = ValueNotifier(localStorage.getItem('password') ?? '');
  password.addListener(() {
    localStorage.setItem('password', password.value.toString());
  });
  token = ValueNotifier(localStorage.getItem('token') ?? '');
  token.addListener(() {
    localStorage.setItem('token', token.value.toString());
  });

  PackageInfo packageInfo = await PackageInfo.fromPlatform();

String? version = localStorage.getItem('version');
String newVersion = packageInfo.version;
if(version!=null){
  if(version!=newVersion){
    user.value = '';
    password.value = '';
    
  }
}
localStorage.setItem("version", newVersion);


/*
    Workmanager().initialize(
                      callbackDispatcher,
                      
                    );
*/

  runApp(
    ProviderScope(
      child: AppMy(),
      overrides: [configureRepositoryLocalStorage()],
    ),
  );
}

class AppMy extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(repositoryInitializerProvider).when(
        error: (error, _) => Text(error.toString()),
        loading: () => const CircularProgressIndicator(),
        data: (_) {
          return MyHomePage(ref: ref);
        });
  }
}

final _messageStreamController = BehaviorSubject<RemoteMessage>();
String? myCal;


Future<bool> saveToPrefs(RemoteMessage message) async {
  print("\n\n\nobject пытаемся сохранить");
  var sp = await SharedPreferences.getInstance();
  print("\n\n\nobject получили схаред");

  var ok = await sp.setString(
      "zayavka-" + message.data["id"], json.encode(message.data));
      print("\n\n\nobject сохранили");
      print(ok.toString());
  return ok;
}

late AndroidNotificationChannel channel;
bool isFlutterLocalNotificationsInitialized = false;
Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null && !kIsWeb) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          // TODO add a proper drawable resource to android, for now using
          //      one that already exists in example app.
          icon: 'launch_background',
        ),
      ),
    );
  }
}

/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  String _lastMessage = "";

  _MyHomePageState() {
/*
 
*/

    _messageStreamController.listen((message) {
      setState(() {
        if (message.notification != null) {
          _lastMessage = 'Received a notification message:'
              '\nTitle=${message.notification?.title},'
              '\nBody=${message.notification?.body},'
              '\nData=${message.data}';
          //newZayavkaFromMessage(message.data);
        } else {
          _lastMessage = 'Received a data message: ${message.data}';
          //saveToPrefs(message);
          newZayavkaFromMessageWithCalendar(widget.ref, message.data);
        }
      });
    });
  }

  // It is assumed that all messages contain a data field with the key 'type'
  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

//zhmakaem na push
  void _handleMessage(RemoteMessage message) {
    if (message.data['id'] != null) {
      //saveToPrefs(message);
      //newZayavkaFromMessage(message.data);
    }
  }

  @override
  void initState() {
    super.initState();

    // Run code required to handle interacted messages in an async function
    // as initState() must not be async
    setupInteractedMessage();
    WidgetsBinding.instance.addObserver(this);
    /*
        try {
      
      OtaUpdate()
          .execute(
        'https://disk.yandex.ru/d/j5GhirMiy5py1A/app-release.apk',
        // OPTIONAL
        //destinationFilename: 'flutter_hello_world.apk',
        //OPTIONAL, ANDROID ONLY - ABILITY TO VALIDATE CHECKSUM OF FILE:
        //sha256checksum: "d6da28451a1e15cf7a75f2c3f151befad3b80ad0bb232ab15c20897e54f21478",
      ).listen(
        (OtaEvent event) {
          setState(() => currentEvent = event);
        },
      );
  } catch (e) {
      print('Failed to make OTA update. Details: $e');
  }
  */
  }

  @override
  void dispose() {
    //don't forget to dispose of it when not needed anymore
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  late AppLifecycleState _lastState;
  
  OtaEvent? currentEvent;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed &&
        _lastState == AppLifecycleState.paused) {
      //now you know that your app went to the background and is back to the foreground
    }
    _lastState =
        state; //register the last state. When you get "paused" it means the app went to the background.
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: __router,
      theme: ThemeData(fontFamily: 'Roboto'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final WidgetRef ref;
  const MyHomePage ({ Key? key, required this.ref }): super(key: key);

  @override
  State<StatefulWidget> createState() => _MyHomePageState();
}

class RootScreen extends StatelessWidget {
  const RootScreen({super.key, required this.navigationShell});

  /// Контейнер для навигационного бара.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) async {
          if (value == 0) {
            _launchUrl();
          } else if (value == 1) {
            context.go('/zayavki');
          } else if (value == 2) {
            context.go('/ofis');
          } else if (value == 3) {
            context.go('/settings');
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.calendar_month_outlined,
              color: Colors.black,
            ),
            label: 'Календарь',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_business_rounded,
              color: Colors.black,
            ),
            label: 'Заявки',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.local_post_office,
              color: Colors.black,
            ),
            label: 'Офис',
          ),
        ],
        currentIndex: 1,
      ),
    );
  }

  // Возвращает лист элементов для нижнего навигационного бара.
  List<BottomNavigationBarItem> get _buildBottomNavBarItems => [
        const BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Заявки',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Настройки',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Офис',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.note),
          label: 'Календарь',
        ),
      ];
}

final GoRouter __router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return MyZayavkiPage();
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'zayavki',
            builder: (BuildContext context, GoRouterState state) {
              return MyZayavkiPage();
            },
          ),
          GoRoute(
            path: 'ofis',
            builder: (BuildContext context, GoRouterState state) {
              return OfisPage();
            },
          ),
          GoRoute(
            path: 'cheki',
            builder: (BuildContext context, GoRouterState state) {
              return CheckiPage();
            },
          ),
           GoRoute(
            path: 'peremeshenie',
            builder: (BuildContext context, GoRouterState state) {
              return OborudovaniePage();
            },
          ),
          GoRoute(
            path: 'settings',
            builder: (BuildContext context, GoRouterState state) {
              return SettingsPage();
            },
          ),
          GoRoute(
            path: 'history',
            builder: (BuildContext context, GoRouterState state) {
              return HistoryPage();
            },
          ),
         
          GoRoute(
            path: 'login',
            builder: (BuildContext context, GoRouterState state) {
              return LoginPage();
            },
          ),
        ],
        redirect: (context, state) {
          final bool userAutheticated = user.value != '';

          final bool onloginPage = state.fullPath == '/login';

          if (!userAutheticated && !onloginPage) {
            return '/login';
          }
          if (userAutheticated && onloginPage) {
            return '/zayavki';
          }
          //you must include this. so if condition not meet, there is no redirect
          return null;
        }),
  ],
);

final Uri _url = Uri.parse('content://com.android.calendar/time/');
Future<void> _launchUrl() async {
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}
Future<ZayavkaRemote> newZayavkaFromMessageWithCalendar(WidgetRef ref, Map data) async {

  

  ZayavkaRemote z = await newZayavkaFromMessage(data, ref);
  sendZayavkaToCalendar(ref, z, getLocation('UTC'), myCal);
  return z;
}

Future<ZayavkaRemote> newZayavkaFromMessage( Map data,WidgetRef ref) async {
  var id = data["id"];
  var nomer = data["nomer"];
  var mes = data["message"];
  var adres = data["adres"];
  var nachalo = data["nachalo"];
  var format = new DateFormat("yyyy-MM-dd HH:mm:ss");

  DateTime nachalo_date =  nachalo==null?DateTime.now():format.parse(nachalo);
  DateTime end_date_time = format.parse(data["end_date_time"]);
  var comment_address = data["comment_address"];
  var service = data["service"];
  var client = data["client"];
  var contact_name = data["contact_name"];
  var contact_number = data["contact_number"];
  var manager_name = data["manager_name"];
  var manager_number = data["manager_number"];
  var lat = data["lat"];
  var lng = data["lng"];
  var status = data['status'];
  Set<AvtomobilRemote> avs = {};
  if (data["avtomobili"] != null) {
    List avtomobili = jsonDecode(data["avtomobili"]);
    for (var i in avtomobili) {
      var a = i["nomer_avto"];
      var s = i["marka_avto"];
      var ag = i["nomerAG"];
      var aid = i["id"];
      AvtomobilRemote ar = AvtomobilRemote(
          id: aid, nomer: a, marka: s, nomerAG: ag, status: "NOVAYA");
      avs.add(ar);
      ar.saveLocal();
    }
  }

  ZayavkaRemote? z = await  ref.zayavkaRemotes.findOne(data["id"]);
  if(z ==null){
   z = ZayavkaRemote(
      id: id,
      avtomobili: avs.asHasMany,
      adres: adres,
      client: client,
      comment_address: comment_address,
      contact_name: contact_name,
      contact_number: contact_number,
      nachalo: nachalo_date,
      end_date_time: end_date_time,
      service: service,
      manager_name: manager_name,
      manager_number: manager_number,
      nomer: nomer,
      message: mes,
      lat: lat,
      lng: lng,
      status: status);

   z.saveLocal();  
  }else{
    z.status = status;
      

  }
  

  return z;
}

Future<ZayavkaRemote> newZayavkaFromMessageZ( Map data) async {
  var id = data["id"];
  var nomer = data["nomer"];
  var mes = data["message"];
  var adres = data["adres"];
  var nachalo = data["nachalo"];
  var format = new DateFormat("yyyy-MM-dd HH:mm:ss");

  DateTime nachalo_date =  nachalo==null?DateTime.now():format.parse(nachalo);
  DateTime end_date_time = format.parse(data["end_date_time"]);
  var comment_address = data["comment_address"];
  var service = data["service"];
  var client = data["client"];
  var contact_name = data["contact_name"];
  var contact_number = data["contact_number"];
  var manager_name = data["manager_name"];
  var manager_number = data["manager_number"];
  var lat = data["lat"];
  var lng = data["lng"];
  var status = data['status'];
  Set<AvtomobilRemote> avs = {};
  if (data["avtomobili"] != null) {
    List avtomobili = jsonDecode(data["avtomobili"]);
    for (var i in avtomobili) {
      var a = i["nomer_avto"];
      var s = i["marka_avto"];
      var ag = i["nomerAG"];
      var aid = i["id"];
      AvtomobilRemote ar = AvtomobilRemote(
          id: aid, nomer: a, marka: s, nomerAG: ag, status: "NOVAYA");
      avs.add(ar);
      ar.saveLocal();
    }
  }

  ZayavkaRemote? z;
 
   z = ZayavkaRemote(
      id: id,
      avtomobili: avs.asHasMany,
      adres: adres,
      client: client,
      comment_address: comment_address,
      contact_name: contact_name,
      contact_number: contact_number,
      nachalo: nachalo_date,
      end_date_time: end_date_time,
      service: service,
      manager_name: manager_name,
      manager_number: manager_number,
      nomer: nomer,
      message: mes,
      lat: lat,
      lng: lng,
      status: status);

   z.saveLocal();  
 
  

  return z;
}


Future<bool> checkConnection() async {
  return true;
  try {
    final result = await InternetAddress.lookup(site, type: InternetAddressType.any);
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      print('connected');
      return true;
    }
  } on SocketException catch (_) {
    print('not connected');
    Fluttertoast.showToast(
        msg: "Нет соединения",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
    return false;
  }
  return false;
}

const simpleTaskKey = "be.tramckrijte.workmanagerExample.simpleTask";
const rescheduledTaskKey = "be.tramckrijte.workmanagerExample.rescheduledTask";
const failedTaskKey = "be.tramckrijte.workmanagerExample.failedTask";
const simpleDelayedTask = "be.tramckrijte.workmanagerExample.simpleDelayedTask";
const simplePeriodicTask =
    "be.tramckrijte.workmanagerExample.simplePeriodicTask";
const simplePeriodic1HourTask =
    "be.tramckrijte.workmanagerExample.simplePeriodic1HourTask";

Future<bool> sendAvtomobil(
    String mytoken,
    List barcode,
    String comment,
    String date,
    List fotos,
    String marka,
    String nomer,
    String nomerAG,
    List oborudovanieFotos,
    List performance_service,
    List performance_service_dop,
    String status,
    String id,
    String zayavkaId) async {
  List<String> rfoto = [];
  List<String> roborudfoto = [];

  for (String foto in fotos) {
    var headers = {
      'Content-Type': 'image/jpeg',
      'Authorization': 'Bearer $mytoken'
    };
    var data = File(foto).readAsBytesSync();

    var dio = Dio();
    var response = await dio.request(
      '${site}rest/files?name=cat-via-direct-request.jpg',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: data,
    );

    if (response.statusCode == 201) {
      print(response.data);
      String f = response.data['fileRef'];
      rfoto.add(f);
    } else {
      return false;
    }
  }

  for (String foto in oborudovanieFotos) {
    var headers = {
      'Content-Type': 'image/jpeg',
      'Authorization': 'Bearer $mytoken'
    };
    var data = File(foto).readAsBytesSync();

    var dio = Dio();
    var response = await dio.request(
      '${site}rest/files?name=cat-via-direct-request.jpg',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: data,
    );

    if (response.statusCode == 201) {
      print(response.data);
      String f = response.data['fileRef'];
      roborudfoto.add(f);
    } else {
      return false;
    }
  }

  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };

  headers.addAll({'Authorization': 'Bearer $mytoken'});
  var jfotos = [];

  for (String f in rfoto) {
    jfotos.add({"file": f});
  }
  var joborudovanieFotos = [];
  for (String f in roborudfoto) {
    joborudovanieFotos.add({"file": f});
  }
  var jperformance_service = [];
  for (String f in performance_service) {
    jperformance_service.add({"title": f, "dop": 'N'});
  }
  for (String f in performance_service_dop) {
    jperformance_service.add({"title": f, "dop": 'Y'});
  }
  var jbarcode = [];
  for (String f in barcode) {
    jbarcode.add({"code": f});
  }

  var data = json.encode({
    "avto": {
      "id": id,
      "zayavka": {"id": "$zayavkaId"},
      "marka": "$marka",
      "nomer": "$nomer",
      "nomerAG": "$nomerAG",
      "comment": "$comment",
      "date": "$date",
      "fotos": jfotos,
      "oborudovanieFotos": joborudovanieFotos,
      "barcode": jbarcode,
      "performance_service": jperformance_service,
      "status": status
    }
  });
  var dio = Dio();
  var response = await dio.request(
    '${site}rest/services/flutterService/saveAvto',
    options: Options(
      method: 'POST',
      headers: headers,
    ),
    data: data,
  );

  if (response.statusCode == 200) {
    print(json.encode(response.data));
    if (response.data == true) return true;
  }
  return false;
}

/*
@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
    
      case rescheduledTaskKey:
        final prefs = await SharedPreferences.getInstance();
        String id = inputData!['id']!;
       
        if(!prefs.containsKey(id)){
         return false;
        }
        bool r = false;
        try {
          r = await sendAvtomobil(
              inputData!['token']!,
              inputData['barcode']!,
              inputData['comment']!,
              inputData['date']!,
              inputData['fotos'],
              inputData['marka']!,
              inputData['nomer']!,
              inputData['nomerAG']!,
              inputData['oborudovanieFotos'],
              inputData['performance_service'],
              inputData['performance_service_dop'],
              inputData['status']!,
              inputData['id']!,
              inputData['zayavkaId']!);
        } on Exception catch (e) {
          print(e);
          return false;
        }
        if (r) {
          print(r);
         
          
          
          await prefs.remove(id);
          
        }

        return r;
    }

    return true;
  });
}
*/
void infoToast(String s) {
  Fluttertoast.showToast(
      msg: s,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      fontSize: 16.0);
}

Future<bool> loadZayavkaFromPrefs(WidgetRef ref) async {
  var prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  // Do the staff
  var keys = prefs.getKeys();
  for (var key in keys) {
    if (key.startsWith("zayavka")) {
      String z = prefs.getString(key)!;
      var map = jsonDecode(z);
      newZayavkaFromMessageWithCalendar(ref, map);
      return await prefs.remove(key);
    }
  }
  return false;
}



// TODO: Define the background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  await saveToPrefs(message);
  //newZayavkaFromMessage(message.data);

  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
    print('Message data: ${message.data}');
    print('Message notification: ${message.notification?.title}');
    print('Message notification: ${message.notification?.body}');
  }
}