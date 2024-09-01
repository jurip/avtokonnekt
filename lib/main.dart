import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluttsec/checki_page.dart';
import 'package:fluttsec/cheki_screen.dart';
import 'package:fluttsec/login_page.dart';
import 'package:fluttsec/my_zayavki_page.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:fluttsec/send_zayavka_to_calendar.dart';
import 'package:fluttsec/settings_page.dart';
import 'package:fluttsec/settings_screen.dart';
import 'package:fluttsec/src/models/avtomobilRemote.dart';
import 'package:fluttsec/src/models/zayavkaRemote.dart';
import 'package:fluttsec/tasks_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttsec/main.data.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uuid/uuid.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rxdart/rxdart.dart';

const String site = "http://5.228.73.174:2222/";
//const String site = "http://89.111.173.110:8080/";

late final ValueNotifier<String> user;
late final ValueNotifier<String> password;
late final ValueNotifier<String> token;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initLocalStorage();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging messaging = FirebaseMessaging.instance;

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
    //newZayavkaFromMessage(message);
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
  var cx = cs.data!.firstWhere(
    (element) => element.name == 'bpium2',
    orElse: () => Calendar(id: null),
  );
  if (cx.id == null) {
    var r = await _deviceCalendarPlugin.createCalendar("bpium2");
    myCal = r.data;
  } else {
    myCal = cx.id;
  }

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

  runApp(
    ProviderScope(
      child: AppMy(),
      overrides: [configureRepositoryLocalStorage()],
    ),
  );
}
class AppMy extends HookConsumerWidget{
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(repositoryInitializerProvider).when(
        error: (error, _) => Text(error.toString()),
        loading: () => const CircularProgressIndicator(),
        data: (_) {
          return MyHomePage();
        });
  }
  
}

final _messageStreamController = BehaviorSubject<RemoteMessage>();
String? myCal;

// TODO: Define the background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  //newZayavkaFromMessage(message);
  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
    print('Message data: ${message.data}');
    print('Message notification: ${message.notification?.title}');
    print('Message notification: ${message.notification?.body}');
  }
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
    _messageStreamController.listen((message) {
      setState(() {
        if (message.notification != null) {
          _lastMessage = 'Received a notification message:'
              '\nTitle=${message.notification?.title},'
              '\nBody=${message.notification?.body},'
              '\nData=${message.data}';
              newZayavkaFromMessage(message);
        } else {
          _lastMessage = 'Received a data message: ${message.data}';
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

  void _handleMessage(RemoteMessage message) {
    if (message.data['id'] != null) {
      newZayavkaFromMessage(message);
     
    }
  }

  @override
  void initState() {
    super.initState();

    // Run code required to handle interacted messages in an async function
    // as initState() must not be async
    setupInteractedMessage();
     WidgetsBinding.instance.addObserver(this);
  }
   @override
  void dispose() {
    //don't forget to dispose of it when not needed anymore
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
   late AppLifecycleState _lastState;    
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed && _lastState == AppLifecycleState.paused) {
      //now you know that your app went to the background and is back to the foreground
      
    }
    _lastState = state; //register the last state. When you get "paused" it means the app went to the background.
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
      bottomNavigationBar: 
      BottomNavigationBar(
        onTap: (value) async {
          if (value == 0) {
            _launchUrl();
          } else if (value == 1) {
            context.go('/zayavki');
          }else if (value == 2) {
            context.go('/cheki');
          }else if (value == 3) {
            context.go('/settings');
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined, color: Colors.black,),
            label: 'Календарь',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_business_rounded,color: Colors.black,),
            label: 'Заявки',
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.local_post_office, color: Colors.black,),
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



final router = GoRouter(
  initialLocation: '/zayavki',
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
        },
  
  routes: <RouteBase>[
    
    // BottomNavigationBar
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          RootScreen(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/zayavki',
              builder: (context, state) => TasksScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => SettingsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/cheki',
              builder: (context, state) => ChekiScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
            path: '/login',
            builder: (BuildContext context, GoRouterState state) {
              return LoginPage();
            },
          ),
  ],
  
);



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
            path: 'cheki',
            builder: (BuildContext context, GoRouterState state) {
              return CheckiPage();
            },
          ),
          GoRoute(
            path: 'settings',
            builder: (BuildContext context, GoRouterState state) {
              return SettingsPage();
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
            return '/';
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

void newZayavkaFromMessage(RemoteMessage message) {
  var id = message.data["id"];
  var nomer = message.data["nomer"];
  var mes = message.data["message"];
  var adres = message.data["adres"];
  var nachalo = message.data["nachalo"];
  var format = new DateFormat("yyyy-MM-dd hh:mm:ss");
  DateTime nachalo_date = format.parse(nachalo);
  DateTime end_date_time = format.parse(message.data["end_date_time"]);
  var comment_address = message.data["comment_address"];
  var service = message.data["service"];
  var client = message.data["client"];
  var contact_name = message.data["contact_name"];
  var contact_number = message.data["contact_number"];
  var manager_name = message.data["manager_name"];
  var manager_number = message.data["manager_number"];
  var lat = message.data["lat"];
  var lng = message.data["lng"];
  Set<AvtomobilRemote> avs ={};
  if(message.data["avtomobili"]!=null){
  List avtomobili = jsonDecode(message.data["avtomobili"]);
  for(var i in avtomobili){
    var a = i["nomer_avto"];
    var s =i["marka_avto"];
    var ag = i["nomerAG"];
    var aid = i["id"];
   AvtomobilRemote ar = AvtomobilRemote(id:aid, nomer: a,marka: s,nomerAG: ag, status: "NOVAYA");
    avs.add(ar);
    ar.saveLocal();
  }
  }
  ZayavkaRemote z = ZayavkaRemote(id:id,
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
      lng: lng);
  

  z.saveLocal();


  sendZayavkaToCalendar(z, getLocation('UTC'), myCal);
}

Future<bool> checkConnection() async {
  try {
    final result = await InternetAddress.lookup('example.com');
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
