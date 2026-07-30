import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/localization/app_language_provider.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/firestore_service.dart';

class EditProfileScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onSaveChanges;
  final UserModel? initialUser;

  const EditProfileScreen({
    super.key,
    this.onBack,
    this.onSaveChanges,
    this.initialUser,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _firestoreService = FirestoreService();
  final _nameController = TextEditingController();

  String _selectedCountry = 'Rwanda';
  String _selectedField = 'Business Administration';
  String _selectedLevel = 'Undergraduate';
  bool _deadlineReminders = true;
  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> _countries = ['Rwanda', 'Kenya', 'Uganda', 'Tanzania', 'Others'];
  final List<String> _fields = ['Business Administration', 'Technology', 'Health', 'Education', 'Engineering'];
  final List<String> _levels = ['Secondary school', 'Undergraduate', 'Undergraduate (Final year)', 'Graduate', 'Job seeker'];

  @override
  void initState() {
    super.initState();
    if (widget.initialUser != null) {
      _nameController.text = widget.initialUser!.fullName;
      if (_countries.contains(widget.initialUser!.country)) _selectedCountry = widget.initialUser!.country!;
      if (_fields.contains(widget.initialUser!.fieldOfStudy)) _selectedField = widget.initialUser!.fieldOfStudy!;
      if (_levels.contains(widget.initialUser!.educationLevel)) _selectedLevel = widget.initialUser!.educationLevel!;
      _isLoading = false;
    } else {
      _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final user = await _firestoreService.getUserProfile(uid);
      if (user != null) {
        setState(() {
          _nameController.text = user.fullName;
          if (user.country != null && _countries.contains(user.country)) {
            _selectedCountry = user.country!;
          }
          if (user.fieldOfStudy != null && _fields.contains(user.fieldOfStudy)) {
            _selectedField = user.fieldOfStudy!;
          }
          if (user.educationLevel != null && _levels.contains(user.educationLevel)) {
            _selectedLevel = user.educationLevel!;
          }
          _deadlineReminders = user.deadlineReminders;
        });
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _handleSave() async {
    final firebaseUser = widget.initialUser != null ? null : FirebaseAuth.instance.currentUser;
    final uid = firebaseUser?.uid;
    if (uid == null) {
      if (widget.onSaveChanges != null) {
        widget.onSaveChanges!();
      } else {
        Navigator.pop(context, true);
      }
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _firestoreService.updateUserProfile(uid, {
        'fullName': _nameController.text.trim(),
        'country': _selectedCountry,
        'fieldOfStudy': _selectedField,
        'educationLevel': _selectedLevel,
        'deadlineReminders': _deadlineReminders,
      });

      if (mounted) {
        if (widget.onSaveChanges != null) {
          widget.onSaveChanges!();
        } else {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
            final bgClr = isDark ? const Color(0xFF121212) : AppColors.background;
            final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
            final textColor = isDark ? Colors.white : AppColors.textPrimary;
            final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;
            final borderClr = isDark ? Colors.white24 : const Color(0xFFE5E7EB);

            return Scaffold(
              backgroundColor: bgClr,
              appBar: AppBar(
                backgroundColor: bgClr,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : AppColors.primary, size: 24),
                  onPressed: widget.onBack ?? () => Navigator.pop(context, true),
                ),
                title: Text(
                  AppTranslations.tr('edit_profile'),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              body: SafeArea(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : Column(
                        children: [
                          Divider(height: 1, color: borderClr),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFieldLabel(AppTranslations.tr('full_name'), textColor),
                                  const SizedBox(height: 8),
                                  _buildTextField(_nameController, cardBg, textColor, borderClr),
                                  const SizedBox(height: 24),

                                  _buildFieldLabel('Country', textColor),
                                  const SizedBox(height: 8),
                                  _buildDropdownField(
                                    value: _selectedCountry,
                                    items: _countries,
                                    cardBg: cardBg,
                                    textColor: textColor,
                                    borderClr: borderClr,
                                    onChanged: (val) {
                                      if (val != null) setState(() => _selectedCountry = val);
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  _buildFieldLabel('Field of study', textColor),
                                  const SizedBox(height: 8),
                                  _buildDropdownField(
                                    value: _selectedField,
                                    items: _fields,
                                    cardBg: cardBg,
                                    textColor: textColor,
                                    borderClr: borderClr,
                                    onChanged: (val) {
                                      if (val != null) setState(() => _selectedField = val);
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  _buildFieldLabel('Education level', textColor),
                                  const SizedBox(height: 8),
                                  _buildDropdownField(
                                    value: _selectedLevel,
                                    items: _levels,
                                    cardBg: cardBg,
                                    textColor: textColor,
                                    borderClr: borderClr,
                                    onChanged: (val) {
                                      if (val != null) setState(() => _selectedLevel = val);
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  _buildFieldLabel('Notifications', textColor),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 60,
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: borderClr, width: 1.2),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Deadline reminders',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                            ),
                                          ),
                                        ),
                                        Switch(
                                          value: _deadlineReminders,
                                          activeThumbColor: AppColors.primary,
                                          onChanged: (val) {
                                            setState(() => _deadlineReminders = val);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Save Changes Button
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _handleSave,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                      )
                                    : Text(
                                        AppTranslations.tr('save_changes'),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
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

  Widget _buildFieldLabel(String label, Color textColor) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, Color cardBg, Color textColor, Color borderClr) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderClr, width: 1.2),
      ),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: controller,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required Color cardBg,
    required Color textColor,
    required Color borderClr,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderClr, width: 1.2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: cardBg,
          icon: Icon(Icons.arrow_drop_down_rounded, color: textColor, size: 28),
          isExpanded: true,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          onChanged: onChanged,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: TextStyle(color: textColor)),
            );
          }).toList(),
        ),
      ),
    );
  }
}
