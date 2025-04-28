import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../checki_page.dart';
import '../../historyPage.dart';
import '../../login_page.dart';
import '../../main.dart';
import '../../my_zayavki_page.dart';
import '../../oborudovanie_page.dart';
import '../../ofis_page.dart';
import '../../settings_page.dart';

final GoRouter appRouter = GoRouter(
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