import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_provider.dart';
import '../../../data/models/application_model.dart';
import '../../../data/models/opportunity_model.dart';
import '../../../data/services/firestore_service.dart';

class ApplyScreen extends StatefulWidget {
  final OpportunityModel opportunity;

  const ApplyScreen({
    super.key,
    required this.opportunity,
  });

  @override
  State<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends State<ApplyScreen> {
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

  Future<void> _handleApplication({required bool saveToSaved}) async {
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
      // 1. If saveToSaved is true, toggle save opportunity
      if (saveToSaved) {
        final profile = await _firestoreService.getUserProfile(user.uid);
        final isAlreadySaved = profile?.savedOpportunityIds.contains(widget.opportunity.id) ?? false;
        if (!isAlreadySaved) {
          await _firestoreService.toggleSaveOpportunity(user.uid, widget.opportunity.id);
        }
      }

      // 2. Submit application
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
    final now = DateTime.now();
    final daysLeft = widget.opportunity.deadline.difference(now).inDays;
    final formattedDate = DateFormat('MMMM dd, yyyy').format(widget.opportunity.deadline);

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeNotifier,
      builder: (context, themeMode, child) {
        final isDark = themeMode == ThemeMode.dark;
        final bgClr = isDark ? const Color(0xFF121212) : Colors.white;
        final cardBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB).withValues(alpha: 0.6);
        final textColor = isDark ? Colors.white : AppColors.textPrimary;
        final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;
        final inputBg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FB);
        final borderClr = isDark ? Colors.white38 : Colors.black87;

        return Scaffold(
          backgroundColor: bgClr,
          appBar: AppBar(
            backgroundColor: bgClr,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : AppColors.primary, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top Circular Graphic Badge
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEEF2FF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.upload_rounded,
                        size: 40,
                        color: isDark ? const Color(0xFF93C5FD) : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Headline Title
                    Text(
                      'Ready to apply?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),

                    // Description
                    Text(
                      'You are about to be taken to the official ${widget.opportunity.provider} application page. Make sure you have your documents ready.',
                      style: TextStyle(
                        fontSize: 14,
                        color: subtextColor,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Grey Deadline Card Container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.access_time_rounded, color: Color(0xFFDC2626), size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '${daysLeft > 0 ? daysLeft : 0} days until deadline',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFDC2626),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: subtextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // --- INTEGRATED APPLICATION FORM FIELDS ---
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cover Letter
                        Text(
                          'Cover letter',
                          style: TextStyle(
                            fontSize: 15,
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
                            fontSize: 15,
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
                            fontSize: 15,
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
                      ],
                    ),
                    const SizedBox(height: 32),

                    // --- BUTTONS ---
                    _isSubmitting
                        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                        : Column(
                            children: [
                              // Save & apply now Button (Primary Purple)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => _handleApplication(saveToSaved: true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Save & apply now',
                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Apply now (don't save) Button (Outlined)
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () => _handleApplication(saveToSaved: false),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: isDark ? const Color(0xFF93C5FD) : AppColors.primary,
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    side: BorderSide(color: isDark ? Colors.white38 : Colors.black87, width: 1.2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    "Apply now (don't save)",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF6366F1),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Subtext Footer
                              Text(
                                'You can always find this in Saved',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: subtextColor,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
