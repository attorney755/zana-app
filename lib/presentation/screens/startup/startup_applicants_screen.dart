import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/localization/app_translations.dart';
import '../../../data/models/application_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/firestore_service.dart';
import '../../widgets/startup_bottom_nav_bar.dart';

class StartupApplicantsScreen extends StatefulWidget {
  final ValueChanged<int>? onNavTap;

  const StartupApplicantsScreen({super.key, this.onNavTap});

  @override
  State<StartupApplicantsScreen> createState() =>
      _StartupApplicantsScreenState();
}

class _StartupApplicantsScreenState extends State<StartupApplicantsScreen> {
  final _firestoreService = FirestoreService();
  int _activeTab = 0; // 0 = All Applicants, 1 = Pending Review
  List<ApplicationModel> _allApplicants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApplicants();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadApplicants();
  }

  Future<void> _loadApplicants() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'founder_demo';
    final apps = await _firestoreService.getApplicationsForFounder(uid);
    final finalApps = apps.isNotEmpty
        ? apps
        : [
            ApplicationModel(
              id: 'sample_app_1',
              opportunityId: 'sample_opp_1',
              opportunityTitle: 'Testing Opportunity',
              companyName: 'Zana Partner',
              applicantUid: uid,
              coverLetter:
                  'Passionate applicant looking forward to working with your team.',
              availability: 'Immediate',
              status: 'Applied',
              appliedAt: DateTime.now().subtract(const Duration(minutes: 10)),
            ),
          ];

    if (mounted) {
      setState(() {
        _allApplicants = finalApps;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(ApplicationModel app, String newStatus) async {
    try {
      await _firestoreService.updateApplicationStatus(
        appId: app.id,
        status: newStatus,
        applicantUid: app.applicantUid,
        opportunityTitle: app.opportunityTitle,
        companyName: app.companyName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Applicant status updated to "$newStatus". Notification sent!',
            ),
            backgroundColor: const Color(0xFF3730A3),
          ),
        );
        _loadApplicants();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating status: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgClr = Color(0xFFF3F0FF);
    const cardBg = Colors.white;
    const textColor = Color(0xFF1E1B4B);
    const subtextColor = Color(0xFF6B7280);

    final pendingApplicants = _allApplicants
        .where(
          (a) =>
              a.status.toLowerCase() == 'applied' ||
              a.status.toLowerCase() == 'pending',
        )
        .toList();

    final displayedList = _activeTab == 0 ? _allApplicants : pendingApplicants;

    return Scaffold(
      backgroundColor: bgClr,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textColor,
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
          AppTranslations.tr('applicants_management'),
          style: const TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0F4C81)),
            )
          : Column(
              children: [
                // Tab Selection Bar
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _activeTab = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _activeTab == 0
                                      ? const Color(0xFF0F4C81)
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Text(
                              '${AppTranslations.tr("all_applicants")} (${_allApplicants.length})',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: _activeTab == 0
                                    ? const Color(0xFF0F4C81)
                                    : subtextColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _activeTab = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _activeTab == 1
                                      ? const Color(0xFF0F4C81)
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Text(
                              '${AppTranslations.tr("pending_review")} (${pendingApplicants.length})',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: _activeTab == 1
                                    ? const Color(0xFF0F4C81)
                                    : subtextColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Applicants List View
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadApplicants,
                    color: const Color(0xFF0F4C81),
                    child: displayedList.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 80),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.people_outline_rounded,
                                      size: 64,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      AppTranslations.tr('no_applicants_found'),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      AppTranslations.tr(
                                        'applicants_appear_here',
                                      ),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: subtextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(20),
                            itemCount: displayedList.length,
                            itemBuilder: (context, index) {
                              return _ApplicantCard(
                                key: ValueKey(displayedList[index].id),
                                app: displayedList[index],
                                cardBg: cardBg,
                                textColor: textColor,
                                subtextColor: subtextColor,
                                onUpdateStatus: _updateStatus,
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: StartupBottomNavBar(
        currentIndex: 2,
        onTap: widget.onNavTap ?? (index) {},
      ),
    );
  }
}

class _ApplicantCard extends StatefulWidget {
  final ApplicationModel app;
  final Color cardBg;
  final Color textColor;
  final Color subtextColor;
  final Function(ApplicationModel, String) onUpdateStatus;

  const _ApplicantCard({
    super.key,
    required this.app,
    required this.cardBg,
    required this.textColor,
    required this.subtextColor,
    required this.onUpdateStatus,
  });

  @override
  State<_ApplicantCard> createState() => _ApplicantCardState();
}

class _ApplicantCardState extends State<_ApplicantCard> {
  final _firestoreService = FirestoreService();
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    if (widget.app.applicantUid.isEmpty) return;
    final profile = await _firestoreService.getUserProfile(
      widget.app.applicantUid,
    );
    if (mounted) {
      setState(() {
        _user = profile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    final appliedDate = DateFormat('MMM dd, yyyy').format(app.appliedAt);
    final name = _user?.fullName.isNotEmpty == true
        ? _user!.fullName
        : 'Applicant';
    final email = _user?.email.isNotEmpty == true
        ? _user!.email
        : 'Student Seeker';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'A';

    Color statusColor;
    Color statusBg;
    switch (app.status.toLowerCase()) {
      case 'accepted':
        statusColor = const Color(0xFF047857);
        statusBg = const Color(0xFFD1FAE5);
        break;
      case 'shortlisted':
        statusColor = const Color(0xFF0F4C81);
        statusBg = const Color(0xFFE0F2FE);
        break;
      case 'rejected':
        statusColor = const Color(0xFFB91C1C);
        statusBg = const Color(0xFFFEE2E2);
        break;
      default:
        statusColor = const Color(0xFFD97706);
        statusBg = const Color(0xFFFEF3C7);
    }

    return Card(
      color: widget.cardBg,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unified Row Layout (No Nested Flex Overflows)
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFEEF2FF),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F4C81),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: widget.textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.subtextColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    app.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFE5E7EB)),
            const SizedBox(height: 8),
            Text(
              'Applied for: ${app.opportunityTitle}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: widget.textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Applied on: $appliedDate',
              style: TextStyle(fontSize: 12, color: widget.subtextColor),
            ),
            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    context.push('/startup/applicant-details', extra: app),
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: const Text(
                  'View Applicant Details',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F4C81),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
