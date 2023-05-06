import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

class NotificationsProvider {
  final messageKey = dotenv.env['MESSAGE_API_KEY'];

  Future sendPushNotification(receiver, sender, message) async {
    final body = {
      'notification': <String, dynamic>{
        'body': message,
        'title': '$sender',
      },
      'priority': 'high',
      'data': <String, dynamic>{
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'id': '1',
        'status': 'done',
      },
      'to': receiver,
    };
    try {
      final response = await post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'key=$messageKey',
        },
        body: jsonEncode(body),
      );
    } catch (e) {
      return e.toString();
    }
  }
}
