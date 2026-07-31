import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_language_provider.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/theme/app_theme_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/firestore_service.dart';
import '../../widgets/change_password_dialog.dart';

class StartupSettingsScreen extends StatefulWidget {
  const StartupSettingsScreen({super.key});

  @override
  State<StartupSettingsScreen> createState() => _StartupSettingsScreenState();
}

class _StartupSettingsScreenState extends State<StartupSettingsScreen> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();

  UserModel? _founder;
  bool _isLoading = true;
  String _accountRegion = 'Rwanda / East Africa';

  final Map<String, String> _languageMap = {
    'en': 'English (US)',
    'rw': 'Kinyarwanda',
    'fr': 'French (Français)',
    'sw': 'Swahili',
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final profile = await _firestoreService.getUserProfile(uid);
    if (mounted) {
      setState(() {
        _founder = profile;
        if (profile?.country?.isNotEmpty == true) {
          _accountRegion = profile!.country!;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppTranslations.tr('logout'), style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(AppTranslations.tr('confirm_logout')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppTranslations.tr('cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppTranslations.tr('logout'), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.signOut();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  void _openChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );
  }

  void _openLanguageSelectorModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        final currentCode = appLanguageNotifier.value.languageCode;

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppTranslations.tr('language'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._languageMap.entries.map((entry) {
                final code = entry.key;
                final name = entry.value;
                final isSelected = code == currentCode;

                return ListTile(
                  leading: Icon(
                    Icons.language_rounded,
                    color: isSelected ? const Color(0xFF0F4C81) : Colors.grey,
                  ),
                  title: Text(
                    name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? const Color(0xFF0F4C81) : const Color(0xFF1E1B4B),
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: Color(0xFF0F4C81), size: 20)
                      : null,
                  onTap: () {
                    appLanguageNotifier.setLocale(Locale(code));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${AppTranslations.tr("language")}: $name'),
                        backgroundColor: const Color(0xFF0F4C81),
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _openAccountInfoModal() {
    final fullNameController = TextEditingController(text: _founder?.fullName ?? '');
    final companyNameController = TextEditingController(text: _founder?.companyName ?? '');
    final regionController = TextEditingController(text: _accountRegion);
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppTranslations.tr('account_info'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.grey),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Account Type Readonly
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Account Type', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                          Text(AppTranslations.tr('founder_partner'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F4C81))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Business Email Readonly
                    Text(AppTranslations.tr('email_address'), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                    const SizedBox(height: 6),
                    TextFormField(
                      initialValue: _founder?.email ?? 'N/A',
                      enabled: false,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Full Name Editable
                    Text(AppTranslations.tr('full_name'), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: fullNameController,
                      decoration: InputDecoration(
                        hintText: AppTranslations.tr('full_name'),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF0F4C81), width: 1.8)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Legal Business Name Editable
                    Text('Legal Business Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: companyNameController,
                      decoration: InputDecoration(
                        hintText: 'Legal Business Name',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF0F4C81), width: 1.8)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Account Region Editable
                    Text(AppTranslations.tr('country'), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: regionController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Rwanda / East Africa',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF0F4C81), width: 1.8)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save Changes Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () async {
                                final uid = FirebaseAuth.instance.currentUser?.uid;
                                if (uid == null) return;

                                setModalState(() => isSaving = true);
                                try {
                                  await _firestoreService.updateUserProfile(uid, {
                                    'fullName': fullNameController.text.trim(),
                                    'companyName': companyNameController.text.trim(),
                                    'country': regionController.text.trim(),
                                  });

                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    _loadSettings();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(AppTranslations.tr('save_changes')),
                                        backgroundColor: const Color(0xFF0F4C81),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    setModalState(() => isSaving = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error updating details: $e')),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F4C81),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: isSaving
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(AppTranslations.tr('save_changes'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: appLanguageNotifier,
      builder: (context, locale, child) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: appThemeNotifier,
          builder: (context, themeMode, child) {
            final isDark = themeMode == ThemeMode.dark;
            final bgClr = isDark ? const Color(0xFF121212) : const Color(0xFFF3F0FF); // Soft Lilac backdrop
            final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
            final textColor = isDark ? Colors.white : const Color(0xFF1E1B4B);
            final subtextColor = isDark ? Colors.white70 : const Color(0xFF6B7280);

            return Scaffold(
              backgroundColor: bgClr,
              appBar: AppBar(
                backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : const Color(0xFF1E1B4B), size: 22),
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      context.go('/startup/profile');
                    }
                  },
                ),
                title: Text(
                  AppTranslations.tr('settings_privacy'),
                  style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E1B4B), fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
              ),
              body: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F4C81)))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section 1: Post Management
                          Text(AppTranslations.tr('opportunities_mgmt'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.post_add_rounded, color: Color(0xFF0F4C81)),
                              title: Text(AppTranslations.tr('manage_posts'), style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                              subtitle: Text(AppTranslations.tr('manage_posts_sub'), style: TextStyle(color: subtextColor, fontSize: 12)),
                              trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: subtextColor),
                              onTap: () => context.push('/startup/my-posts'),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Section 2: Account & Business Verification
                          Text(AppTranslations.tr('account_verification'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.account_box_outlined, color: Color(0xFF0F4C81)),
                                  title: Text(AppTranslations.tr('account_info'), style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                                  subtitle: Text(AppTranslations.tr('account_info_sub'), style: TextStyle(color: subtextColor, fontSize: 12)),
                                  trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: subtextColor),
                                  onTap: _openAccountInfoModal,
                                ),
                                const SizedBox(height: 4),
                                ListTile(
                                  leading: const Icon(Icons.lock_outline_rounded, color: Color(0xFF0F4C81)),
                                  title: Text(AppTranslations.tr('security_password'), style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                                  subtitle: Text(AppTranslations.tr('security_password_sub'), style: TextStyle(color: subtextColor, fontSize: 12)),
                                  trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: subtextColor),
                                  onTap: _openChangePasswordDialog,
                                ),
                                const SizedBox(height: 4),
                                ListTile(
                                  leading: const Icon(Icons.verified_user_outlined, color: Color(0xFF10B981)),
                                  title: Text(AppTranslations.tr('business_verification'), style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                                  subtitle: Text(AppTranslations.tr('verified_account'), style: const TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold)),
                                  trailing: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Section 3: Appearance & Preferences
                          Text(AppTranslations.tr('preferences'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.language_rounded, color: Color(0xFF0F4C81)),
                                  title: Text(AppTranslations.tr('language'), style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                                  subtitle: Text(_languageMap[locale.languageCode] ?? 'English (US)', style: TextStyle(color: subtextColor, fontSize: 12)),
                                  trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: subtextColor),
                                  onTap: _openLanguageSelectorModal,
                                ),
                                const SizedBox(height: 4),
                                SwitchListTile(
                                  secondary: const Icon(Icons.dark_mode_outlined, color: Color(0xFF0F4C81)),
                                  title: Text(isDark ? AppTranslations.tr('dark_mode') : AppTranslations.tr('light_mode'), style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                                  subtitle: Text(AppTranslations.tr('dark_mode_sub'), style: TextStyle(color: subtextColor, fontSize: 12)),
                                  value: isDark,
                                  onChanged: (val) {
                                    appThemeNotifier.toggleTheme();
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Section 4: Log Out Card
                          Container(
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.logout_rounded, color: Colors.red),
                              title: Text(AppTranslations.tr('logout'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                              subtitle: Text(AppTranslations.tr('logout_sub'), style: TextStyle(color: subtextColor, fontSize: 12)),
                              onTap: _handleLogout,
                            ),
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
}
