import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_provider.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/services/firestore_service.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

class NotificationsScreen extends StatefulWidget {
  final Function(int navIndex)? onNavTap;
  final List<NotificationModel>? initialNotifications;

  const NotificationsScreen({
    super.key,
    this.onNavTap,
    this.initialNotifications,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _firestoreService = FirestoreService();
  int _currentNavIndex = 0;
  List<NotificationModel>? _mockList;

  @override
  void initState() {
    super.initState();
    if (widget.initialNotifications != null) {
      _mockList = widget.initialNotifications;
    }
  }

  Future<void> _markAllAsRead(String uid) async {
    if (_mockList != null) {
      setState(() {
        _mockList = _mockList!.map((n) => NotificationModel(id: n.id, title: n.title, body: n.body, type: n.type, isRead: true, createdAt: n.createdAt)).toList();
      });
      return;
    }
    await _firestoreService.markAllNotificationsAsRead(uid);
  }

  Future<void> _deleteAllNotifications(String uid) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete All Notifications'),
        content: const Text('Are you sure you want to delete all notifications?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (_mockList != null) {
        setState(() {
          _mockList = [];
        });
        return;
      }
      await _firestoreService.deleteAllNotifications(uid);
    }
  }

  Future<void> _markAsRead(String uid, NotificationModel note) async {
    if (note.isRead) return;
    if (_mockList != null) {
      setState(() {
        _mockList = _mockList!.map((n) => n.id == note.id ? NotificationModel(id: n.id, title: n.title, body: n.body, type: n.type, isRead: true, createdAt: n.createdAt) : n).toList();
      });
      return;
    }
    await _firestoreService.markNotificationAsRead(uid, note.id);
  }

  Future<void> _deleteSingleNotification(String uid, String notifId) async {
    if (_mockList != null) {
      setState(() {
        _mockList = _mockList!.where((n) => n.id != notifId).toList();
      });
      return;
    }
    await _firestoreService.deleteNotification(uid, notifId);
  }

  void _handleNotificationNavigation(NotificationModel note) {
    final type = note.type.toLowerCase();
    final title = note.title.toLowerCase();
    final body = note.body.toLowerCase();

    if (type == 'applicant' || title.contains('applicant') || body.contains('applied')) {
      context.push('/startup/applicants');
    } else if (type == 'status_change' || type == 'application' || title.contains('status')) {
      context.push('/applications');
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'application':
        return Icons.assignment_turned_in_rounded;
      case 'status_change':
        return Icons.published_with_changes_rounded;
      case 'opportunity':
        return Icons.campaign_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'application':
        return const Color(0xFF3B82F6);
      case 'status_change':
        return const Color(0xFF8B5CF6);
      case 'opportunity':
        return const Color(0xFF10B981);
      default:
        return AppColors.primary;
    }
  }

  String? get _currentUid {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = _currentUid;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeNotifier,
      builder: (context, themeMode, child) {
        final isDark = themeMode == ThemeMode.dark;
        final bgClr = isDark ? const Color(0xFF121212) : AppColors.background;
        final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final textColor = isDark ? Colors.white : AppColors.textPrimary;
        final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;
        final borderClr = isDark ? Colors.white24 : const Color(0xFFE5E7EB);

        return StreamBuilder<List<NotificationModel>>(
          stream: (_mockList == null && uid != null) ? _firestoreService.streamUserNotifications(uid) : null,
          builder: (context, snapshot) {
            final notifications = _mockList ?? snapshot.data ?? [];
            final hasUnread = notifications.any((n) => !n.isRead);

            return Scaffold(
              backgroundColor: bgClr,
              appBar: AppBar(
                backgroundColor: cardBg,
                elevation: 0.5,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : AppColors.primary),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  'Notifications',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                actions: [
                  if (hasUnread && uid != null)
                    TextButton(
                      onPressed: () => _markAllAsRead(uid),
                      child: const Text(
                        'Mark all as read',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
              body: notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.textMuted),
                          const SizedBox(height: 16),
                          Text(
                            'No notifications',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "You're all caught up!",
                            style: TextStyle(fontSize: 14, color: subtextColor),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Top Bar with "Delete All"
                        if (uid != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => _deleteAllNotifications(uid),
                              icon: const Icon(Icons.delete_sweep_rounded, size: 18, color: Colors.red),
                              label: const Text(
                                'Delete All',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red),
                              ),
                            ),
                          ),

                        // Notification Cards List
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            itemCount: notifications.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final note = notifications[index];
                              final itemBg = note.isRead ? cardBg : (isDark ? const Color(0xFF1E3A8A) : AppColors.primaryLight.withValues(alpha: 0.5));
                              final itemBorder = note.isRead ? borderClr : AppColors.primary;

                              return GestureDetector(
                                onTap: () {
                                  if (uid != null) _markAsRead(uid, note);
                                  _handleNotificationNavigation(note);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: itemBg,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: itemBorder,
                                      width: note.isRead ? 1.2 : 1.5,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: _getTypeColor(note.type).withValues(alpha: 0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(_getTypeIcon(note.type), color: _getTypeColor(note.type), size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    note.title,
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: note.isRead ? FontWeight.w600 : FontWeight.bold,
                                                      color: textColor,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  note.timeAgo,
                                                  style: TextStyle(fontSize: 11, color: subtextColor),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              note.body,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: subtextColor,
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (uid != null)
                                        IconButton(
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.only(left: 8),
                                          icon: Icon(Icons.close_rounded, size: 18, color: subtextColor),
                                          onPressed: () => _deleteSingleNotification(uid, note.id),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
              bottomNavigationBar: CustomBottomNavBar(
                currentIndex: _currentNavIndex,
                onTap: (index) {
                  setState(() {
                    _currentNavIndex = index;
                  });
                  widget.onNavTap?.call(index);
                },
              ),
            );
          },
        );
      },
    );
  }
}
