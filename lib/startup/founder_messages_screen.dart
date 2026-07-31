import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/founder_message_model.dart';
import '../../../data/services/firestore_service.dart';

class FounderMessagesScreen extends StatefulWidget {
  const FounderMessagesScreen({super.key});

  @override
  State<FounderMessagesScreen> createState() => _FounderMessagesScreenState();
}

class _FounderMessagesScreenState extends State<FounderMessagesScreen> {
  final _firestoreService = FirestoreService();

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 30) {
      return '${diff.inDays}d ago';
    } else if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return '$months mth ago';
    } else {
      final years = (diff.inDays / 365).floor();
      return '$years yr ago';
    }
  }

  Future<void> _confirmDeleteMessage(String msgId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Message',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1B4B),
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this feedback message from your history?',
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

    if (confirm == true) {
      await _firestoreService.deleteFounderMessage(msgId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feedback message deleted successfully.'),
            backgroundColor: Color(0xFF3730A3),
          ),
        );
        setState(() {});
      }
    }
  }

  void _showSendFollowUpDialog(FounderMessageModel msg) {
    final feedbackController = TextEditingController();
    final founderUid = FirebaseAuth.instance.currentUser?.uid ?? 'founder_demo';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Send Follow-Up / Reminder to ${msg.studentName}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1B4B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF6B7280),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'For opportunity: ${msg.opportunityTitle}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),

              // Preset Follow-Up Suggestion Chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(
                      Icons.description_outlined,
                      size: 14,
                      color: Color(0xFF0F4C81),
                    ),
                    label: const Text(
                      'Document Reminder',
                      style: TextStyle(fontSize: 12),
                    ),
                    onPressed: () => feedbackController.text =
                        'Reminder: Please submit the requested documents/resume before the deadline so we can finalize your review.',
                  ),
                  ActionChip(
                    avatar: const Icon(
                      Icons.replay_rounded,
                      size: 14,
                      color: Color(0xFF0F4C81),
                    ),
                    label: const Text(
                      'Application Reconsidered',
                      style: TextStyle(fontSize: 12),
                    ),
                    onPressed: () => feedbackController.text =
                        'Good news! We have reconsidered your application and would love to move forward. Please check your inbox for details.',
                  ),
                  ActionChip(
                    avatar: const Icon(
                      Icons.calendar_month_outlined,
                      size: 14,
                      color: Color(0xFF0F4C81),
                    ),
                    label: const Text(
                      'Interview Slot Reminder',
                      style: TextStyle(fontSize: 12),
                    ),
                    onPressed: () => feedbackController.text =
                        'Friendly reminder regarding your scheduled interview slot. Let us know if you need to reschedule.',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextField(
                controller: feedbackController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Type your follow-up message or reminder here...',
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF0F4C81),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final text = feedbackController.text.trim();
                    if (text.isEmpty) return;

                    Navigator.pop(context);

                    await _firestoreService.sendFounderFeedback(
                      founderUid: founderUid,
                      studentUid: msg.studentUid,
                      studentName: msg.studentName,
                      opportunityTitle: msg.opportunityTitle,
                      messageText: text,
                    );

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Follow-up message sent successfully to ${msg.studentName}!',
                          ),
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      );
                      setState(() {});
                    }
                  },
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text(
                    'Send Follow-Up Message',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F4C81),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgClr = Color(0xFFF3F0FF);
    const textColor = Color(0xFF1E1B4B);
    const subtextColor = Color(0xFF6B7280);

    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? 'founder_demo';

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
        title: const Text(
          'Sent Feedback & Messages',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<FounderMessageModel>>(
        stream: _firestoreService.streamFounderMessages(currentUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0F4C81)),
            );
          }

          final messages = snapshot.data ?? [];

          if (messages.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 64,
                    color: Color(0xFF9CA3AF),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No messages sent yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Feedback sent to candidates will appear here.',
                    style: TextStyle(fontSize: 14, color: subtextColor),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              final timeAgo = _formatRelativeTime(msg.sentAt);

              return Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.only(bottom: 14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _showSendFollowUpDialog(msg),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: const Color(0xFFEEF2FF),
                                    child: Text(
                                      msg.studentName.isNotEmpty
                                          ? msg.studentName[0].toUpperCase()
                                          : 'S',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F4C81),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          msg.studentName,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'For: ${msg.opportunityTitle}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: subtextColor,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    timeAgo,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F4C81),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 20,
                                    color: Color(0xFFEF4444),
                                  ),
                                  tooltip: 'Delete Message',
                                  onPressed: () =>
                                      _confirmDeleteMessage(msg.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Color(0xFFE5E7EB)),
                        const SizedBox(height: 8),
                        Text(
                          msg.messageText,
                          style: const TextStyle(
                            fontSize: 14,
                            color: textColor,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Action button to send follow up / reminder
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => _showSendFollowUpDialog(msg),
                            icon: const Icon(
                              Icons.reply_rounded,
                              size: 16,
                              color: Color(0xFF0F4C81),
                            ),
                            label: const Text(
                              'Send Follow-up / Reminder',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F4C81),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
