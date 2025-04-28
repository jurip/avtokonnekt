import 'package:fluttsec/src/notifications/app_notifications.dart';
import 'package:fluttsec/src/routes/app_router.dart';
import 'package:fluttsec/src/services/storage_service.dart';
import 'package:fluttsec/src/themes/app_themes.dart';
import 'package:geolocator/geolocator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

//const String site = "http://95.84.224.43:2222/";
//prod
const String site = "http://80.78.242.170:8080/";
//onst String site = "http://89.111.173.110:8080/";
//const String site = "http://193.227.240.27:8080/";
//const String site = "http://10.0.2.2:8080/";
//const String site = "http://80.78.242.102:8080/";
//test
//const String site = "http://89.111.169.163:8080/";
//

late final ValueNotifier<String> company;

late final ValueNotifier<String> user;
late final ValueNotifier<String> password;
late final ValueNotifier<String> token;
LocationPermission? permission;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initLocalStorage();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      Geolocator.openLocationSettings();
      return Future.error('Location permissions are denied');
    }
  }
  await _initMessaging();
  await _initCalendar();
  await initUserSession();

  runApp(
    ProviderScope(
      child: AppMy(),
      overrides: [configureRepositoryLocalStorage()],
    ),
  );
}

Future<void> _initCalendar() async {
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
}

Future<void> _initMessaging() async {
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
    if (message.data['tip_soobsheniya'] == 'avto_update') {
      updateAvtoFromMessageZ(message.data);
    } else {
      newZayavkaFromMessageZ(message.data);
    }
    if (kDebugMode) {
      print('Handling a foreground message: ${message.messageId}');
      print('Message data: ${message.data}');
      print('Message notification: ${message.notification?.title}');
      print('Message notification: ${message.notification?.body}');
    }

    _messageStreamController.sink.add(message);
  });
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

/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  String _lastMessage = "";
  ThemeMode _themeMode = ThemeMode.light;
  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  _MyHomePageState() {
/*

*/

    _messageStreamController.listen((message) {
      setState(() {
        if (message.data['tip_soobsheniya'] == 'avto_update') {
          updateAvtoFromMessage(widget.ref, message.data);
        } else {
          // newZayavkaFromMessageWithCalendar(widget.ref, message.data);
        }
        if (message.notification != null) {
          _lastMessage = 'Received a notification message:'
              '\nTitle=${message.notification?.title},'
              '\nBody=${message.notification?.body},'
              '\nData=${message.data}';
          //newZayavkaFromMessage(message.data);
        } else {
          _lastMessage = 'Received a data message: ${message.data}';
          //saveToPrefs(message);
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
      routerConfig: appRouter,
      themeMode: _themeMode,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme, // standard dark theme
    );
  }
}

class MyHomePage extends StatefulWidget {
  final WidgetRef ref;
  const MyHomePage({Key? key, required this.ref}) : super(key: key);
  static _MyHomePageState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyHomePageState>()!;

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
            _launchCalendar();
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
              //color: Colors.black,
            ),
            label: 'Календарь',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_business_rounded,
              //color: Colors.black,
            ),
            label: 'Заявки',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.local_post_office,
              //color: Colors.black,
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

Future<void> _launchCalendar() async {
  if (!await launchUrl(Uri.parse('content://com.android.calendar/time/'))) {
    throw Exception('Could not launch calendar');
  }
}

Future<bool> checkConnection() async {
  return true;
}

void infoToast(String s) {
  Fluttertoast.showToast(
      msg: s,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      fontSize: 16.0);
}

// TODO: Define the background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await saveToPrefs(message);

  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
    print('Message data: ${message.data}');
    print('Message notification: ${message.notification?.title}');
    print('Message notification: ${message.notification?.body}');
  }
}
