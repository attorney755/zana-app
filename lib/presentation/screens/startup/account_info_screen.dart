import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/firestore_service.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  final _fullNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _regionController = TextEditingController();

  UserModel? _user;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final profile = await _firestoreService.getUserProfile(uid);
    if (profile != null && mounted) {
      setState(() {
        _user = profile;
        _fullNameController.text = profile.fullName;
        _companyNameController.text = profile.companyName ?? '';
        _emailController.text = profile.email;
        _regionController.text = profile.country?.isNotEmpty == true ? profile.country! : 'Rwanda / East Africa';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _companyNameController.dispose();
    _emailController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  Future<void> _saveAccountInfo() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await _firestoreService.updateUserProfile(uid, {
        'fullName': _fullNameController.text.trim(),
        'companyName': _companyNameController.text.trim(),
        'country': _regionController.text.trim(),
      });

      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account information updated successfully!'),
            backgroundColor: Color(0xFF0F4C81),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating information: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeNotifier,
      builder: (context, themeMode, child) {
        final isDark = themeMode == ThemeMode.dark;
        final bgClr = isDark ? const Color(0xFF121212) : const Color(0xFFF3F0FF); // Soft Lilac backdrop
        final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF1E1B4B);
        final subtextColor = isDark ? Colors.white70 : const Color(0xFF6B7280);
        final inputBg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8FAFC);
        final borderClr = isDark ? Colors.white24 : const Color(0xFFCBD5E1);

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
                  context.go('/startup/settings');
                }
              },
            ),
            title: Text(
              'Account Information',
              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E1B4B), fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F4C81)))
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Account Type Badge
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderClr.withValues(alpha: 0.5)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Account Type', style: TextStyle(fontSize: 12, color: subtextColor)),
                                const SizedBox(height: 4),
                                const Text('Startup Founder', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F4C81))),
                              ],
                            ),
                            const Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 28),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Form Header
                      Text('Edit Account Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 14),

                      // Full Name
                      Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 14)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _fullNameController,
                        validator: (val) => val == null || val.trim().isEmpty ? 'Please enter full name' : null,
                        decoration: _inputDeco('Full Name', inputBg, borderClr),
                      ),
                      const SizedBox(height: 18),

                      // Legal Business Name
                      Text('Legal Business Name', style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 14)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _companyNameController,
                        validator: (val) => val == null || val.trim().isEmpty ? 'Please enter business name' : null,
                        decoration: _inputDeco('Legal Business Name', inputBg, borderClr),
                      ),
                      const SizedBox(height: 18),

                      // Business Email (Disabled / Read-only)
                      Text('Business Email', style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 14)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        enabled: false,
                        decoration: _inputDeco('Business Email', isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE2E8F0), borderClr),
                      ),
                      const SizedBox(height: 18),

                      // Account Region
                      Text('Account Region', style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 14)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _regionController,
                        validator: (val) => val == null || val.trim().isEmpty ? 'Please enter region' : null,
                        decoration: _inputDeco('e.g. Rwanda / East Africa', inputBg, borderClr),
                      ),
                      const SizedBox(height: 32),

                      // Save Button
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveAccountInfo,
                          icon: const Icon(Icons.check_rounded, size: 18),
                          label: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F4C81), // Cool Teal Blue Accent
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  InputDecoration _inputDeco(String hint, Color fillClr, Color borderClr) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: fillClr,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderClr)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderClr)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF0F4C81), width: 1.8)),
    );
  }
}
