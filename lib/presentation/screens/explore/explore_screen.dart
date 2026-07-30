import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_provider.dart';
import '../../../data/models/opportunity_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/firestore_service.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../widgets/filter_bottom_sheet.dart';
import '../../widgets/opportunity_card.dart';

class ExploreScreen extends StatefulWidget {
  final Function(int navIndex)? onNavTap;
  final Function(String opportunityId)? onOpportunityTap;
  final UserModel? initialUser;
  final List<OpportunityModel>? initialOpportunities;
  final String? initialCategoryFilter;

  const ExploreScreen({
    super.key,
    this.onNavTap,
    this.onOpportunityTap,
    this.initialUser,
    this.initialOpportunities,
    this.initialCategoryFilter,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _firestoreService = FirestoreService();
  final _searchController = TextEditingController();
  int _currentNavIndex = 1;

  UserModel? _user;
  List<OpportunityModel> _allOpportunities = [];
  bool _isLoading = false;

  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedWorkType = 'All';
  String _selectedCommitment = 'All';

  @override
  void initState() {
    super.initState();
    if (widget.initialCategoryFilter != null) {
      _selectedCategory = widget.initialCategoryFilter!;
    }
    if (widget.initialUser != null) {
      _user = widget.initialUser;
    }
    if (widget.initialOpportunities != null) {
      _allOpportunities = widget.initialOpportunities!;
    } else {
      _loadData();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
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
        final opps = await _firestoreService.getOpportunities().timeout(const Duration(seconds: 3));
        if (mounted) {
          setState(() {
            _user = profile;
            _allOpportunities = opps;
          });
        }
      } else {
        final opps = await _firestoreService.getOpportunities().timeout(const Duration(seconds: 3));
        if (mounted) {
          setState(() {
            _allOpportunities = opps;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading explore data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleBookmark(String oppId) async {
    final uid = _currentUid;
    if (uid == null) return;

    await _firestoreService.toggleSaveOpportunity(uid, oppId);
    await _loadData();
  }

  void _openFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        selectedCategory: _selectedCategory,
        selectedWorkType: _selectedWorkType,
        selectedCommitment: _selectedCommitment,
        onApplyFilters: (category, workType, commitment) {
          setState(() {
            _selectedCategory = category;
            _selectedWorkType = workType;
            _selectedCommitment = commitment;
          });
        },
      ),
    );
  }

  List<OpportunityModel> get _filteredOpportunities {
    return _allOpportunities.where((opp) {
      // 1. Search Query Filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = opp.title.toLowerCase().contains(q);
        final matchProvider = opp.provider.toLowerCase().contains(q);
        final matchCategory = opp.category.toLowerCase().contains(q);
        final matchSub = opp.subtitle.toLowerCase().contains(q);
        if (!matchTitle && !matchProvider && !matchCategory && !matchSub) {
          return false;
        }
      }

      // 2. Category Filter
      if (_selectedCategory != 'All') {
        final catLower = _selectedCategory.toLowerCase();
        final oppCatLower = opp.category.toLowerCase();
        if (oppCatLower != catLower && '${oppCatLower}s' != catLower && !oppCatLower.contains(catLower)) {
          return false;
        }
      }

      // 3. Work Type Filter
      if (_selectedWorkType != 'All') {
        final typeLower = _selectedWorkType.toLowerCase();
        if (!opp.subtitle.toLowerCase().contains(typeLower) && !opp.description.toLowerCase().contains(typeLower)) {
          return false;
        }
      }

      // 4. Commitment Filter
      if (_selectedCommitment != 'All') {
        final comLower = _selectedCommitment.toLowerCase();
        if (!opp.subtitle.toLowerCase().contains(comLower) && !opp.description.toLowerCase().contains(comLower)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  bool get _hasActiveFilters => _selectedCategory != 'All' || _selectedWorkType != 'All' || _selectedCommitment != 'All';

  void _clearAllFilters() {
    setState(() {
      _selectedCategory = 'All';
      _selectedWorkType = 'All';
      _selectedCommitment = 'All';
    });
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredOpportunities;
    final uid = _currentUid;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeNotifier,
      builder: (context, themeMode, child) {
        final isDark = themeMode == ThemeMode.dark;
        final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final textColor = isDark ? Colors.white : AppColors.textPrimary;
        final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;
        final borderClr = isDark ? Colors.white24 : const Color(0xFFE5E7EB);
        final searchBg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FB);

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
              AppTranslations.tr('explore'),
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.tune_rounded, color: AppColors.primary),
                onPressed: _openFilterBottomSheet,
              ),
            ],
          ),
          body: Column(
            children: [
              // Search Bar Container
              Container(
                color: cardBg,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: textColor),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: AppTranslations.tr('search_opportunities'),
                    hintStyle: TextStyle(color: subtextColor),
                    prefixIcon: Icon(Icons.search_rounded, color: subtextColor),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear_rounded, color: subtextColor),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: searchBg,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
              ),

              // Active Filter Chips Bar
              if (_hasActiveFilters)
                Container(
                  color: cardBg,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (_selectedCategory != 'All')
                          _buildActiveFilterChip('Category: $_selectedCategory', () {
                            setState(() => _selectedCategory = 'All');
                          }),
                        if (_selectedWorkType != 'All')
                          _buildActiveFilterChip('Work: $_selectedWorkType', () {
                            setState(() => _selectedWorkType = 'All');
                          }),
                        if (_selectedCommitment != 'All')
                          _buildActiveFilterChip('Commitment: $_selectedCommitment', () {
                            setState(() => _selectedCommitment = 'All');
                          }),
                        TextButton(
                          onPressed: _clearAllFilters,
                          child: const Text(
                            'Clear All',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Results Count
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(
                  '${results.length} opportunities found${_searchQuery.isNotEmpty ? ' for "$_searchQuery"' : ''}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: subtextColor,
                  ),
                ),
              ),

              // Opportunity List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadData,
                  color: AppColors.primary,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : results.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                const SizedBox(height: 60),
                                Center(
                                  child: Column(
                                    children: [
                                      const Icon(Icons.search_off_rounded, size: 64, color: AppColors.textMuted),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No opportunities found',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Try clearing your search or filters.',
                                        style: TextStyle(fontSize: 14, color: subtextColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              itemCount: results.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 14),
                              itemBuilder: (context, index) {
                                final opp = results[index];
                                final isSaved = _user?.savedOpportunityIds.contains(opp.id) ?? false;

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
                              },
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
  }

  Widget _buildActiveFilterChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded, size: 16, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
