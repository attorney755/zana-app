import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../data/models/application_model.dart';
import '../../../data/models/opportunity_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/firestore_service.dart';

class ApplicantDetailScreen extends StatefulWidget {
  final ApplicationModel application;

  const ApplicantDetailScreen({
    super.key,
    required this.application,
  });

  @override
  State<ApplicantDetailScreen> createState() => _ApplicantDetailScreenState();
}

class _ApplicantDetailScreenState extends State<ApplicantDetailScreen> {
  final _firestoreService = FirestoreService();
  UserModel? _applicantUser;
  OpportunityModel? _opportunity;
  bool _isLoading = true;
  bool _isCoverLetterExpanded = false;
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.application.status;
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final user = await _firestoreService.getUserProfile(widget.application.applicantUid);
      final opp = await _firestoreService.getOpportunityById(widget.application.opportunityId);
      if (mounted) {
        setState(() {
          _applicantUser = user;
          _opportunity = opp;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      await _firestoreService.updateApplicationStatus(
        appId: widget.application.id,
        status: newStatus,
        applicantUid: widget.application.applicantUid,
        opportunityTitle: widget.application.opportunityTitle,
        companyName: widget.application.companyName,
      );

      if (mounted) {
        setState(() {
          _currentStatus = newStatus;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to "$newStatus". Notification sent to candidate!'),
            backgroundColor: const Color(0xFF3730A3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e')),
        );
      }
    }
  }

  void _showSendFeedbackDialog() {
    final feedbackController = TextEditingController();
    final founderUid = FirebaseAuth.instance.currentUser?.uid ?? 'founder_demo';
    final studentName = _applicantUser?.fullName ?? 'Applicant';
    final rootContext = context;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            bool isSending = false;

            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Send Feedback to $studentName',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF6B7280)),
                        onPressed: () => Navigator.pop(modalContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Type a message or click a suggestion below. The candidate will receive a notification and it will be recorded in your Messages history.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 14),

                  // Suggestion Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                        label: const Text('Shortlisted for interview', style: TextStyle(fontSize: 12)),
                        onPressed: () => feedbackController.text =
                            'Thank you for your interest! We have shortlisted your application and would like to invite you for an interview. Please reply with your resume.',
                      ),
                      ActionChip(
                        label: const Text('Skills update', style: TextStyle(fontSize: 12)),
                        onPressed: () => feedbackController.text =
                            'Thank you for applying. While your profile is strong, our team is looking for skills closely matching the role specs. We encourage you to apply for future roles!',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: feedbackController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Type your feedback message here...',
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF0F4C81), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isSending
                          ? null
                          : () async {
                              final msg = feedbackController.text.trim();
                              if (msg.isEmpty) return;

                              setModalState(() => isSending = true);

                              await _firestoreService.sendFounderFeedback(
                                founderUid: founderUid,
                                studentUid: widget.application.applicantUid,
                                studentName: studentName,
                                opportunityTitle: widget.application.opportunityTitle,
                                messageText: msg,
                              );

                              if (Navigator.canPop(modalContext)) {
                                Navigator.pop(modalContext);
                              }

                              if (rootContext.mounted) {
                                ScaffoldMessenger.of(rootContext).showSnackBar(
                                  SnackBar(
                                    content: Text('Feedback sent successfully to $studentName! Opening Sent Messages...'),
                                    backgroundColor: const Color(0xFF10B981),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                                rootContext.push('/startup/messages');
                              }
                            },
                      icon: isSending
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.send_rounded, size: 18),
                      label: Text(
                        isSending ? 'Sending Feedback...' : 'Send Feedback',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F4C81),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLinkToast(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening candidate $title...'),
        backgroundColor: const Color(0xFF0F4C81),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgClr = Color(0xFFF3F0FF);
    const textColor = Color(0xFF1E1B4B);
    const subtextColor = Color(0xFF6B7280);

    final appliedDate = DateFormat('MMM dd, yyyy').format(widget.application.appliedAt);
    final user = _applicantUser;
    final name = (user?.fullName ?? '').isNotEmpty ? user!.fullName : 'Applicant';
    final email = (user?.email ?? '').isNotEmpty ? user!.email : 'Student Seeker';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'A';
    final countryStr = (user?.country ?? '').isNotEmpty ? user!.country! : 'Rwanda';
    final fieldOfStudy = (user?.fieldOfStudy ?? '').isNotEmpty ? user!.fieldOfStudy! : 'Computer Science';
    final educationLevel = (user?.educationLevel ?? '').isNotEmpty ? user!.educationLevel! : 'Undergraduate';

    // Check Eligibility match
    final eligibleCountries = _opportunity?.eligibleCountries ?? ['Rwanda'];
    final isEligible = eligibleCountries.any((c) => c.toLowerCase() == countryStr.toLowerCase()) || eligibleCountries.isEmpty;

    Color statusColor;
    Color statusBg;
    switch (_currentStatus.toLowerCase()) {
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

    final coverText = widget.application.coverLetter.isNotEmpty
        ? widget.application.coverLetter
        : 'I am highly passionate about this opportunity and ready to contribute to the team.';

    final shortCoverText = coverText.length > 120 ? '${coverText.substring(0, 120)}...' : coverText;

    return Scaffold(
      backgroundColor: bgClr,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Applicant Details',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F4C81)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Candidate Profile Card
                  Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: const Color(0xFFEEF2FF),
                                child: Text(
                                  initial,
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F4C81)),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                                    ),
                                    Text(
                                      email,
                                      style: const TextStyle(fontSize: 13, color: subtextColor),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF0F4C81)),
                                        const SizedBox(width: 4),
                                        Text(countryStr, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8)),
                                child: Text(
                                  _currentStatus.toUpperCase(),
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Color(0xFFE5E7EB)),
                          const SizedBox(height: 12),

                          Text('Education & Field:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: subtextColor)),
                          const SizedBox(height: 4),
                          Text('$educationLevel · $fieldOfStudy', style: const TextStyle(fontSize: 14, color: textColor, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 16),

                          // Links Row
                          Text('Candidate Links:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: subtextColor)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => _showLinkToast('GitHub Profile'),
                                icon: const Icon(Icons.code_rounded, size: 16, color: Color(0xFF0F4C81)),
                                label: const Text('GitHub Profile', style: TextStyle(fontSize: 12)),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => _showLinkToast('LinkedIn'),
                                icon: const Icon(Icons.link_rounded, size: 16, color: Color(0xFF0F4C81)),
                                label: const Text('LinkedIn', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Eligibility Banner
                  Card(
                    color: isEligible ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: isEligible ? const Color(0xFF10B981) : const Color(0xFFF59E0B)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            isEligible ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                            color: isEligible ? const Color(0xFF047857) : const Color(0xFFD97706),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isEligible ? 'Meets Country Eligibility' : 'Review Country Requirement',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isEligible ? const Color(0xFF047857) : const Color(0xFFD97706),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isEligible
                                      ? 'Candidate from $countryStr is eligible for ${widget.application.opportunityTitle} (${eligibleCountries.join(", ")})'
                                      : 'Eligible countries: ${eligibleCountries.join(", ")}. Candidate location: $countryStr',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF374151)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cover Letter Card
                  Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Cover Letter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                              Text('Applied: $appliedDate', style: const TextStyle(fontSize: 12, color: subtextColor)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _isCoverLetterExpanded ? coverText : shortCoverText,
                            style: const TextStyle(fontSize: 14, color: textColor, height: 1.5),
                          ),
                          if (coverText.length > 120) ...[
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => setState(() => _isCoverLetterExpanded = !_isCoverLetterExpanded),
                              child: Text(
                                _isCoverLetterExpanded ? 'Show Less' : 'View Full Cover Letter',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F4C81)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Bar (Send Feedback & Status Updates)
                  Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Application Actions', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor)),
                          const SizedBox(height: 14),

                          // Send Feedback Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _showSendFeedbackDialog,
                              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                              label: const Text('Send Feedback to Candidate', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3730A3),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Status Update Buttons
                          Row(
                            children: [
                              if (_currentStatus.toLowerCase() != 'shortlisted')
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _updateStatus('shortlisted'),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Color(0xFF0F4C81)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: const Text('Shortlist', style: TextStyle(color: Color(0xFF0F4C81), fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              if (_currentStatus.toLowerCase() != 'shortlisted') const SizedBox(width: 8),
                              if (_currentStatus.toLowerCase() != 'accepted')
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => _updateStatus('accepted'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF10B981),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      elevation: 0,
                                    ),
                                    child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              if (_currentStatus.toLowerCase() != 'accepted') const SizedBox(width: 8),
                              if (_currentStatus.toLowerCase() != 'rejected')
                                Expanded(
                                  child: TextButton(
                                    onPressed: () => _updateStatus('rejected'),
                                    child: const Text('Reject', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                  ),
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
    );
  }
}
