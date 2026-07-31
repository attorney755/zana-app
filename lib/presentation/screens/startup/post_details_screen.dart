import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme_provider.dart';
import '../../../data/models/opportunity_model.dart';
import '../../../data/services/firestore_service.dart';

class PostDetailsScreen extends StatefulWidget {
  final String opportunityId;

  const PostDetailsScreen({super.key, required this.opportunityId});

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final _firestoreService = FirestoreService();
  OpportunityModel? _opp;

  @override
  void initState() {
    super.initState();
    _loadPostDetails();
  }

  Future<void> _loadPostDetails() async {
    final opp = await _firestoreService.getOpportunityById(
      widget.opportunityId,
    );
    if (mounted) {
      setState(() {
        _opp = opp;
      });
    }
  }

  Future<void> _toggleActiveStatus(OpportunityModel opp) async {
    final nextState = !opp.isActive;
    final actionTitle = nextState ? 'Reopen Opportunity' : 'Close Opportunity';
    final actionMsg = nextState
        ? 'Are you sure you want to reopen "${opp.title}"? Candidates will be notified.'
        : 'Are you sure you want to close "${opp.title}"? Applications will be paused.';
    final buttonLabel = nextState ? 'Reopen Post' : 'Close Post';
    final btnColor = nextState
        ? const Color(0xFF10B981)
        : const Color(0xFFF59E0B);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          actionTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1B4B),
          ),
        ),
        content: Text(actionMsg),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Color(0xFF9CA3AF)),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF4B5563),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    buttonLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _firestoreService.toggleOpportunityActiveStatus(
        opp.id,
        opp.title,
        opp.isActive,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              nextState
                  ? 'Opportunity reopened successfully! Redirecting to My Posts...'
                  : 'Opportunity closed successfully! Redirecting to My Posts...',
            ),
            backgroundColor: btnColor,
            duration: const Duration(seconds: 2),
          ),
        );
        context.go('/startup/my-posts');
      }
    }
  }

  Future<void> _deletePost(OpportunityModel opp) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Post',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1B4B),
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${opp.title}"? This action cannot be undone.',
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Color(0xFF9CA3AF)),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF4B5563),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _firestoreService.deleteOpportunity(opp.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Opportunity deleted successfully. Redirecting to My Posts...',
            ),
            duration: Duration(seconds: 2),
          ),
        );
        context.go('/startup/my-posts');
      }
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
            : const Color(0xFFF3F0FF);
        final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF1E1B4B);
        final subtextColor = isDark ? Colors.white70 : const Color(0xFF6B7280);

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
                  context.go('/startup/my-posts');
                }
              },
            ),
            title: Text(
              'Post Details',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.refresh_rounded,
                  color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                ),
                onPressed: _loadPostDetails,
              ),
              IconButton(
                icon: Icon(
                  Icons.edit_rounded,
                  color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                ),
                onPressed: () {
                  if (_opp != null) {
                    context.push('/startup/edit-post/${_opp!.id}');
                  }
                },
              ),
            ],
          ),
          body: StreamBuilder<OpportunityModel?>(
            stream: _firestoreService.streamOpportunityById(
              widget.opportunityId,
            ),
            builder: (context, snapshot) {
              final opp = snapshot.data ?? _opp;

              if (snapshot.connectionState == ConnectionState.waiting &&
                  opp == null) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF3730A3)),
                );
              }

              if (opp == null) {
                return const Center(child: Text('Opportunity not found.'));
              }

              final postedDate = DateFormat(
                'MMM dd, yyyy',
              ).format(opp.createdAt);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Badge + Category Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            opp.category,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3730A3),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: opp.isActive
                                ? const Color(0xFFD1FAE5)
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            opp.isActive ? 'Active' : 'Closed',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: opp.isActive
                                  ? const Color(0xFF047857)
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      opp.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Provider Name
                    Text(
                      'By ${opp.provider}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3730A3),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Metrics Card (Views, Applicants, Posted Date)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMetricItem(
                            Icons.people_outline_rounded,
                            '${opp.applicantsCount}',
                            'Applicants',
                            textColor,
                            subtextColor,
                          ),
                          _buildMetricItem(
                            Icons.calendar_today_rounded,
                            postedDate,
                            'Posted Date',
                            textColor,
                            subtextColor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Details Info Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            Icons.work_outline_rounded,
                            'Work Type',
                            opp.workType,
                            textColor,
                            subtextColor,
                          ),
                          const SizedBox(height: 14),
                          _buildDetailRow(
                            Icons.access_time_rounded,
                            'Commitment',
                            opp.commitment,
                            textColor,
                            subtextColor,
                          ),
                          const SizedBox(height: 14),
                          _buildDetailRow(
                            Icons.location_on_outlined,
                            'Location',
                            opp.location,
                            textColor,
                            subtextColor,
                          ),
                          const SizedBox(height: 14),
                          _buildDetailRow(
                            Icons.timer_outlined,
                            'Hours/Week',
                            opp.hoursPerWeek,
                            textColor,
                            subtextColor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Description
                    Text(
                      'Description',
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
                    const SizedBox(height: 24),

                    // Skills Required
                    if (opp.skills.isNotEmpty) ...[
                      Text(
                        'Required Skills',
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
                        children: opp.skills.map((skill) {
                          return Chip(
                            label: Text(skill),
                            backgroundColor: const Color(0xFFEEF2FF),
                            labelStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3730A3),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: Color(0xFFC7D2FE)),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Action Buttons: Close/Reopen Post & Delete Post
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: Icon(
                              opp.isActive
                                  ? Icons.lock_outline_rounded
                                  : Icons.lock_open_rounded,
                            ),
                            label: Text(
                              opp.isActive ? 'Close Post' : 'Reopen Post',
                            ),
                            onPressed: () => _toggleActiveStatus(opp),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: opp.isActive
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.red,
                            ),
                            label: const Text(
                              'Delete Post',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () => _deletePost(opp),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(
                                color: Colors.red,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMetricItem(
    IconData icon,
    String value,
    String label,
    Color textColor,
    Color subtextColor,
  ) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF3730A3), size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: subtextColor)),
      ],
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    Color textColor,
    Color subtextColor,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF3730A3)),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(fontSize: 14, color: subtextColor)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
