import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_language_provider.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/theme/app_theme_provider.dart';
import '../../../data/models/opportunity_model.dart';
import '../../../data/services/firestore_service.dart';
import '../../widgets/startup_bottom_nav_bar.dart';

class MyPostsScreen extends StatefulWidget {
  final ValueChanged<int>? onNavTap;

  const MyPostsScreen({
    super.key,
    this.onNavTap,
  });

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _selectedTab = 'All'; // 'All', 'Open', 'Closed'
  String _selectedSort = 'Default'; // 'Default', 'Most Viewed'

  Future<void> _deletePost(String oppId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Opportunity', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
        content: const Text('Are you sure you want to delete this opportunity? This action cannot be undone.'),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: Color(0xFF9CA3AF)),
                  ),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF4B5563), fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _firestoreService.deleteOpportunity(oppId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opportunity deleted successfully')),
        );
      }
    }
  }

  Future<void> _toggleActiveStatus(OpportunityModel opp) async {
    final nextState = !opp.isActive;
    final actionTitle = nextState ? 'Reopen Opportunity' : 'Close Opportunity';
    final actionMsg = nextState
        ? 'Are you sure you want to reopen "${opp.title}"? Candidates will be notified.'
        : 'Are you sure you want to close "${opp.title}"? Applications will be paused.';
    final buttonLabel = nextState ? 'Reopen Post' : 'Close Post';
    final btnColor = nextState ? const Color(0xFF10B981) : const Color(0xFFF59E0B);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(actionTitle, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
        content: Text(actionMsg),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: Color(0xFF9CA3AF)),
                  ),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF4B5563), fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btnColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(buttonLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _firestoreService.toggleOpportunityActiveStatus(opp.id, opp.title, opp.isActive);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(nextState ? 'Opportunity reopened! Applicants notified.' : 'Opportunity closed! Applicants notified.'),
            backgroundColor: btnColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

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
                  AppTranslations.tr('my_posts'),
                  style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E1B4B), fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
              ),
              body: currentUid == null
                  ? Center(
                      child: Text(
                        'Please log in to view your posts.',
                        style: TextStyle(color: textColor),
                      ),
                    )
                  : StreamBuilder<List<OpportunityModel>>(
                      stream: _firestoreService.streamFounderOpportunities(currentUid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: Color(0xFF0F4C81)));
                        }

                        final allPosts = snapshot.data ?? [];

                        // Filter by tab
                        var filteredPosts = allPosts.where((p) {
                          if (_selectedTab == 'Open') return p.isActive;
                          if (_selectedTab == 'Closed') return !p.isActive;
                          return true;
                        }).toList();

                        // Sort
                        if (_selectedSort == 'Oldest') {
                          filteredPosts.sort((a, b) => a.createdAt.compareTo(b.createdAt));
                        } else {
                          filteredPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                        }

                        return Column(
                          children: [
                            // Filter & Tab Header Bar
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                              child: Column(
                                children: [
                                  // Tab Chips
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        _buildFilterTabChip('All', 'All (${allPosts.length})'),
                                        const SizedBox(width: 8),
                                        _buildFilterTabChip('Open', 'Open (${allPosts.where((p) => p.isActive).length})'),
                                        const SizedBox(width: 8),
                                        _buildFilterTabChip('Closed', 'Closed (${allPosts.where((p) => !p.isActive).length})'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${filteredPosts.length} Opportunities',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: subtextColor),
                                      ),
                                      DropdownButton<String>(
                                        value: _selectedSort,
                                        underline: const SizedBox(),
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F4C81)),
                                        icon: const Icon(Icons.sort_rounded, size: 18, color: Color(0xFF0F4C81)),
                                        items: const [
                                          DropdownMenuItem(value: 'Default', child: Text('Sort: Latest')),
                                          DropdownMenuItem(value: 'Oldest', child: Text('Sort: Oldest')),
                                        ],
                                        onChanged: (val) {
                                          if (val != null) setState(() => _selectedSort = val);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            Expanded(
                              child: filteredPosts.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.post_add_rounded, size: 64, color: Color(0xFF9CA3AF)),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No $_selectedTab opportunities found',
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Create a new opportunity to reach candidates.',
                                            style: TextStyle(fontSize: 14, color: subtextColor),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.all(20),
                                      itemCount: filteredPosts.length,
                                      itemBuilder: (context, index) {
                                        final opp = filteredPosts[index];
                                        final isClosed = !opp.isActive;

                                        return Card(
                                          color: cardBg,
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                          margin: const EdgeInsets.only(bottom: 16),
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(20),
                                            onTap: () => context.push('/startup/post-details/${opp.id}'),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(20),
                                              child: IntrinsicHeight(
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                                  children: [
                                                    // Left Accent Bar
                                                    Container(
                                                      width: 6,
                                                      color: isClosed
                                                          ? const Color(0xFF9CA3AF)
                                                          : (opp.category.toLowerCase() == 'internship' ? const Color(0xFF0F4C81) : const Color(0xFF10B981)),
                                                    ),
                                                    Expanded(
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(16.0),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Container(
                                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                                      decoration: BoxDecoration(
                                                                        color: const Color(0xFFEEF2FF),
                                                                        borderRadius: BorderRadius.circular(8),
                                                                      ),
                                                                      child: Text(
                                                                        opp.category.toUpperCase(),
                                                                        style: const TextStyle(
                                                                          color: Color(0xFF0F4C81),
                                                                          fontSize: 11,
                                                                          fontWeight: FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(width: 8),
                                                                    Container(
                                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                                      decoration: BoxDecoration(
                                                                        color: isClosed ? const Color(0xFFF3F4F6) : const Color(0xFFD1FAE5),
                                                                        borderRadius: BorderRadius.circular(8),
                                                                      ),
                                                                      child: Text(
                                                                        isClosed ? 'CLOSED' : 'ACTIVE',
                                                                        style: TextStyle(
                                                                          color: isClosed ? Colors.grey : const Color(0xFF047857),
                                                                          fontSize: 10,
                                                                          fontWeight: FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                PopupMenuButton<String>(
                                                                  icon: Icon(Icons.more_vert_rounded, color: subtextColor, size: 20),
                                                                  onSelected: (val) {
                                                                    if (val == 'details') {
                                                                      context.push('/startup/post-details/${opp.id}');
                                                                    } else if (val == 'edit') {
                                                                      context.push('/startup/edit-post/${opp.id}');
                                                                    } else if (val == 'toggle') {
                                                                      _toggleActiveStatus(opp);
                                                                    } else if (val == 'delete') {
                                                                      _deletePost(opp.id);
                                                                    }
                                                                  },
                                                                  itemBuilder: (context) => [
                                                                    PopupMenuItem(
                                                                      value: 'details',
                                                                      child: Row(
                                                                        children: [
                                                                          const Icon(Icons.visibility_outlined, size: 18),
                                                                          const SizedBox(width: 8),
                                                                          Text(AppTranslations.tr('view_details')),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    PopupMenuItem(
                                                                      value: 'edit',
                                                                      child: Row(
                                                                        children: [
                                                                          const Icon(Icons.edit_outlined, size: 18),
                                                                          const SizedBox(width: 8),
                                                                          Text(AppTranslations.tr('edit')),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    PopupMenuItem(
                                                                      value: 'toggle',
                                                                      child: Row(
                                                                        children: [
                                                                          Icon(isClosed ? Icons.play_arrow_outlined : Icons.pause_outlined, size: 18),
                                                                          const SizedBox(width: 8),
                                                                          Text(isClosed ? 'Reopen Post' : 'Close Post'),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    const PopupMenuItem(
                                                                      value: 'delete',
                                                                      child: Row(
                                                                        children: [
                                                                          Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                                                                          SizedBox(width: 8),
                                                                          Text('Delete', style: TextStyle(color: Colors.red)),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(height: 8),
                                                            Text(
                                                              opp.title,
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.bold,
                                                                color: textColor,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 4),
                                                            Text(
                                                              '${opp.category} · ${opp.location}',
                                                              style: TextStyle(fontSize: 12, color: subtextColor),
                                                            ),
                                                            const SizedBox(height: 12),
                                                            Row(
                                                              children: [
                                                                Icon(Icons.people_outline_rounded, size: 16, color: subtextColor),
                                                                const SizedBox(width: 4),
                                                                Text(
                                                                  '${opp.applicantsCount} ${AppTranslations.tr('applicants')}',
                                                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        );
                      },
                    ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () => context.go('/startup/post-opportunity'),
                backgroundColor: const Color(0xFF0F4C81),
                foregroundColor: Colors.white,
                elevation: 4,
                icon: const Icon(Icons.add_rounded),
                label: Text(
                  AppTranslations.tr('post'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              bottomNavigationBar: StartupBottomNavBar(
                currentIndex: 1,
                onTap: widget.onNavTap ?? (index) {},
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterTabChip(String key, String label) {
    final isSelected = _selectedTab == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _selectedTab = key);
      },
      selectedColor: const Color(0xFF0F4C81),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: isSelected ? Colors.white : const Color(0xFF1E1B4B),
      ),
      backgroundColor: const Color(0xFFF3F4F6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
