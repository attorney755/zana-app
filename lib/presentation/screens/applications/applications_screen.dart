import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/localization/app_language_provider.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_provider.dart';
import '../../../data/models/application_model.dart';
import '../../../data/models/opportunity_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/firestore_service.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../widgets/opportunity_card.dart';

class ApplicationsScreen extends StatefulWidget {
  final Function(int navIndex)? onNavTap;
  final Function(String opportunityId)? onOpportunityTap;
  final UserModel? initialUser;
  final List<ApplicationModel>? initialApplications;
  final List<OpportunityModel>? initialSavedOpportunities;

  const ApplicationsScreen({
    super.key,
    this.onNavTap,
    this.onOpportunityTap,
    this.initialUser,
    this.initialApplications,
    this.initialSavedOpportunities,
  });

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> with SingleTickerProviderStateMixin {
  final _firestoreService = FirestoreService();
  late TabController _tabController;
  int _currentNavIndex = 2; // Applications Tab

  UserModel? _user;
  List<ApplicationModel> _applications = [];
  List<OpportunityModel> _savedOpportunities = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });

    if (widget.initialUser != null) {
      _user = widget.initialUser;
    }
    if (widget.initialApplications != null) {
      _applications = widget.initialApplications!;
    }
    if (widget.initialSavedOpportunities != null) {
      _savedOpportunities = widget.initialSavedOpportunities!;
    }

    if (widget.initialApplications == null || widget.initialSavedOpportunities == null) {
      _loadData();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String? get _currentUid {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final uid = _currentUid;
      if (uid != null) {
        final profile = await _firestoreService.getUserProfile(uid).timeout(const Duration(seconds: 3));
        final apps = await _firestoreService.getUserApplications(uid).timeout(const Duration(seconds: 3));

        // Fetch saved opportunities
        final allOpps = await _firestoreService.getOpportunities().timeout(const Duration(seconds: 3));
        final savedOpps = allOpps.where((o) => profile?.savedOpportunityIds.contains(o.id) == true).toList();

        if (mounted) {
          setState(() {
            _user = profile;
            _applications = apps;
            _savedOpportunities = savedOpps;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading applications data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleSave(String oppId) async {
    final uid = _currentUid;
    if (uid == null) return;

    await _firestoreService.toggleSaveOpportunity(uid, oppId);
    await _loadData();
  }

  List<ApplicationModel> _filterAppsByTab(int tabIndex) {
    switch (tabIndex) {
      case 0: // All
        return _applications;
      case 1: // Applied
        return _applications.where((a) => a.status == 'Applied').toList();
      case 2: // Interview (Under Review or Shortlisted)
        return _applications.where((a) => a.status == 'Under Review' || a.status == 'Shortlisted').toList();
      case 3: // Accepted
        return _applications.where((a) => a.status == 'Accepted').toList();
      default:
        return [];
    }
  }

  Widget _buildFilterChip(int index, String label, IconData icon, Color baseColor, bool isDark) {
    final isSelected = _tabController.index == index;
    final unselectedBg = isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100;
    final unselectedText = isDark ? Colors.white70 : AppColors.textSecondary;
    final unselectedBorder = isDark ? Colors.white24 : Colors.grey.shade300;

    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? baseColor.withValues(alpha: 0.2) : unselectedBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? baseColor : unselectedBorder,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? baseColor : unselectedText,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? baseColor : unselectedText,
              ),
            ),
          ],
        ),
      ),
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
            final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
            final textColor = isDark ? Colors.white : AppColors.textPrimary;
            final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;

            return Scaffold(
              backgroundColor: isDark ? const Color(0xFF121212) : AppColors.background,
              appBar: AppBar(
                backgroundColor: cardBg,
                elevation: 0.5,
                leading: Navigator.canPop(context)
                    ? IconButton(
                        icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : AppColors.primary),
                        onPressed: () => Navigator.pop(context),
                      )
                    : null,
                title: Text(
                  AppTranslations.tr('applications'),
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                    onPressed: _loadData,
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(54),
                  child: Container(
                    color: cardBg,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(0, AppTranslations.tr('category_all'), Icons.assignment_outlined, AppColors.primary, isDark),
                          _buildFilterChip(1, AppTranslations.tr('applied'), Icons.send_rounded, const Color(0xFFEA580C), isDark),
                          _buildFilterChip(2, AppTranslations.tr('shortlisted'), Icons.chat_bubble_outline_rounded, const Color(0xFF9333EA), isDark),
                          _buildFilterChip(3, AppTranslations.tr('accepted'), Icons.verified_outlined, const Color(0xFF059669), isDark),
                          _buildFilterChip(4, AppTranslations.tr('saved'), Icons.bookmark_outline_rounded, const Color(0xFFD97706), isDark),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              body: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildApplicationsList(_filterAppsByTab(0), isDark),
                        _buildApplicationsList(_filterAppsByTab(1), isDark),
                        _buildApplicationsList(_filterAppsByTab(2), isDark),
                        _buildApplicationsList(_filterAppsByTab(3), isDark),
                        _buildSavedTab(),
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

  Widget _buildApplicationsList(List<ApplicationModel> apps, bool isDark) {
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;

    if (apps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_outlined, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              'No applications found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Explore opportunities and submit applications!',
              style: TextStyle(fontSize: 14, color: subtextColor),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];
        return _buildApplicationCard(app, isDark);
      },
    );
  }

  Widget _buildApplicationCard(ApplicationModel app, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;
    final borderClr = isDark ? Colors.white24 : const Color(0xFFE5E7EB);
    final dividerClr = isDark ? Colors.white12 : const Color(0xFFE5E7EB);

    Color statusBgColor = isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEEF2FF);
    Color statusTextColor = isDark ? const Color(0xFF93C5FD) : AppColors.primary;

    if (app.status == 'Under Review' || app.status == 'Shortlisted') {
      statusBgColor = isDark ? const Color(0xFF7C2D12) : const Color(0xFFFFF7ED);
      statusTextColor = isDark ? const Color(0xFFFDBA74) : const Color(0xFFEA580C);
    } else if (app.status == 'Accepted') {
      statusBgColor = isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5);
      statusTextColor = isDark ? const Color(0xFF6EE7B7) : const Color(0xFF059669);
    } else if (app.status == 'Rejected') {
      statusBgColor = isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEF2F2);
      statusTextColor = isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderClr, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  app.opportunityTitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  app.status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            app.companyName,
            style: TextStyle(
              fontSize: 14,
              color: subtextColor,
            ),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: dividerClr),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Applied: ${_formatDate(app.appliedAt)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              TextButton(
                onPressed: () {
                  if (widget.onOpportunityTap != null) {
                    widget.onOpportunityTap!(app.opportunityId);
                  }
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'View Details',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSavedTab() {
    if (_savedOpportunities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.bookmark_outline_rounded, size: 64, color: AppColors.textMuted),
            SizedBox(height: 16),
            Text(
              'No saved opportunities',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            SizedBox(height: 8),
            Text(
              'Bookmark opportunities to view them here later.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _savedOpportunities.length,
      itemBuilder: (context, index) {
        final opp = _savedOpportunities[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: OpportunityCard(
            id: opp.id,
            category: opp.category,
            title: opp.title,
            subtitle: opp.provider,
            deadlineText: opp.deadlineFormattedText,
            isUrgent: opp.isUrgent,
            isSaved: true,
            onTap: () => widget.onOpportunityTap?.call(opp.id),
            onBookmarkTap: () => _toggleSave(opp.id),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
