import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ApplicationModel {
  final String id;
  final String opportunityId;
  final String opportunityTitle;
  final String companyName;
  final String applicantUid;
  final String coverLetter;
  final String availability;
  final String? portfolioUrl;
  final String status; // 'Applied', 'Under Review', 'Shortlisted', 'Accepted', 'Rejected'
  final DateTime appliedAt;

  ApplicationModel({
    required this.id,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.companyName,
    required this.applicantUid,
    required this.coverLetter,
    required this.availability,
    this.portfolioUrl,
    this.status = 'Applied',
    DateTime? appliedAt,
  }) : appliedAt = appliedAt ?? DateTime.now();

  String get timeAgo {
    final diff = DateTime.now().difference(appliedAt);
    if (diff.inMinutes < 60) return 'Applied ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Applied ${diff.inHours}h ago';
    return 'Applied ${diff.inDays}d ago';
  }

  Color get statusColor {
    switch (status) {
      case 'Applied':
        return const Color(0xFF3B82F6); // Blue
      case 'Under Review':
        return const Color(0xFFF59E0B); // Orange
      case 'Shortlisted':
        return const Color(0xFF8B5CF6); // Purple
      case 'Accepted':
        return const Color(0xFF10B981); // Green
      case 'Rejected':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF6B7280);
    }
  }

  factory ApplicationModel.fromMap(Map<String, dynamic> map, String id) {
    return ApplicationModel(
      id: id,
      opportunityId: map['opportunityId'] ?? '',
      opportunityTitle: map['opportunityTitle'] ?? '',
      companyName: map['companyName'] ?? '',
      applicantUid: map['applicantUid'] ?? '',
      coverLetter: map['coverLetter'] ?? '',
      availability: map['availability'] ?? '',
      portfolioUrl: map['portfolioUrl'],
      status: map['status'] ?? 'Applied',
      appliedAt: (map['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'opportunityId': opportunityId,
      'opportunityTitle': opportunityTitle,
      'companyName': companyName,
      'applicantUid': applicantUid,
      'coverLetter': coverLetter,
      'availability': availability,
      'portfolioUrl': portfolioUrl,
      'status': status,
      'appliedAt': Timestamp.fromDate(appliedAt),
    };
  }
}