import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_provider.dart';
import '../../../data/models/opportunity_model.dart';
import '../../../data/services/firestore_service.dart';

class OpportunityDetailScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onApplyNow;
  final VoidCallback? onNavigateToApplications;
  final OpportunityModel? opportunity;
  final String? opportunityId;

  const OpportunityDetailScreen({
    super.key,
    this.onBack,
    this.onApplyNow,
    this.onNavigateToApplications,
    this.opportunity,
    this.opportunityId,
  });

  @override
  State<OpportunityDetailScreen> createState() => _OpportunityDetailScreenState();
}

class _OpportunityDetailScreenState extends State<OpportunityDetailScreen> {
  final _firestoreService = FirestoreService();
  OpportunityModel? _opp;
  bool _isLoadingOpp = true;

  bool _isSaved = false;
  bool _hasApplied = false;
  bool _isCheckingAppliedStatus = true;

  @override
  void initState() {
    super.initState();
    _loadOpportunity();
  }

  Future<void> _loadOpportunity() async {
    if (widget.opportunity != null) {
      _opp = widget.opportunity!;
      _isLoadingOpp = false;
      _firestoreService.incrementOpportunityViews(_opp!.id);
      _checkUserStatus();
      return;
    }

    if (widget.opportunityId != null && widget.opportunityId!.isNotEmpty) {
      final fetched = await _firestoreService.getOpportunityById(widget.opportunityId!);
      if (fetched != null && mounted) {
        setState(() {
          _opp = fetched;
          _isLoadingOpp = false;
        });
        _firestoreService.incrementOpportunityViews(fetched.id);
        _checkUserStatus();
        return;
      }
    }

    if (mounted) {
      setState(() {
        _opp = OpportunityModel(
          id: widget.opportunityId ?? 'sample_opp_1',
          category: 'Scholarship',
          title: 'MasterCard Foundation Scholars Program',
          provider: 'MasterCard Foundation',
          subtitle: 'Full funding · Masters · Rwanda',
          description:
              'Full tuition, accommodation, stipend, and mentorship for African students pursuing a Masters degree at partner universities',
          eligibility: 'African students · Masters level · GPA 3.0+',
          eligibleCountries: const ['Rwanda', 'Kenya', 'Ghana', 'Uganda', 'Tanzania'],
          deadline: DateTime.now().add(const Duration(days: 12)),
          applicationUrl: 'https://mastercardfdn.org',
        );
        _isLoadingOpp = false;
      });
      _checkUserStatus();
    }
  }

  String? get _currentUid {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  Future<void> _checkUserStatus() async {
    final uid = _currentUid;
    if (_opp == null) return;
    if (uid == null) {
      if (mounted) setState(() => _isCheckingAppliedStatus = false);
      return;
    }

    final profile = await _firestoreService.getUserProfile(uid);
    final applied = await _firestoreService.hasUserApplied(uid, _opp!.id);

    if (mounted) {
      setState(() {
        _isSaved = profile?.savedOpportunityIds.contains(_opp!.id) ?? false;
        _hasApplied = applied;
        _isCheckingAppliedStatus = false;
      });
    }
  }

  Future<void> _toggleBookmark() async {
    final uid = _currentUid;
    if (uid == null || _opp == null) return;

    setState(() {
      _isSaved = !_isSaved;
    });

    await _firestoreService.toggleSaveOpportunity(uid, _opp!.id);
  }

  void _openApplyScreen() {
    if (_opp == null) return;
    context.push('/apply', extra: _opp!);
  }

  Future<void> _handleWithdraw() async {
    final uid = _currentUid;
    if (uid == null || _opp == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Withdraw Application'),
        content: Text('Are you sure you want to withdraw your application for "${_opp!.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isCheckingAppliedStatus = true;
      });

      try {
        await _firestoreService.withdrawUserApplication(
          uid: uid,
          opportunityId: _opp!.id,
          opportunityTitle: _opp!.title,
          companyName: _opp!.provider,
        );

        if (mounted) {
          context.push(
            '/withdraw-success?title=${Uri.encodeComponent(_opp!.title)}&provider=${Uri.encodeComponent(_opp!.provider)}',
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isCheckingAppliedStatus = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error withdrawing application: $e')),
          );
        }
      }
    }
  }

