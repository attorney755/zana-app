import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/localization/app_language_provider.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_provider.dart';
import '../../../data/models/opportunity_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/firestore_service.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../widgets/filter_bottom_sheet.dart';
import '../../widgets/opportunity_card.dart';

class HomeScreen extends StatefulWidget {
  final Function(int navIndex)? onNavTap;
  final VoidCallback? onNotificationTap;
  final Function(String opportunityId)? onOpportunityTap;
  final Function(String category)? onCategoryTap;
  final UserModel? initialUser;
  final int? initialUnreadCount;

  const HomeScreen({
    super.key,
    this.onNavTap,
    this.onNotificationTap,
    this.onOpportunityTap,
    this.onCategoryTap,
    this.initialUser,
    this.initialUnreadCount,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  int _currentNavIndex = 0;

  UserModel? _user;
  List<OpportunityModel> _allOpportunities = [];
  bool _isLoading = true;

  UserModel? get _currentUser => widget.initialUser ?? _user;

  String? get _currentUid {
    if (widget.initialUser != null) return widget.initialUser!.uid;
    return FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialUser != null) {
      _user = widget.initialUser;
    }
    _loadData();
  }

  Future<void> _loadData() async {
    final uid = _currentUid;
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final opps = await _firestoreService.getOpportunities();
      UserModel? profile = _user;
      if (uid != null) {
        profile = await _firestoreService.getUserProfile(uid);
      }

      if (mounted) {
        setState(() {
          _allOpportunities = opps;
          if (profile != null) _user = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<OpportunityModel> get _matchingOpportunities {
    final user = _currentUser;
    if (user != null && user.interests.isNotEmpty) {
      final userInterests = user.interests.map((i) => i.trim().toLowerCase()).toList();

      final matches = _allOpportunities.where((opp) {
        final category = opp.category.trim().toLowerCase();
        return userInterests.any((interest) =>
            category == interest ||
            category.contains(interest) ||
            interest.contains(category));
      }).toList();

      return matches;
    }

    if (user != null && user.interests.isEmpty) {
      return [];
    }

    return _allOpportunities;
  }

  Future<void> _toggleBookmark(String oppId) async {
    final uid = _currentUid;
    if (uid == null) return;

    final user = _currentUser;
    if (user == null) return;

    final isSaved = user.savedOpportunityIds.contains(oppId);
    final updatedList = List<String>.from(user.savedOpportunityIds);
    if (isSaved) {
      updatedList.remove(oppId);
    } else {
      updatedList.add(oppId);
    }

    setState(() {
      _user = user.copyWith(savedOpportunityIds: updatedList);
    });

    try {
      await _firestoreService.toggleSaveOpportunity(uid, oppId);
    } catch (_) {
      setState(() {
        _user = user;
      });
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

  String get _activeFirstName => _safeFirstName(_currentUser, FirebaseAuth.instance.currentUser);
  String get _activeInitials => _safeInitials(_currentUser, FirebaseAuth.instance.currentUser);

  void _openFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        onApplyFilters: (category, workType, commitment) {
          if (widget.onCategoryTap != null) {
            widget.onCategoryTap!(category);
          } else {
            widget.onNavTap?.call(1);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = _currentUid;
    final firstName = _activeFirstName;
    final initials = _activeInitials;
    final displayedOpportunities = _matchingOpportunities;

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

            final headerBg = isDark ? const Color(0xFF1E1B4B) : AppColors.primary;
            final searchBg = isDark ? const Color(0xFF2E2A68) : Colors.white;

            return Scaffold(
              backgroundColor: bgClr,
              body: Column(
                children: [
                  // Top Header Container
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: headerBg,
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 36, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row: Greeting Title (Left) & Action Icons (Right) on exact same horizontal axis!
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                '${AppTranslations.tr('hello')}, $firstName 👋',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Notification Bell with Badge Count
                                StreamBuilder<int>(
                                  stream: widget.initialUnreadCount != null
                                      ? Stream.value(widget.initialUnreadCount!)
                                      : (uid != null ? _firestoreService.streamUnreadNotificationCount(uid) : Stream.value(0)),
                                  builder: (context, countSnap) {
                                    final unreadCount = countSnap.data ?? 0;

                                    return Stack(
                                      clipBehavior: Clip.none,
                                      alignment: Alignment.center,
                                      children: [
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                                          icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 26),
                                          onPressed: widget.onNotificationTap,
                                        ),
                                        if (unreadCount > 0)
                                          Positioned(
                                            right: 2,
                                            top: 2,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                                              child: Text(
                                                unreadCount > 9 ? '9+' : '$unreadCount',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),

                                // Far Right: Profile Avatar (Circular, User Initials)
                                GestureDetector(
                                  onTap: () => widget.onNavTap?.call(3), // Navigate to Profile
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.25),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: Center(
                                      child: Text(
                                        initials,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppTranslations.tr('find_ways'),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Search Bar Box
                        Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: searchBg,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            children: [
                              Icon(Icons.search_rounded, color: isDark ? Colors.white70 : AppColors.textSecondary, size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => widget.onNavTap?.call(1), // Navigate to Explore
                                  child: Text(
                                    AppTranslations.tr('search_opportunities'),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.tune_rounded, color: isDark ? const Color(0xFFA5B4FC) : AppColors.primary, size: 22),
                                onPressed: _openFilterBottomSheet,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Scrollable Feed Body
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadData,
                      color: AppColors.primary,
                      child: _isLoading
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 80),
                                child: CircularProgressIndicator(color: AppColors.primary),
                              ),
                            )
                          : ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              children: [
                                // --- BROWSE BY CATEGORY SECTION ---
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    AppTranslations.tr('browse_category'),
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Horizontal Scroll of Category Buttons
                                SizedBox(
                                  height: 42,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    children: [
                                      _buildCategoryChip(Icons.school_rounded, 'Scholarship', isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2FF), isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5)),
                                      _buildCategoryChip(Icons.work_outline_rounded, 'Internship', isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5), isDark ? const Color(0xFF34D399) : const Color(0xFF059669)),
                                      _buildCategoryChip(Icons.star_outline_rounded, 'Fellowship', isDark ? const Color(0xFF78350F) : const Color(0xFFFFF7ED), isDark ? const Color(0xFFFBBF24) : const Color(0xFFEA580C)),
                                      _buildCategoryChip(Icons.code_rounded, 'Engineering', isDark ? const Color(0xFF581C87) : const Color(0xFFF3E8FF), isDark ? const Color(0xFFC084FC) : const Color(0xFF7C3AED)),
                                      _buildCategoryChip(Icons.palette_outlined, 'Design', isDark ? const Color(0xFF831843) : const Color(0xFFFCE7F3), isDark ? const Color(0xFFF472B6) : const Color(0xFFDB2777)),
                                      _buildCategoryChip(Icons.lightbulb_outline_rounded, 'Grants', isDark ? const Color(0xFF7C2D12) : const Color(0xFFFEF3C7), isDark ? const Color(0xFFFDBA74) : const Color(0xFFD97706)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // --- RECENT OPPORTUNITIES MATCHING YOUR INTEREST ---
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          AppTranslations.tr('recent_matching'),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () => widget.onNavTap?.call(1),
                                        child: Text(
                                          AppTranslations.tr('see_all'),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? const Color(0xFF818CF8) : AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Vertical List of Opportunity Cards OR Empty State
                                if (displayedOpportunities.isEmpty)
                                  Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    padding: const EdgeInsets.all(28),
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: borderClr, width: 1.2),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2FF),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.search_off_rounded,
                                            size: 30,
                                            color: isDark ? const Color(0xFF818CF8) : AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          AppTranslations.tr('no_matching_title'),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          AppTranslations.tr('no_matching_subtitle'),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: subtextColor,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Column(
                                      children: displayedOpportunities.map((opp) {
                                        final isSaved = _currentUser?.savedOpportunityIds.contains(opp.id) ?? false;
                                        return OpportunityCard(
                                          id: opp.id,
                                          category: opp.category,
                                          title: opp.title,
                                          subtitle: opp.subtitle,
                                          deadlineText: opp.deadlineFormattedText,
                                          isUrgent: opp.isUrgent,
                                          isSaved: isSaved,
                                          onTap: () => widget.onOpportunityTap?.call(opp.id),
                                          onBookmarkTap: () => _toggleBookmark(opp.id),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                              ],
                            ),
                    ),
                  ),
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

  Widget _buildCategoryChip(IconData icon, String label, Color bgColor, Color iconColor) {
    return GestureDetector(
      onTap: () {
        if (widget.onCategoryTap != null) {
          widget.onCategoryTap!(label);
        } else {
          widget.onNavTap?.call(1); // Go to Explore
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: iconColor.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: iconColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
