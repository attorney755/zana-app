import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/opportunity_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/firestore_service.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

class SavedScreen extends StatefulWidget {
  final Function(int navIndex)? onNavTap;
  final Function(String opportunityId)? onOpportunityTap;
  final List<OpportunityModel>? initialOpportunities;

  const SavedScreen({
    super.key,
    this.onNavTap,
    this.onOpportunityTap,
    this.initialOpportunities,
  });

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  final _firestoreService = FirestoreService();
  int _currentNavIndex = 2;

  UserModel? _user;
  List<OpportunityModel> _savedOpportunities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialOpportunities != null) {
      _savedOpportunities = widget.initialOpportunities!;
      _isLoading = false;
    } else {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final user = await _firestoreService.getUserProfile(uid);
      List<OpportunityModel> savedList = [];
      if (user != null && user.savedOpportunityIds.isNotEmpty) {
        savedList = await _firestoreService.getSavedOpportunities(
          user.savedOpportunityIds,
        );
      }

      setState(() {
        _user = user;
        _savedOpportunities = savedList;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeBookmark(String oppId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await _firestoreService.toggleSaveOpportunity(uid, oppId);
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final closingSoonCount = _savedOpportunities
        .where((o) => o.daysLeft <= 7)
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Saved opportunities',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 8.0,
              ),
              child: Text(
                '${_savedOpportunities.length} saved · $closingSoonCount closing soon',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),

            // List or Empty State
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : _savedOpportunities.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 100),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.bookmark_outline_rounded,
                                size: 72,
                                color: AppColors.textMuted,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No saved opportunities yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap the bookmark icon on any opportunity to save it here.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: _savedOpportunities.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final opp = _savedOpportunities[index];

                        return _buildSavedCard(
                          id: opp.id,
                          category: opp.category,
                          title: opp.title,
                          subtitle: opp.subtitle,
                          deadlineText: opp.deadlineFormattedText,
                          isUrgent: opp.isUrgent,
                          onTap: () => widget.onOpportunityTap?.call(opp.id),
                          onRemoveTap: () => _removeBookmark(opp.id),
                        );
                      },
                    ),
            ),
          ],
        ),
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
  }

  Widget _buildSavedCard({
    required String id,
    required String category,
    required String title,
    required String subtitle,
    required String deadlineText,
    bool isUrgent = false,
    VoidCallback? onTap,
    VoidCallback? onRemoveTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.scholarshipBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.scholarshipText,
                    ),
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    deadlineText,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isUrgent
                          ? AppColors.deadlineText
                          : AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(
                    Icons.bookmark_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  onPressed: onRemoveTap,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
