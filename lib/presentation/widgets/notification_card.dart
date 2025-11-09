import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback? onMarkRead;
  
  const NotificationCard({
    Key? key,
    required this.notification,
    required this.onTap,
    this.onMarkRead,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor;
    
    switch (notification.type) {
      case 'temperature_high':
        iconData = Icons.thermostat;
        iconColor = Colors.red;
        break;
      case 'temperature_low':
        iconData = Icons.ac_unit;
        iconColor = Colors.blue;
        break;
      case 'humidity_high':
        iconData = Icons.water;
        iconColor = Colors.blue;
        break;
      case 'humidity_low':
        iconData = Icons.water_drop;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.info;
        iconColor = Colors.grey;
    }

    return Card(
      elevation: notification.isRead ? 1 : 3,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: notification.isRead ? null : Colors.blue.shade50,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.2),
          child: Icon(iconData, color: iconColor),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd MMM yyyy, HH:mm').format(notification.createdAt),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: onMarkRead != null
            ? IconButton(
                icon: const Icon(Icons.mark_email_read, color: Colors.green),
                onPressed: onMarkRead,
                tooltip: 'Tandai sudah dibaca',
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}