import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_provider.dart';
import '../../data/models/application_model.dart';
import '../../data/models/opportunity_model.dart';
import '../../data/services/firestore_service.dart';

class ApplicationFormBottomSheet extends StatefulWidget {
  final OpportunityModel opportunity;
  final VoidCallback onSuccess;

  const ApplicationFormBottomSheet({
    super.key,
    required this.opportunity,
    required this.onSuccess,
  });

  @override
  State<ApplicationFormBottomSheet> createState() => _ApplicationFormBottomSheetState();
}

class _ApplicationFormBottomSheetState extends State<ApplicationFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _coverLetterController = TextEditingController();
  final _portfolioController = TextEditingController();
  final _firestoreService = FirestoreService();

  String _availability = 'Immediate';
  bool _isSubmitting = false;

  final List<String> _availabilityOptions = [
    'Immediate',
    'Within 2 weeks',
    'Within 1 month',
  ];

  @override
  void dispose() {
    _coverLetterController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to submit an application.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final application = ApplicationModel(
        id: '',
        opportunityId: widget.opportunity.id,
        opportunityTitle: widget.opportunity.title,
        companyName: widget.opportunity.provider,
        applicantUid: user.uid,
        coverLetter: _coverLetterController.text.trim(),
        availability: _availability,
        portfolioUrl: _portfolioController.text.trim().isEmpty ? null : _portfolioController.text.trim(),
        status: 'Applied',
      );

      await _firestoreService.submitApplication(application);

      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
        context.push(
          '/application-success?title=${Uri.encodeComponent(widget.opportunity.title)}&provider=${Uri.encodeComponent(widget.opportunity.provider)}',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting application: $e')),
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
        final sheetBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final textColor = isDark ? Colors.white : AppColors.textPrimary;
        final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;
        final inputBg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FB);
        final borderClr = isDark ? Colors.white38 : Colors.black87;

        return Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white30 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title & Subtitle
                  Text(
                    'Apply for this role',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.opportunity.title} · ${widget.opportunity.provider}',
                    style: TextStyle(
                      fontSize: 14,
                      color: subtextColor,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Cover Letter
                  Text(
                    'Cover letter',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _coverLetterController,
                    maxLines: 4,
                    style: TextStyle(color: textColor, fontSize: 14),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Please enter why you want this role';
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Why do you want this role?',
                      hintStyle: TextStyle(color: isDark ? Colors.white38 : AppColors.textMuted, fontSize: 14),
                      filled: true,
                      fillColor: inputBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: borderClr, width: 1.2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: borderClr, width: 1.2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Availability Chips
                  Text(
                    'When can you start?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availabilityOptions.map((opt) {
                      final isSelected = _availability == opt;
                      return ChoiceChip(
                        label: Text(opt),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => _availability = opt);
                        },
                        selectedColor: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEEF2FF),
                        backgroundColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF3F4F6),
                        labelStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? (isDark ? const Color(0xFF93C5FD) : AppColors.primary) : subtextColor,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            width: 1.2,
                          ),
                        ),
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Portfolio / GitHub Link
                  Text(
                    'Portfolio / GitHub link (optional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _portfolioController,
                    keyboardType: TextInputType.url,
                    style: TextStyle(color: textColor, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'https://github.com/yourusername',
                      hintStyle: TextStyle(color: isDark ? Colors.white38 : AppColors.textMuted, fontSize: 14),
                      filled: true,
                      fillColor: inputBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: borderClr, width: 1.2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: borderClr, width: 1.2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Submit Application Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text(
                              'Submit Application',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}