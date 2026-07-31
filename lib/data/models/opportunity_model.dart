import 'package:cloud_firestore/cloud_firestore.dart';

class OpportunityModel {
  final String id;
  final String category; // 'Scholarship', 'Internship', 'Fellowship', 'Engineering', etc.
  final String title;
  final String provider;
  final String subtitle;
  final String description;
  final String eligibility;
  final List<String> eligibleCountries;
  final DateTime deadline;
  final String? applicationUrl;
  final DateTime createdAt;

  // Founder / Startup Fields
  final String? postedByUid;
  final bool isActive;
  final String workType; // 'Remote', 'On Campus', 'Hybrid'
  final String commitment; // 'Part Time', 'Full Time', 'Project Based'
  final String location;
  final String hoursPerWeek;
  final List<String> skills;
  final int viewsCount;
  final int applicantsCount;

  OpportunityModel({
    required this.id,
    required this.category,
    required this.title,
    required this.provider,
    required this.subtitle,
    required this.description,
    required this.eligibility,
    required this.eligibleCountries,
    required this.deadline,
    this.applicationUrl,
    DateTime? createdAt,
    this.postedByUid,
    this.isActive = true,
    this.workType = 'Remote',
    this.commitment = 'Part Time',
    this.location = 'Kigali, Rwanda',
    this.hoursPerWeek = '20 hrs/week',
    this.skills = const [],
    this.viewsCount = 0,
    this.applicantsCount = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  int get daysLeft {
    final diff = deadline.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  bool get isUrgent => daysLeft <= 14;
  bool get isClosed => !isActive;

  String get deadlineFormattedText => '$daysLeft days left';

  factory OpportunityModel.fromMap(Map<String, dynamic> map, String id) {
    return OpportunityModel(
      id: id,
      category: map['category'] ?? 'Scholarship',
      title: map['title'] ?? '',
      provider: map['provider'] ?? '',
      subtitle: map['subtitle'] ?? '',
      description: map['description'] ?? '',
      eligibility: map['eligibility'] ?? '',
      eligibleCountries: List<String>.from(map['eligibleCountries'] ?? []),
      deadline: (map['deadline'] as Timestamp?)?.toDate() ?? DateTime.now().add(const Duration(days: 30)),
      applicationUrl: map['applicationUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      postedByUid: map['postedByUid'],
      isActive: map['isActive'] ?? true,
      workType: map['workType'] ?? 'Remote',
      commitment: map['commitment'] ?? 'Part Time',
      location: map['location'] ?? 'Kigali, Rwanda',
      hoursPerWeek: map['hoursPerWeek'] ?? '20 hrs/week',
      skills: List<String>.from(map['skills'] ?? []),
      viewsCount: map['viewsCount'] ?? 0,
      applicantsCount: map['applicantsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'provider': provider,
      'subtitle': subtitle,
      'description': description,
      'eligibility': eligibility,
      'eligibleCountries': eligibleCountries,
      'deadline': Timestamp.fromDate(deadline),
      'applicationUrl': applicationUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'postedByUid': postedByUid,
      'isActive': isActive,
      'workType': workType,
      'commitment': commitment,
      'location': location,
      'hoursPerWeek': hoursPerWeek,
      'skills': skills,
      'viewsCount': viewsCount,
      'applicantsCount': applicantsCount,
    };
  }

  OpportunityModel copyWith({
    String? category,
    String? title,
    String? provider,
    String? subtitle,
    String? description,
    String? eligibility,
    List<String>? eligibleCountries,
    DateTime? deadline,
    String? applicationUrl,
    bool? isActive,
    String? workType,
    String? commitment,
    String? location,
    String? hoursPerWeek,
    List<String>? skills,
    int? viewsCount,
    int? applicantsCount,
  }) {
    return OpportunityModel(
      id: id,
      category: category ?? this.category,
      title: title ?? this.title,
      provider: provider ?? this.provider,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      eligibility: eligibility ?? this.eligibility,
      eligibleCountries: eligibleCountries ?? this.eligibleCountries,
      deadline: deadline ?? this.deadline,
      applicationUrl: applicationUrl ?? this.applicationUrl,
      createdAt: createdAt,
      postedByUid: postedByUid,
      isActive: isActive ?? this.isActive,
      workType: workType ?? this.workType,
      commitment: commitment ?? this.commitment,
      location: location ?? this.location,
      hoursPerWeek: hoursPerWeek ?? this.hoursPerWeek,
      skills: skills ?? this.skills,
      viewsCount: viewsCount ?? this.viewsCount,
      applicantsCount: applicantsCount ?? this.applicantsCount,
    );
  }
}