  Widget _buildCountryPill(String label, Color bgClr, Color textClr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgClr,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: textClr,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeNotifier,
      builder: (context, themeMode, child) {
        final isDark = themeMode == ThemeMode.dark;
        final bgClr = isDark ? const Color(0xFF121212) : Colors.white;
        final textColor = isDark ? Colors.white : AppColors.textPrimary;
        final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;
        final categoryBg = isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE);
        final categoryText = isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF);
        final deadlineBg = isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2);
        final deadlineText = isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626);
        final chipBg = isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE);
        final chipText = isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF);

        if (_isLoadingOpp || _opp == null) {
          return Scaffold(
            backgroundColor: bgClr,
            appBar: AppBar(
              backgroundColor: bgClr,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black, size: 22),
                onPressed: widget.onBack ?? () => Navigator.pop(context),
              ),
              title: Text(
                'Opportunity details',
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            ),
            body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        final opp = _opp!;
        final skills = opp.skills.isNotEmpty
            ? opp.skills
            : [
                'Leadership',
                'Research',
                'Data Analysis',
                'Communication',
                'Problem Solving',
              ];

        final countries = opp.eligibleCountries.isNotEmpty
            ? opp.eligibleCountries
            : const ['Rwanda'];

        return Scaffold(
          backgroundColor: bgClr,
          appBar: AppBar(
            backgroundColor: bgClr,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black, size: 22),
              onPressed: widget.onBack ?? () => Navigator.pop(context),
            ),
            title: Text(
              'Opportunity details',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: _isSaved ? AppColors.primary : textColor,
                ),
                onPressed: _toggleBookmark,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Pill Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: categoryBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    opp.category,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: categoryText,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Opportunity Title
                Text(
                  opp.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),

                // Provider & Subtitle Subtext
                Text(
                  'By ${opp.provider} ${opp.subtitle}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: subtextColor,
                  ),
                ),
                const SizedBox(height: 20),

                // Red Deadline Box Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: deadlineBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Deadline: ${opp.deadlineFormattedText}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: deadlineText,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
                const SizedBox(height: 20),

                // Eligibility Section
                Text(
                  'Eligibility',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  opp.eligibility,
                  style: TextStyle(
                    fontSize: 14,
                    color: subtextColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                // About Section
                Text(
                  'About',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  opp.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: subtextColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                // Countries Eligible Section
                Text(
                  'Countries eligible',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: countries.map((country) => _buildCountryPill(country, chipBg, chipText)).toList(),
                ),
                const SizedBox(height: 24),

                // Required Skills Section
                Text(
                  'Skills Required',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills.map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: chipBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF6366F1)),
                      ),
                      child: Text(
                        skill,
                        style: const TextStyle(
                          color: Color(0xFF6366F1),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // Apply / Already Applied / Closed Action Banner
                SizedBox(
                  width: double.infinity,
                  child: _isCheckingAppliedStatus
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : _opp?.isClosed == true
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFEF4444)),
                              ),
                              child: Column(
                                children: const [
                                  Icon(Icons.lock_clock_rounded, color: Color(0xFFDC2626), size: 32),
                                  SizedBox(height: 8),
                                  Text(
                                    'This opportunity is currently closed',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF991B1B)),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'The publisher has closed applications for this role. Please explore other active opportunities!',
                                    style: TextStyle(fontSize: 13, color: Color(0xFFB91C1C)),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : _hasApplied
                              ? Column(
                                  children: [
                                    // Green Already Applied Button
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: widget.onNavigateToApplications,
                                        icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                                        label: const Text(
                                          'Already Applied',
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF10B981),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 18),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // Red Outlined Withdraw Application Button
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed: _handleWithdraw,
                                        icon: const Icon(Icons.exit_to_app_rounded, color: Colors.red, size: 20),
                                        label: const Text(
                                          'Withdraw Application',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          side: BorderSide(color: isDark ? Colors.redAccent : Colors.red, width: 1.5),
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : ElevatedButton(
                                  onPressed: _openApplyScreen,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Apply now',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
