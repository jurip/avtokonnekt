import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluttsec/checki_page.dart';
import 'package:fluttsec/login_page.dart';
import 'package:fluttsec/my_zayavki_page.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttsec/main.data.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:localstorage/localstorage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rxdart/rxdart.dart';

//const String site = "http://95.84.221.108:2222/";
const String site = "http://89.111.173.110:8080/";
late final ValueNotifier<String> user;
late final ValueNotifier<String> password;
late final ValueNotifier<String> token;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initLocalStorage();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    await setupFlutterNotifications();
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
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
      child: MyHomePage(),
      overrides: [configureRepositoryLocalStorage()],
    ),
  );
}

final _messageStreamController = BehaviorSubject<RemoteMessage>();
String? myCal;

// TODO: Define the background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
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

class _MyHomePageState extends State<MyHomePage> {
  String _lastMessage = "";

  _MyHomePageState() {
    _messageStreamController.listen((message) {
      setState(() {
        if (message.notification != null) {
          _lastMessage = 'Received a notification message:'
              '\nTitle=${message.notification?.title},'
              '\nBody=${message.notification?.body},'
              '\nData=${message.data}';
        } else {
          _lastMessage = 'Received a data message: ${message.data}';
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: __router,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyHomePageState();
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
            path: 'cheki',
            builder: (BuildContext context, GoRouterState state) {
              return CheckiPage();
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
