import 'package:bunyan/models/notification.dart';
import 'package:bunyan/tools/res.dart';
import 'package:bunyan/tools/webservices/base.dart';

class NotificationsWebService extends BaseWebService {

    Future<List<NotificationModel>> getNotifications() async {
      final response = (await dio.get('notifications')).data;
      List<NotificationModel> notifications = [];

      for (final notif in List.of(response['notifications']))
        notifications.add(NotificationModel.fromJson(notif));
      return notifications;
    }

    Future<bool> readNotification(int id) async {
        final response = (await dio.get('markAsRead',
            queryParameters: {'id': id})).data;

        return true;
    }
}