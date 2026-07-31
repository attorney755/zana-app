import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme_provider.dart';
import '../../../data/models/opportunity_model.dart';
import '../../../data/models/application_model.dart';
import '../../../data/services/firestore_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final _firestoreService = FirestoreService();
  List<OpportunityModel> _posts = [];
  List<ApplicationModel> _apps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final posts = await _firestoreService.getFounderOpportunities(uid);
    final apps = await _firestoreService.getApplicationsForFounder(uid);

    if (mounted) {
      setState(() {
        _posts = posts;
        _apps = apps;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeNotifier,
      builder: (context, themeMode, child) {
        final isDark = themeMode == ThemeMode.dark;
        final bgClr = isDark
            ? const Color(0xFF121212)
            : const Color(0xFFF3F0FF); // Soft Lilac backdrop
        final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF1E1B4B);
        final subtextColor = isDark ? Colors.white70 : const Color(0xFF6B7280);

        final totalPosts = _posts.length;
        final totalApplicants = _apps.length;
        final conversionRate = totalPosts > 0
            ? (totalApplicants / totalPosts).toStringAsFixed(1)
            : '0.0';

        return Scaffold(
          backgroundColor: bgClr,
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                size: 22,
              ),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  context.go('/startup/feed');
                }
              },
            ),
            title: Text(
              'Performance Analytics',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF3730A3)),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Key Performance Metrics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Stat Box Cards with reference design colors (Teal, Maroon, Violet)
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricBox(
                              'Total Posts',
                              '$totalPosts',
                              Icons.post_add_rounded,
                              const Color(0xFF0F4C81),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildMetricBox(
                              'Applicants',
                              '$totalApplicants',
                              Icons.people_rounded,
                              const Color(0xFF7F1D1D),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildMetricBox(
                              'Avg / Post',
                              conversionRate,
                              Icons.trending_up_rounded,
                              const Color(0xFF3730A3),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // "Your Opportunities" Performance Section with Left Color Accent Stripes!
                      Text(
                        'Your Opportunities',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (_posts.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              'No opportunities posted to analyze yet.',
                              style: TextStyle(
                                color: subtextColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _posts.length,
                          itemBuilder: (context, index) {
                            final opp = _posts[index];
                            final stripeColor = index % 3 == 0
                                ? const Color(0xFF0F4C81)
                                : (index % 3 == 1
                                      ? const Color(0xFF7F1D1D)
                                      : const Color(0xFF10B981));

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                onTap: () => context.push(
                                  '/startup/post-details?id=${opp.id}',
                                ),
                                borderRadius: BorderRadius.circular(16),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Row(
                                    children: [
                                      // Vertical Accent Stripe from reference design!
                                      Container(
                                        width: 6,
                                        height: 70,
                                        color: stripeColor,
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              opp.title,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: textColor,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${opp.category} • ${opp.commitment}',
                                              style: TextStyle(
                                                color: subtextColor,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 16,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${opp.applicantsCount} Applicants',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: Color(0xFF3730A3),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${opp.viewsCount} Views',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: subtextColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildMetricBox(
    String title,
    String value,
    IconData icon,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
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
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
