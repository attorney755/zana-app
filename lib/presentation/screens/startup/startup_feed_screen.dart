import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_language_provider.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/theme/app_theme_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/opportunity_model.dart';
import '../../../data/models/application_model.dart';
import '../../../data/services/firestore_service.dart';
import '../../widgets/startup_bottom_nav_bar.dart';

class StartupFeedScreen extends StatefulWidget {
  final ValueChanged<int>? onNavTap;

  const StartupFeedScreen({super.key, this.onNavTap});

  @override
  State<StartupFeedScreen> createState() => _StartupFeedScreenState();
}

class _StartupFeedScreenState extends State<StartupFeedScreen> {
  final _firestoreService = FirestoreService();
  UserModel? _founder;
  List<OpportunityModel> _myPosts = [];
  List<ApplicationModel> _myApplicants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final profile = await _firestoreService.getUserProfile(uid);
    final posts = await _firestoreService.getFounderOpportunities(uid);
    final apps = await _firestoreService.getApplicationsForFounder(uid);

    if (mounted) {
      setState(() {
        _founder = profile;
        _myPosts = posts;
        _myApplicants = apps;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return ValueListenableBuilder<Locale>(
      valueListenable: appLanguageNotifier,
      builder: (context, locale, child) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: appThemeNotifier,
          builder: (context, themeMode, child) {
            final isDark = themeMode == ThemeMode.dark;
            final bgClr = isDark
                ? const Color(0xFF121212)
                : const Color(0xFFF3F0FF);
            final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
            final textColor = isDark ? Colors.white : const Color(0xFF1E1B4B);
            final subtextColor = isDark
                ? Colors.white70
                : const Color(0xFF6B7280);

            final startupName = _founder?.companyName?.isNotEmpty == true
                ? _founder!.companyName!
                : (_founder?.fullName.isNotEmpty == true
                      ? _founder!.fullName
                      : (FirebaseAuth.instance.currentUser?.displayName ??
                            'Startup Founder'));

            final initials = _founder?.initials ?? 'ZT';

            return Scaffold(
              backgroundColor: bgClr,
              body: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF3730A3),
                      ),
                    )
                  : Column(
                      children: [
                        // Soft Lilac / White Clean Top Header Area
                        Container(
                          width: double.infinity,
                          color: isDark
                              ? const Color(0xFF1E1E1E)
                              : Colors.white,
                          padding: EdgeInsets.fromLTRB(
                            20,
                            MediaQuery.of(context).padding.top + 12,
                            20,
                            16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Greeting & Username on Top Left
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${AppTranslations.tr("hello")}, $startupName',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          AppTranslations.tr(
                                            'welcome_back_dashboard',
                                          ),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF6B7280),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Notification Bell & Circular Initials Avatar on Top Right
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      StreamBuilder<int>(
                                        stream: uid != null
                                            ? _firestoreService
                                                  .streamUnreadNotificationCount(
                                                    uid,
                                                  )
                                            : Stream.value(0),
                                        builder: (context, countSnap) {
                                          final unreadCount =
                                              countSnap.data ?? 0;
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? const Color(0xFF2D2B55)
                                                  : const Color(0xFF0F4C81),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons
                                                        .notifications_none_rounded,
                                                    color: Colors.white,
                                                    size: 22,
                                                  ),
                                                  onPressed: () => context.push(
                                                    '/notifications',
                                                  ),
                                                ),
                                                if (unreadCount > 0)
                                                  Positioned(
                                                    right: 4,
                                                    top: 4,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            4,
                                                          ),
                                                      decoration:
                                                          const BoxDecoration(
                                                            color: Color(
                                                              0xFFEF4444,
                                                            ),
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                      constraints:
                                                          const BoxConstraints(
                                                            minWidth: 16,
                                                            minHeight: 16,
                                                          ),
                                                      child: Text(
                                                        '$unreadCount',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 10),
                                      GestureDetector(
                                        onTap: () {
                                          if (widget.onNavTap != null) {
                                            widget.onNavTap!(3);
                                          } else {
                                            context.go('/startup/profile');
                                          }
                                        },
                                        child: CircleAvatar(
                                          radius: 22,
                                          backgroundColor: const Color(
                                            0xFFEEF2FF,
                                          ),
                                          child: Text(
                                            initials,
                                            style: const TextStyle(
                                              color: Color(0xFF0F4C81),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Main Scrollable Dashboard Content
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _loadDashboardData,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Greeting Headline
                                  Text(
                                    AppTranslations.tr('dashboard_overview'),
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    AppTranslations.tr('track_performance'),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: subtextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Horizontal Scrolling Colorful Project/Stat Cards
                                  SizedBox(
                                    height: 130,
                                    child: ListView(
                                      scrollDirection: Axis.horizontal,
                                      children: [
                                        // Card 1: Total Posts
                                        GestureDetector(
                                          onTap: () =>
                                              context.push('/startup/my-posts'),
                                          child: _buildColorfulCard(
                                            title: AppTranslations.tr(
                                              'total_posts',
                                            ),
                                            count: '${_myPosts.length}',
                                            subtitle: AppTranslations.tr(
                                              'active_opportunities',
                                            ),
                                            bgColor: const Color(0xFF0F4C81),
                                            textColor: Colors.white,
                                            icon: Icons.post_add_rounded,
                                          ),
                                        ),
                                        const SizedBox(width: 14),

                                        // Card 2: Total Applicants
                                        GestureDetector(
                                          onTap: () => context.push(
                                            '/startup/applicants',
                                          ),
                                          child: _buildColorfulCard(
                                            title: AppTranslations.tr(
                                              'applicants',
                                            ),
                                            count: '${_myApplicants.length}',
                                            subtitle: AppTranslations.tr(
                                              'received_submissions',
                                            ),
                                            bgColor: const Color(0xFF7F1D1D),
                                            textColor: Colors.white,
                                            icon: Icons.people_alt_rounded,
                                          ),
                                        ),
                                        const SizedBox(width: 14),

                                        // Card 3: Analytics
                                        GestureDetector(
                                          onTap: () => context.push(
                                            '/startup/analytics',
                                          ),
                                          child: _buildColorfulCard(
                                            title: AppTranslations.tr(
                                              'analytics',
                                            ),
                                            count: _myPosts.isNotEmpty
                                                ? (_myApplicants.length /
                                                          _myPosts.length)
                                                      .toStringAsFixed(1)
                                                : '0.0',
                                            subtitle: 'Avg Applicants/Post',
                                            bgColor: const Color(0xFF3730A3),
                                            textColor: Colors.white,
                                            icon: Icons.analytics_rounded,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 28),

                                  // Quick Actions Section
                                  Text(
                                    AppTranslations.tr('quick_actions'),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 14),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildActionButton(
                                          icon: Icons.add_rounded,
                                          label: AppTranslations.tr('post'),
                                          color: const Color(0xFF3730A3),
                                          bgColor: const Color(0xFFEEF2FF),
                                          onTap: () => context.go(
                                            '/startup/post-opportunity',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _buildActionButton(
                                          icon: Icons.bar_chart_rounded,
                                          label: AppTranslations.tr(
                                            'analytics',
                                          ),
                                          color: const Color(0xFF0F4C81),
                                          bgColor: const Color(0xFFE0F2FE),
                                          onTap: () => context.push(
                                            '/startup/analytics',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _buildActionButton(
                                          icon: Icons.people_outline_rounded,
                                          label: AppTranslations.tr(
                                            'applicants',
                                          ),
                                          color: const Color(0xFF10B981),
                                          bgColor: const Color(0xFFD1FAE5),
                                          onTap: () => context.push(
                                            '/startup/applicants',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _buildActionButton(
                                          icon:
                                              Icons.chat_bubble_outline_rounded,
                                          label: AppTranslations.tr('messages'),
                                          color: const Color(0xFFF59E0B),
                                          bgColor: const Color(0xFFFEF3C7),
                                          onTap: () =>
                                              context.push('/startup/messages'),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 28),

                                  // Recent Opportunities Section
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        AppTranslations.tr(
                                          'recent_opportunities',
                                        ),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            context.push('/startup/my-posts'),
                                        child: Text(
                                          AppTranslations.tr('see_all'),
                                          style: const TextStyle(
                                            color: Color(0xFF0F4C81),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  if (_myPosts.isEmpty)
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: cardBg,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isDark
                                              ? Colors.white12
                                              : const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          const Icon(
                                            Icons.post_add_rounded,
                                            size: 48,
                                            color: Color(0xFF9CA3AF),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            AppTranslations.tr(
                                              'no_opportunities_yet',
                                            ),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            AppTranslations.tr('tap_to_create'),
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: subtextColor,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: _myPosts.length > 3
                                          ? 3
                                          : _myPosts.length,
                                      itemBuilder: (context, index) {
                                        final opp = _myPosts[index];
                                        return Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: cardBg,
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.04,
                                                ),
                                                blurRadius: 10,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: ListTile(
                                            onTap: () => context.push(
                                              '/startup/post-details/${opp.id}',
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 6,
                                                ),
                                            title: Text(
                                              opp.title,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: textColor,
                                              ),
                                            ),
                                            subtitle: Text(
                                              '${opp.category} • ${opp.location}',
                                              style: TextStyle(
                                                color: subtextColor,
                                                fontSize: 12,
                                              ),
                                            ),
                                            trailing: const Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              size: 16,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
              floatingActionButton: FloatingActionButton(
                onPressed: () => context.go('/startup/post-opportunity'),
                backgroundColor: const Color(0xFF0F4C81),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              bottomNavigationBar: StartupBottomNavBar(
                currentIndex: 0,
                onTap: widget.onNavTap ?? (index) {},
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildColorfulCard({
    required String title,
    required String count,
    required String subtitle,
    required Color bgColor,
    required Color textColor,
    required IconData icon,
  }) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor.withValues(alpha: 0.85),
                ),
              ),
              Icon(icon, color: textColor.withValues(alpha: 0.9), size: 20),
            ],
          ),
          Text(
            count,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: textColor.withValues(alpha: 0.75),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
