import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String accountType; // 'student' or 'founder'
  final String? companyName;
  final String? country;
  final String? fieldOfStudy;
  final String? educationLevel;
  final List<String> interests;
  final bool deadlineReminders;
  final bool onboardingCompleted;
  final List<String> savedOpportunityIds;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    this.accountType = 'student',
    this.companyName,
    this.country,
    this.fieldOfStudy,
    this.educationLevel,
    this.interests = const [],
    this.deadlineReminders = true,
    this.onboardingCompleted = false,
    this.savedOpportunityIds = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get firstName {
    if (fullName.trim().isEmpty) return 'User';
    return fullName.trim().split(' ').first;
  }

  String get initials {
    final displayName = companyName?.trim().isNotEmpty == true
        ? companyName!.trim()
        : (fullName.trim().isNotEmpty ? fullName.trim() : 'User');

    final parts = displayName.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0].toUpperCase()}${parts[1][0].toUpperCase()}';
    }
    if (parts.isNotEmpty && parts[0].length >= 2) {
      return parts[0].substring(0, 2).toUpperCase();
    }
    if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'ZT';
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      accountType: map['accountType'] ?? 'student',
      companyName: map['companyName'],
      country: map['country'],
      fieldOfStudy: map['fieldOfStudy'],
      educationLevel: map['educationLevel'],
      interests: List<String>.from(map['interests'] ?? []),
      deadlineReminders: map['deadlineReminders'] ?? true,
      onboardingCompleted: map['onboardingCompleted'] ?? false,
      savedOpportunityIds: List<String>.from(map['savedOpportunityIds'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'accountType': accountType,
      'companyName': companyName,
      'country': country,
      'fieldOfStudy': fieldOfStudy,
      'educationLevel': educationLevel,
      'interests': interests,
      'deadlineReminders': deadlineReminders,
      'onboardingCompleted': onboardingCompleted,
      'savedOpportunityIds': savedOpportunityIds,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? fullName,
    String? accountType,
    String? companyName,
    String? country,
    String? fieldOfStudy,
    String? educationLevel,
    List<String>? interests,
    bool? deadlineReminders,
    bool? onboardingCompleted,
    List<String>? savedOpportunityIds,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      fullName: fullName ?? this.fullName,
      accountType: accountType ?? this.accountType,
      companyName: companyName ?? this.companyName,
      country: country ?? this.country,
      fieldOfStudy: fieldOfStudy ?? this.fieldOfStudy,
      educationLevel: educationLevel ?? this.educationLevel,
      interests: interests ?? this.interests,
      deadlineReminders: deadlineReminders ?? this.deadlineReminders,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      savedOpportunityIds: savedOpportunityIds ?? this.savedOpportunityIds,
      createdAt: createdAt,
    );
  }
}