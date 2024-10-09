import 'package:device_calendar/device_calendar.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttsec/login_page.dart';
import 'package:fluttsec/main.data.dart';
import 'package:fluttsec/src/models/calendarEvent.dart';
import 'package:fluttsec/src/models/zayavkaRemote.dart';


sendZayavkaToCalendar(WidgetRef ref,  ZayavkaRemote z, Location _currentLocation, myCal) async {
  DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
   var es =  await ref.calendarEvents.findAll(remote: false);
   var exists =es.any((element) => element.zayavka.value?.nomer == z.nomer,);
   if (!exists) {
      if (z.nachalo != null) {
        Event event = Event(myCal, title: z.nomer);

        event.end = TZDateTime.from(z.nachalo!, _currentLocation);
        event.start = TZDateTime.from(z.nachalo!, _currentLocation);

        event.description = z.message;
        event.eventId = z.id;
        Result<String>? r =
            await _deviceCalendarPlugin.createOrUpdateEvent(event);
        CalendarEvent ce =
            CalendarEvent(zayavka: BelongsTo(z), calId: r!.data!);
        ce.saveLocal();
        z.saveLocal();
      }
    }
}
