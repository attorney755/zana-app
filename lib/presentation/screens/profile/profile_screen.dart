import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/localization/app_language_provider.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/firestore_service.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  final Function(int navIndex)? onNavTap;
  final Future<void> Function()? onEditProfileTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onLogoutSuccess;
  final UserModel? initialUser;

  const ProfileScreen({
    super.key,
    this.onNavTap,
    this.onEditProfileTap,
    this.onSettingsTap,
    this.onLogoutSuccess,
    this.initialUser,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firestoreService = FirestoreService();
  int _currentNavIndex = 3;

  UserModel? _user;
  int _savedCount = 0;
  int _matchedCount = 0;

  UserModel? get _currentUser => widget.initialUser ?? _user;

  @override
  void initState() {
    super.initState();
    if (widget.initialUser != null) {
      _user = widget.initialUser;
      _savedCount = widget.initialUser!.savedOpportunityIds.length;
    }
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final authUser = FirebaseAuth.instance.currentUser;
      if (authUser != null) {
        final profile = await _firestoreService.getUserProfile(authUser.uid);
        final apps = await _firestoreService.getUserApplications(authUser.uid);
        if (mounted) {
          setState(() {
            _user = profile;
            _savedCount = profile?.savedOpportunityIds.length ?? 0;
            _matchedCount = apps.length;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppTranslations.tr('logout')),
        content: Text(AppTranslations.tr('confirm_logout')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppTranslations.tr('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppTranslations.tr('logout')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
      if (widget.onLogoutSuccess != null) {
        widget.onLogoutSuccess!();
      }
    }
  }

  String _safeFirstName(UserModel? userModel, User? authUser) {
    if (userModel != null && userModel.fullName.trim().isNotEmpty) {
      return userModel.firstName;
    }
    if (authUser?.displayName != null && authUser!.displayName!.trim().isNotEmpty) {
      return authUser.displayName!.trim().split(' ').first;
    }
    if (authUser?.email != null && authUser!.email!.trim().isNotEmpty) {
      final raw = authUser.email!.split('@').first.toLowerCase();
      if (raw.startsWith('attorney')) {
        return 'Attorney';
      }
      final formatted = raw.replaceAll(RegExp(r'[_.-]'), ' ').trim();
      final parts = formatted.split(RegExp(r'\s+'));
      if (parts.isNotEmpty) {
        final first = parts.first;
        return first[0].toUpperCase() + first.substring(1).toLowerCase();
      }
    }
    return 'Attorney';
  }

  String _safeInitials(UserModel? userModel, User? authUser) {
    if (userModel != null && userModel.fullName.trim().isNotEmpty) {
      return userModel.initials;
    }
    if (authUser?.displayName != null && authUser!.displayName!.trim().isNotEmpty) {
      final parts = authUser.displayName!.trim().split(' ').where((p) => p.isNotEmpty).toList();
      if (parts.length > 1) {
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      } else if (parts.isNotEmpty) {
        return parts.first[0].toUpperCase();
      }
    }
    final fname = _safeFirstName(userModel, authUser);
    return fname.isNotEmpty ? fname[0].toUpperCase() : 'A';
  }

  String _safeFullName(UserModel? userModel, User? authUser) {
    if (userModel != null && userModel.fullName.trim().isNotEmpty) {
      return userModel.fullName;
    }
    return _safeFirstName(userModel, authUser);
  }

  @override
  Widget build(BuildContext context) {
    final authUser = FirebaseAuth.instance.currentUser;
    final userModel = _currentUser;

    final initials = _safeInitials(userModel, authUser);
    final fullName = _safeFullName(userModel, authUser);

    final country = (userModel?.country != null && userModel!.country!.trim().isNotEmpty) ? userModel.country! : 'Rwanda';
    final field = (userModel?.fieldOfStudy != null && userModel!.fieldOfStudy!.trim().isNotEmpty) ? userModel.fieldOfStudy! : 'Business Administration';
    final level = (userModel?.educationLevel != null && userModel!.educationLevel!.trim().isNotEmpty) ? userModel.educationLevel! : 'Undergraduate';

    return ValueListenableBuilder<Locale>(
      valueListenable: appLanguageNotifier,
      builder: (context, currentLocale, child) {
        final langCode = currentLocale.languageCode;
        final validLang = ['en', 'fr', 'sw', 'rw'].contains(langCode) ? langCode : 'en';

        return ValueListenableBuilder<ThemeMode>(
          valueListenable: appThemeNotifier,
          builder: (context, themeMode, child) {
            final isDark = themeMode == ThemeMode.dark;
            final bgClr = isDark ? const Color(0xFF121212) : AppColors.background;
            final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
            final textColor = isDark ? Colors.white : AppColors.textPrimary;
            final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;
            final borderClr = isDark ? Colors.white24 : const Color(0xFFE5E7EB);
            final statBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6);

            return Scaffold(
              backgroundColor: bgClr,
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row with Avatar, Name, Language Selector, & Settings
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Avatar Badge
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E3A8A) : AppColors.primaryLight,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    initials,
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? const Color(0xFF93C5FD) : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fullName,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Kigali, $country',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: subtextColor,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        level,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: subtextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Top Right Controls: Flag Language Dropdown & Settings Gear
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Flag Language Selector Dropdown
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: cardBg,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: borderClr),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: validLang,
                                          isDense: true,
                                          dropdownColor: cardBg,
                                          icon: const Icon(Icons.language_rounded, size: 14, color: AppColors.primary),
                                          items: [
                                            DropdownMenuItem(value: 'en', child: Text('🇺🇸 EN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor))),
                                            DropdownMenuItem(value: 'fr', child: Text('🇫🇷 FR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor))),
                                            DropdownMenuItem(value: 'sw', child: Text('🇹🇿 SW', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor))),
                                            DropdownMenuItem(value: 'rw', child: Text('🇷🇼 RW', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor))),
                                          ],
                                          onChanged: (val) {
                                            if (val != null) appLanguageNotifier.setLocale(Locale(val));
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),

                                    // Settings Gear Icon
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                      icon: Icon(Icons.settings_outlined, color: textColor, size: 24),
                                      onPressed: widget.onSettingsTap ?? () => widget.onNavTap?.call(4),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),

                            // My details Section
                            Text(
                              AppTranslations.tr('my_details'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 12),

                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: borderClr, width: 1.2),
                              ),
                              child: Column(
                                children: [
                                  _buildDetailRow(Icons.school_outlined, AppTranslations.tr('field'), field, textColor, subtextColor),
                                  Divider(height: 24, color: isDark ? Colors.white12 : const Color(0xFFE5E7EB)),
                                  _buildDetailRow(Icons.location_on_outlined, AppTranslations.tr('country'), country, textColor, subtextColor),
                                  Divider(height: 24, color: isDark ? Colors.white12 : const Color(0xFFE5E7EB)),
                                  _buildDetailRow(Icons.workspace_premium_outlined, AppTranslations.tr('level'), level, textColor, subtextColor),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Starts / Stats Section
                            Text(
                              AppTranslations.tr('starts'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard('$_savedCount', AppTranslations.tr('saved'), statBg, textColor, borderClr),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard('$_matchedCount', AppTranslations.tr('matched'), statBg, textColor, borderClr),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                          ],
                        ),
                      ),
                    ),
                    CustomBottomNavBar(
                      currentIndex: _currentNavIndex,
                      onTap: (index) {
                        setState(() {
                          _currentNavIndex = index;
                        });
                        widget.onNavTap?.call(index);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color textColor, Color subtextColor) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: subtextColor),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, Color bgClr, Color textColor, Color borderClr) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: bgClr,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderClr),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: textColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
