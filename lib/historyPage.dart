import 'package:flutter/material.dart';
import 'package:fluttsec/tasks_screen_history.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class HistoryPage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/11.jpg"),
            fit: BoxFit.fill,
          ),
        ),
          child: Center(child: TasksScreenHistory()),
      ),
     bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (value) async {
          if (value == 0) {
            _launchUrl();
          } else if (value == 1) {
            context.go('/zayavki');
          }else if (value == 2) {
            context.go('/cheki');
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_calendar_rounded),
            label: 'Календарь',
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Заявки',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_post_office_rounded),
            label: 'Офис',
          )
        ],
      ),
    );
  }
  final Uri _url = Uri.parse('content://com.android.calendar/time/');
Future<void> _launchUrl() async {
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}
}

