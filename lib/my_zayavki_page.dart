import 'package:flutter/material.dart';
import 'package:fluttsec/tasks_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class MyZayavkiPage extends HookConsumerWidget {
  static final routeName = "/zayavki";
  MyZayavkiPage({super.key}) {}


  
final Uri _url = Uri.parse('content://com.android.calendar/time/');
Future<void> _launchUrl() async {
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(child: TasksScreen()),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) async {
          if (value == 0) {
            _launchUrl();
          } else if (value == 1) {
            context.go('/cheki');
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_calendar_rounded),
            label: 'Календарь',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_post_office_rounded),
            label: 'Офис',
          ),
        ],
      ),
    );
  }
}
