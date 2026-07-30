class FounderMessageModel {
  final String id;
  final String founderUid;
  final String studentUid;
  final String studentName;
  final String opportunityTitle;
  final String messageText;
  final DateTime sentAt;

  FounderMessageModel({
    required this.id,
    required this.founderUid,
    required this.studentUid,
    required this.studentName,
    required this.opportunityTitle,
    required this.messageText,
    required this.sentAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'founderUid': founderUid,
      'studentUid': studentUid,
      'studentName': studentName,
      'opportunityTitle': opportunityTitle,
      'messageText': messageText,
      'sentAt': sentAt.toIso8601String(),
    };
  }

  factory FounderMessageModel.fromMap(Map<String, dynamic> map, String id) {
    return FounderMessageModel(
      id: id,
      founderUid: map['founderUid'] ?? '',
      studentUid: map['studentUid'] ?? '',
      studentName: map['studentName'] ?? 'Applicant',
      opportunityTitle: map['opportunityTitle'] ?? 'Opportunity',
      messageText: map['messageText'] ?? '',
      sentAt: map['sentAt'] != null ? DateTime.parse(map['sentAt']) : DateTime.now(),
    );
  }
}