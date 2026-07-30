import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_provider.dart';
import '../../../data/services/firestore_service.dart';
import '../../widgets/change_password_dialog.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onEditProfileTap;

  const SettingsScreen({
    super.key,
    this.onBack,
    this.onEditProfileTap,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _firestoreService = FirestoreService();
  bool _pushNotifications = true;
  bool _emailNotifications = true;

  void _openChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );
  }

  String? get _currentUid {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  Future<void> _openEditInterestsModal() async {
    final availableInterests = [
      'Scholarship',
      'Internship',
      'Fellowship',
      'Engineering',
      'Design',
      'Technology',
      'Business',
      'Grants',
    ];

    final uid = _currentUid;
    List<String> selectedInterests = ['Scholarship', 'Internship', 'Engineering'];
    if (uid != null) {
      final user = await _firestoreService.getUserProfile(uid);
      if (user != null) {
        selectedInterests = List<String>.from(user.interests);
      }
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Areas of Interest',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Select fields you want to see in your home feed',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 10,
                    children: availableInterests.map((interest) {
                      final isSelected = selectedInterests.contains(interest);
                      return FilterChip(
                        label: Text(interest),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: Colors.grey.shade100,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : Colors.grey.shade300,
                          ),
                        ),
                        onSelected: (val) {
                          setModalState(() {
                            if (val) {
                              selectedInterests.add(interest);
                            } else {
                              selectedInterests.remove(interest);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final uid = _currentUid;
                        if (uid != null) {
                          await _firestoreService.updateUserProfile(uid, {
                            'interests': selectedInterests,
                          });
                        }
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Areas of Interest updated! Your home feed has been updated.'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Save Interests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeNotifier,
      builder: (context, themeMode, child) {
        final isDark = themeMode == ThemeMode.dark;
        final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final textColor = isDark ? Colors.white : AppColors.textPrimary;
        final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;
        final borderClr = isDark ? Colors.white24 : const Color(0xFFE5E7EB);
        final dividerClr = isDark ? Colors.white12 : const Color(0xFFE5E7EB);

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : AppColors.background,
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            elevation: 0.5,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : AppColors.primary),
              onPressed: widget.onBack ?? () => Navigator.pop(context),
            ),
            title: Text(
              AppTranslations.tr('settings'),
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ACCOUNT SECTION
              Text(
                'Account',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: subtextColor),
              ),
              const SizedBox(height: 8),
              Material(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderClr, width: 1.2),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
                        title: Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                        subtitle: Text('Update your personal information', style: TextStyle(color: subtextColor)),
                        trailing: Icon(Icons.chevron_right_rounded, color: subtextColor),
                        onTap: widget.onEditProfileTap ?? () => Navigator.pop(context),
                      ),
                      Divider(height: 1, color: dividerClr),
                      ListTile(
                        leading: const Icon(Icons.interests_outlined, color: AppColors.primary),
                        title: Text('Areas of Interest', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                        subtitle: Text('Customize opportunities in your home feed', style: TextStyle(color: subtextColor)),
                        trailing: Icon(Icons.chevron_right_rounded, color: subtextColor),
                        onTap: _openEditInterestsModal,
                      ),
                      Divider(height: 1, color: dividerClr),
                      ListTile(
                        leading: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
                        title: Text('Security', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                        subtitle: Text('Change password, manage sessions', style: TextStyle(color: subtextColor)),
                        trailing: Icon(Icons.chevron_right_rounded, color: subtextColor),
                        onTap: _openChangePasswordDialog,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // APPEARANCE SECTION
              Text(
                'Appearance',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: subtextColor),
              ),
              const SizedBox(height: 8),
              Material(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderClr, width: 1.2),
                  ),
                  child: SwitchListTile(
                    secondary: Icon(
                      isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      isDark ? AppTranslations.tr('dark_mode') : AppTranslations.tr('light_mode'),
                      style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                    ),
                    subtitle: Text('Toggle between Light and Dark mode themes', style: TextStyle(color: subtextColor)),
                    value: isDark,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) => appThemeNotifier.toggleTheme(),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // NOTIFICATIONS SECTION
              Text(
                'Notifications',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: subtextColor),
              ),
              const SizedBox(height: 8),
              Material(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderClr, width: 1.2),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.primary),
                        title: Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                        subtitle: Text('Receive alerts about application status', style: TextStyle(color: subtextColor)),
                        value: _pushNotifications,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) => setState(() => _pushNotifications = val),
                      ),
                      Divider(height: 1, color: dividerClr),
                      SwitchListTile(
                        secondary: const Icon(Icons.mark_email_unread_outlined, color: AppColors.primary),
                        title: Text('Email Notifications', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                        subtitle: Text('Get email updates on opportunities', style: TextStyle(color: subtextColor)),
                        value: _emailNotifications,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) => setState(() => _emailNotifications = val),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // SUPPORT SECTION
              Text(
                'Support',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: subtextColor),
              ),
              const SizedBox(height: 8),
              Material(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderClr, width: 1.2),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.help_outline_rounded, color: AppColors.primary),
                        title: Text('Help & Support', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                        trailing: Icon(Icons.chevron_right_rounded, color: subtextColor),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Help & Support center is coming soon!')),
                          );
                        },
                      ),
                      Divider(height: 1, color: dividerClr),
                      ListTile(
                        leading: const Icon(Icons.feedback_outlined, color: AppColors.primary),
                        title: Text('Send Feedback', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                        trailing: Icon(Icons.chevron_right_rounded, color: subtextColor),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Feedback form is coming soon!')),
                          );
                        },
                      ),
                      Divider(height: 1, color: dividerClr),
                      ListTile(
                        leading: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                        title: Text('About', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                        subtitle: Text('Version 1.0.0', style: TextStyle(color: subtextColor)),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // LOG OUT BUTTON
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                  label: Text(
                    AppTranslations.tr('logout'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  onPressed: _confirmLogout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: isDark ? Colors.redAccent : Colors.red, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppTranslations.tr('logout'), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
        content: Text(AppTranslations.tr('confirm_logout')),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: Color(0xFF9CA3AF)),
                  ),
                  child: Text(AppTranslations.tr('cancel'), style: const TextStyle(color: Color(0xFF4B5563), fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(AppTranslations.tr('logout'), style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
      if (mounted) {
        context.go('/login');
      }
    }
  }
}
