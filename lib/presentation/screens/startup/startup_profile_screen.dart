import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_language_provider.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/theme/app_theme_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/firestore_service.dart';
import '../../widgets/startup_bottom_nav_bar.dart';

class StartupProfileScreen extends StatefulWidget {
  final ValueChanged<int>? onNavTap;

  const StartupProfileScreen({
    super.key,
    this.onNavTap,
  });

  @override
  State<StartupProfileScreen> createState() => _StartupProfileScreenState();
}

class _StartupProfileScreenState extends State<StartupProfileScreen> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();

  UserModel? _founder;
  int _totalPosts = 0;
  int _totalApplicants = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final profile = await _firestoreService.getUserProfile(uid);
    final posts = await _firestoreService.getFounderOpportunities(uid);
    final apps = await _firestoreService.getApplicationsForFounder(uid);

    if (mounted) {
      setState(() {
        _founder = profile;
        _totalPosts = posts.length;
        _totalApplicants = apps.length;
        _isLoading = false;
      });
    }
  }

  void _showEditProfileModal() {
    final nameController = TextEditingController(text: _founder?.fullName ?? '');
    final companyController = TextEditingController(text: _founder?.companyName ?? '');
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
                        Text(AppTranslations.tr('edit_profile'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.grey),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Text(AppTranslations.tr('full_name'), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: AppTranslations.tr('full_name'),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF0F4C81), width: 1.8)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(AppTranslations.tr('legal_business_name'), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: companyController,
                      decoration: InputDecoration(
                        hintText: AppTranslations.tr('legal_business_name'),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF0F4C81), width: 1.8)),
                      ),
                    ),
                    const SizedBox(height: 24),

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
                                    'fullName': nameController.text.trim(),
                                    'companyName': companyController.text.trim(),
                                  });

                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    _loadProfileData();
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
                                      SnackBar(content: Text('Error updating profile: $e')),
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
            final bgClr = isDark ? const Color(0xFF121212) : const Color(0xFFF3F0FF);
            final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
            final textColor = isDark ? Colors.white : const Color(0xFF1E1B4B);
            final subtextColor = isDark ? Colors.white70 : const Color(0xFF6B7280);

            final startupName = _founder?.companyName?.isNotEmpty == true
                ? _founder!.companyName!
                : (_founder?.fullName.isNotEmpty == true ? _founder!.fullName : 'Startup Founder');

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
                      context.go('/startup/feed');
                    }
                  },
                ),
                title: Text(
                  AppTranslations.tr('startup_profile'),
                  style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E1B4B), fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: Icon(Icons.settings_outlined, color: isDark ? Colors.white : const Color(0xFF1E1B4B)),
                    onPressed: () => context.push('/startup/settings'),
                  ),
                ],
              ),
              body: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F4C81)))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Profile Avatar Badge
                          CircleAvatar(
                            radius: 46,
                            backgroundColor: const Color(0xFFEEF2FF),
                            child: Text(
                              _founder?.initials ?? 'ZT',
                              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF0F4C81)),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Startup Name & Verified Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                startupName,
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.verified_rounded, color: Color(0xFF3B82F6), size: 22),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Role Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              AppTranslations.tr('startup_founder'),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F4C81),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Compact Edit Profile Button (Cool Teal Accent)
                          ElevatedButton.icon(
                            onPressed: _showEditProfileModal,
                            icon: const Icon(Icons.edit_outlined, size: 16),
                            label: Text(AppTranslations.tr('edit_profile'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F4C81),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 0,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Stats Card Row
                          Container(
                            padding: const EdgeInsets.all(20),
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(AppTranslations.tr('total_posts'), '$_totalPosts', Icons.post_add_rounded, textColor, subtextColor),
                                _buildStatItem(AppTranslations.tr('total_applicants'), '$_totalApplicants', Icons.people_rounded, textColor, subtextColor),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Account Info List Card
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                                _buildInfoTile(Icons.person_outline_rounded, AppTranslations.tr('full_name'), _founder?.fullName ?? 'N/A', textColor, subtextColor),
                                const SizedBox(height: 16),
                                _buildInfoTile(Icons.business_rounded, AppTranslations.tr('legal_business_name'), _founder?.companyName ?? 'N/A', textColor, subtextColor),
                                const SizedBox(height: 16),
                                _buildInfoTile(Icons.email_outlined, AppTranslations.tr('business_email'), _founder?.email ?? 'N/A', textColor, subtextColor),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
              bottomNavigationBar: StartupBottomNavBar(
                currentIndex: 3,
                onTap: widget.onNavTap ?? (index) {},
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color textColor, Color subtextColor) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF0F4C81), size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: subtextColor),
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value, Color textColor, Color subtextColor) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0F4C81)),
        const SizedBox(width: 14),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: subtextColor),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
        ),
      ],
    );
  }
}
