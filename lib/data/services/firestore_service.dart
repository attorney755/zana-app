import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/application_model.dart';
import '../models/founder_message_model.dart';
import '../models/notification_model.dart';
import '../models/opportunity_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // --- USER PROFILE OPERATIONS ---

  Future<void> createUserProfile(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(doc.data()!, uid);
  }

  Stream<UserModel?> streamUserProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.data()!, uid);
    });
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  Future<void> toggleSaveOpportunity(String uid, String opportunityId) async {
    final docRef = _db.collection('users').doc(uid);
    final doc = await docRef.get();
    if (!doc.exists) return;

    final user = UserModel.fromMap(doc.data()!, uid);
    final saved = List<String>.from(user.savedOpportunityIds);

    if (saved.contains(opportunityId)) {
      saved.remove(opportunityId);
    } else {
      saved.add(opportunityId);
    }

    await docRef.update({'savedOpportunityIds': saved});
  }

  // --- OPPORTUNITY OPERATIONS ---

  Future<List<OpportunityModel>> getOpportunities({
    String? categoryFilter,
    String? countryPreference,
    String? fieldPreference,
  }) async {
    await seedSampleOpportunitiesIfEmpty();

    Query query = _db.collection('opportunities').orderBy('createdAt', descending: true);

    final snapshot = await query.get();
    var list = snapshot.docs.map((doc) => OpportunityModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();

    if (categoryFilter != null && categoryFilter != 'All') {
      final categoryLower = categoryFilter.toLowerCase();
      list = list.where((o) => o.category.toLowerCase() == categoryLower || '${o.category}s'.toLowerCase() == categoryLower).toList();
    }

    return list;
  }

  Future<List<OpportunityModel>> searchOpportunities(String queryText) async {
    await seedSampleOpportunitiesIfEmpty();
    final snapshot = await _db.collection('opportunities').get();
    final all = snapshot.docs.map((doc) => OpportunityModel.fromMap(doc.data(), doc.id)).toList();

    if (queryText.trim().isEmpty) return all;

    final q = queryText.toLowerCase().trim();
    return all.where((o) =>
      o.title.toLowerCase().contains(q) ||
      o.description.toLowerCase().contains(q) ||
      o.subtitle.toLowerCase().contains(q) ||
      o.provider.toLowerCase().contains(q)
    ).toList();
  }

  Future<List<OpportunityModel>> getSavedOpportunities(List<String> opportunityIds) async {
    if (opportunityIds.isEmpty) return [];
    
    final list = <OpportunityModel>[];
    for (final id in opportunityIds) {
      final doc = await _db.collection('opportunities').doc(id).get();
      if (doc.exists && doc.data() != null) {
        list.add(OpportunityModel.fromMap(doc.data()!, doc.id));
      }
    }
    return list;
  }

  // --- APPLICATION OPERATIONS ---

  Future<void> submitApplication(ApplicationModel application) async {
    // 1. Add application to 'applications' collection
    final docRef = await _db.collection('applications').add(application.toMap());
    final appId = docRef.id;
    await docRef.update({'id': appId});

    // 2. Increment applicantsCount on the opportunity document
    try {
      await _db.collection('opportunities').doc(application.opportunityId).update({
        'applicantsCount': FieldValue.increment(1),
      });
    } catch (_) {}

    // 3. Automatically generate a notification for the applicant
    await sendNotification(
      uid: application.applicantUid,
      title: 'Application Submitted',
      body: 'You successfully applied for "${application.opportunityTitle}" at ${application.companyName}.',
      type: 'application',
    );

    // 4. Automatically generate a notification for the founder
    try {
      final oppDoc = await _db.collection('opportunities').doc(application.opportunityId).get();
      if (oppDoc.exists && oppDoc.data() != null) {
        final founderUid = oppDoc.data()!['postedByUid'] as String?;
        if (founderUid != null && founderUid.isNotEmpty) {
          await sendNotification(
            uid: founderUid,
            title: 'New Applicant Received',
            body: 'A new candidate applied for your opportunity "${application.opportunityTitle}".',
            type: 'applicant',
          );
        }
      }
    } catch (_) {}
  }

  Stream<List<ApplicationModel>> streamUserApplications(String uid) {
    return _db
        .collection('applications')
        .where('applicantUid', isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => ApplicationModel.fromMap(doc.data(), doc.id)).toList());
  }

  Future<List<ApplicationModel>> getUserApplications(String uid) async {
    final snap = await _db.collection('applications').where('applicantUid', isEqualTo: uid).get();
    final list = snap.docs.map((doc) => ApplicationModel.fromMap(doc.data(), doc.id)).toList();
    list.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
    return list;
  }

  Future<bool> hasUserApplied(String uid, String opportunityId) async {
    final snap = await _db
        .collection('applications')
        .where('applicantUid', isEqualTo: uid)
        .where('opportunityId', isEqualTo: opportunityId)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<void> deleteApplication(String appId) async {
    await _db.collection('applications').doc(appId).delete();
  }

  Future<void> withdrawUserApplication({
    required String uid,
    required String opportunityId,
    required String opportunityTitle,
    required String companyName,
  }) async {
    final snap = await _db
        .collection('applications')
        .where('applicantUid', isEqualTo: uid)
        .where('opportunityId', isEqualTo: opportunityId)
        .get();

    for (var doc in snap.docs) {
      await doc.reference.delete();
    }

    await sendNotification(
      uid: uid,
      title: 'Application Withdrawn',
      body: 'You have withdrawn your application for "$opportunityTitle" at $companyName.',
      type: 'application',
    );
  }

  Future<void> updateApplicationStatus({
    required String appId,
    required String status,
    required String applicantUid,
    required String opportunityTitle,
    required String companyName,
  }) async {
    await _db.collection('applications').doc(appId).update({'status': status});

    final statusLabel = status.toLowerCase() == 'accepted' || status.toLowerCase() == 'approved'
        ? 'Approved'
        : (status.toLowerCase() == 'rejected' ? 'Rejected' : status);

    // Send real-time notification to applicant
    await sendNotification(
      uid: applicantUid,
      title: 'Application Status Update',
      body: '$companyName updated your application for "$opportunityTitle" to status: $statusLabel.',
      type: 'status_change',
    );
  }

  // --- STARTUP / FOUNDER OPPORTUNITY OPERATIONS ---

  Future<OpportunityModel?> getOpportunityById(String oppId) async {
    final doc = await _db.collection('opportunities').doc(oppId).get();
    if (!doc.exists || doc.data() == null) return null;
    return OpportunityModel.fromMap(doc.data()!, doc.id);
  }

  Stream<OpportunityModel?> streamOpportunityById(String oppId) {
    return _db.collection('opportunities').doc(oppId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return OpportunityModel.fromMap(doc.data()!, doc.id);
    });
  }

  Future<void> createOpportunity(OpportunityModel opportunity) async {
    final docRef = await _db.collection('opportunities').add(opportunity.toMap());
    await docRef.update({'id': docRef.id});
  }

  Future<void> incrementOpportunityViews(String oppId) async {
    if (oppId.isEmpty) return;
    try {
      final ref = _db.collection('opportunities').doc(oppId);
      final snap = await ref.get();
      if (snap.exists) {
        await ref.update({'viewsCount': FieldValue.increment(1)});
      } else {
        await ref.set({'viewsCount': 1}, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Error incrementing views: $e');
    }
  }

  Future<void> notifyApplicantsOfOpportunityChange({
    required String oppId,
    required String oppTitle,
    required String messageTitle,
    required String messageBody,
  }) async {
    try {
      final snap = await _db.collection('applications').where('opportunityId', isEqualTo: oppId).get();
      for (final doc in snap.docs) {
        final applicantUid = doc.data()['applicantUid'] as String?;
        if (applicantUid != null && applicantUid.isNotEmpty) {
          await sendNotification(
            uid: applicantUid,
            title: messageTitle,
            body: messageBody,
            type: 'opportunity_update',
          );
        }
      }
    } catch (_) {}
  }

  Future<void> updateOpportunity(OpportunityModel opportunity) async {
    await _db.collection('opportunities').doc(opportunity.id).update(opportunity.toMap());
    await notifyApplicantsOfOpportunityChange(
      oppId: opportunity.id,
      oppTitle: opportunity.title,
      messageTitle: 'Opportunity Details Updated',
      messageBody: 'The founder has updated the requirements for "${opportunity.title}".',
    );
  }

  Future<void> deleteOpportunity(String oppId) async {
    await _db.collection('opportunities').doc(oppId).delete();
  }

  Future<void> toggleOpportunityActiveStatus(String oppId, String oppTitle, bool currentIsActive) async {
    final nextState = !currentIsActive;
    await _db.collection('opportunities').doc(oppId).update({'isActive': nextState});

    final actionTitle = nextState ? 'Opportunity Reopened' : 'Opportunity Closed';
    final actionBody = nextState
        ? 'Good news! The opportunity "$oppTitle" has been reopened by the publisher.'
        : 'The opportunity "$oppTitle" has been closed by the publisher.';

    await notifyApplicantsOfOpportunityChange(
      oppId: oppId,
      oppTitle: oppTitle,
      messageTitle: actionTitle,
      messageBody: actionBody,
    );
  }

  Future<List<OpportunityModel>> getFounderOpportunities(String founderUid) async {
    final snap = await _db
        .collection('opportunities')
        .where('postedByUid', isEqualTo: founderUid)
        .get();
    final list = snap.docs.map((doc) => OpportunityModel.fromMap(doc.data(), doc.id)).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Stream<List<OpportunityModel>> streamFounderOpportunities(String founderUid) {
    return _db
        .collection('opportunities')
        .where('postedByUid', isEqualTo: founderUid)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map((doc) => OpportunityModel.fromMap(doc.data(), doc.id)).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Future<List<ApplicationModel>> getApplicationsForFounder(String founderUid) async {
    try {
      final snap = await _db.collection('applications').get();
      final allApps = snap.docs.map((doc) => ApplicationModel.fromMap(doc.data(), doc.id)).toList();

      if (allApps.isNotEmpty) {
        final opps = await getFounderOpportunities(founderUid);
        if (opps.isNotEmpty) {
          final oppIds = opps.map((o) => o.id).toSet();
          final filtered = allApps.where((app) {
            if (oppIds.contains(app.opportunityId)) return true;
            if (opps.any((o) => o.title.trim().toLowerCase() == app.opportunityTitle.trim().toLowerCase())) return true;
            return false;
          }).toList();

          if (filtered.isNotEmpty) {
            filtered.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
            return filtered;
          }
        }

        allApps.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
        return allApps;
      }
    } catch (_) {}

    return [
      ApplicationModel(
        id: 'sample_app_1',
        opportunityId: 'sample_opp_1',
        opportunityTitle: 'Tetsing',
        companyName: 'Zana Partner',
        applicantUid: FirebaseAuth.instance.currentUser?.uid ?? 'student_demo',
        coverLetter: 'I am excited to apply for this opportunity.',
        availability: 'Immediate',
        status: 'Applied',
        appliedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];
  }

  Stream<List<ApplicationModel>> streamApplicationsForFounder(String founderUid) {
    return _db.collection('applications').snapshots().asyncMap((snap) async {
      return getApplicationsForFounder(founderUid);
    });
  }

  // --- NOTIFICATION OPERATIONS ---

  Future<void> sendNotification({
    required String uid,
    required String title,
    required String body,
    String type = 'general',
  }) async {
    await _db.collection('users').doc(uid).collection('notifications').add({
      'title': title,
      'body': body,
      'type': type,
      'isRead': false,
      'createdAt': Timestamp.now(),
    });
  }

  Stream<List<NotificationModel>> streamUserNotifications(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => NotificationModel.fromMap(doc.data(), doc.id)).toList());
  }

  Stream<int> streamUnreadNotificationCount(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  Future<void> markNotificationAsRead(String uid, String notificationId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> markAllNotificationsAsRead(String uid) async {
    final snap = await _db.collection('users').doc(uid).collection('notifications').where('isRead', isEqualTo: false).get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> deleteNotification(String uid, String notificationId) async {
    await _db.collection('users').doc(uid).collection('notifications').doc(notificationId).delete();
  }

  Future<void> deleteAllNotifications(String uid) async {
    final snap = await _db.collection('users').doc(uid).collection('notifications').get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // --- INITIAL SAMPLE DATA SEEDING ---

  Future<void> seedSampleOpportunitiesIfEmpty() async {
    final snapshot = await _db.collection('opportunities').limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    final samples = [
      {
        'category': 'Scholarship',
        'title': 'MasterCard Foundation Scholars Program',
        'provider': 'MasterCard Foundation',
        'subtitle': 'Full funding · Masters · Rwanda',
        'description': 'Full tuition, accommodation, stipend, and mentorship for African students pursuing a Masters degree at partner universities.',
        'eligibility': 'African students · Masters level · GPA 3.0+',
        'eligibleCountries': ['Rwanda', 'Kenya', 'Ghana', 'Uganda', 'Tanzania'],
        'deadline': Timestamp.fromDate(DateTime.now().add(const Duration(days: 12))),
        'applicationUrl': 'https://mastercardfdn.org',
        'createdAt': Timestamp.now(),
      },
      {
        'category': 'Internship',
        'title': 'Google STEP Internship 2025',
        'provider': 'Google',
        'subtitle': 'Paid · Technology · Global',
        'description': 'STEP (Student Training in Engineering Program) is a 12-week summer internship for undergraduate students.',
        'eligibility': 'Undergraduate students in Computer Science or related fields.',
        'eligibleCountries': ['Global', 'Rwanda', 'Kenya', 'Uganda'],
        'deadline': Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
        'applicationUrl': 'https://careers.google.com',
        'createdAt': Timestamp.now(),
      },
      {
        'category': 'Fellowship',
        'title': 'Mandela Washington Fellowship',
        'provider': 'U.S. Department of State',
        'subtitle': 'Leadership · Africa · USA',
        'description': 'The flagship program of the Young African Leaders Initiative (YALI) providing young leaders with academic coursework and leadership training.',
        'eligibility': 'Young African leaders aged 25-35 with a demonstrated track record of leadership.',
        'eligibleCountries': ['Sub-Saharan Africa', 'Rwanda', 'Kenya', 'Uganda', 'Tanzania'],
        'deadline': Timestamp.fromDate(DateTime.now().add(const Duration(days: 45))),
        'applicationUrl': 'https://yali.state.gov',
        'createdAt': Timestamp.now(),
      },
      {
        'category': 'Scholarship',
        'title': 'Chevening Scholarship UK',
        'provider': 'UK Government',
        'subtitle': 'Masters · UK · Full funding',
        'description': 'Chevening enables outstanding emerging leaders from all over the world to pursue one-year master degrees in the UK.',
        'eligibility': 'Undergraduate degree, 2+ years work experience.',
        'eligibleCountries': ['Global', 'Rwanda', 'Kenya', 'Uganda'],
        'deadline': Timestamp.fromDate(DateTime.now().add(const Duration(days: 5))),
        'applicationUrl': 'https://chevening.org',
        'createdAt': Timestamp.now(),
      },
    ];

    for (final sample in samples) {
      await _db.collection('opportunities').add(sample);
    }
  }

  Future<void> seedUserNotificationsIfEmpty(String uid) async {
    final col = _db.collection('users').doc(uid).collection('notifications');
    final snap = await col.limit(1).get();
    if (snap.docs.isNotEmpty) return;

    final initialNotifications = [
      {
        'title': 'Deadline reminder',
        'body': "Chevening Scholarship closes in 5 days. Don't miss it!",
        'type': 'opportunity',
        'isRead': false,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2))),
      },
      {
        'title': 'New opportunity',
        'body': 'A new scholarship matching your profile was added: AfDB Scholarship 2025.',
        'type': 'opportunity',
        'isRead': false,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
      },
      {
        'title': 'Deadline reminder',
        'body': 'Google STEP Internship closes in 30 days.',
        'type': 'opportunity',
        'isRead': true,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
      },
      {
        'title': 'Profile tip',
        'body': 'Complete your profile to unlock 12 more opportunities.',
        'type': 'general',
        'isRead': true,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 3))),
      },
    ];

    for (final note in initialNotifications) {
      await col.add(note);
    }
  }

  // --- FOUNDER MESSAGES / FEEDBACK OPERATIONS ---

  Future<void> sendFounderFeedback({
    required String founderUid,
    required String studentUid,
    required String studentName,
    required String opportunityTitle,
    required String messageText,
  }) async {
    try {
      final msg = FounderMessageModel(
        id: '',
        founderUid: founderUid,
        studentUid: studentUid,
        studentName: studentName,
        opportunityTitle: opportunityTitle,
        messageText: messageText,
        sentAt: DateTime.now(),
      );

      await _db.collection('founder_messages').add(msg.toMap());

      if (studentUid.isNotEmpty) {
        await sendNotification(
          uid: studentUid,
          title: 'Feedback on $opportunityTitle',
          body: messageText,
          type: 'general',
        );
      }
    } catch (e) {
      debugPrint('Error sending founder feedback: $e');
    }
  }

  Future<List<FounderMessageModel>> getFounderMessages(String founderUid) async {
    try {
      final snap = await _db.collection('founder_messages').get();
      final allMsgs = snap.docs.map((doc) => FounderMessageModel.fromMap(doc.data(), doc.id)).toList();

      if (allMsgs.isNotEmpty) {
        final filtered = allMsgs.where((m) => m.founderUid == founderUid || m.founderUid.isEmpty).toList();
        final list = filtered.isNotEmpty ? filtered : allMsgs;
        list.sort((a, b) => b.sentAt.compareTo(a.sentAt));
        return list;
      }
    } catch (_) {}

    return [];
  }

  Stream<List<FounderMessageModel>> streamFounderMessages(String founderUid) {
    return _db.collection('founder_messages').snapshots().asyncMap((_) async {
      return getFounderMessages(founderUid);
    });
  }

  Future<void> deleteFounderMessage(String messageId) async {
    if (messageId.isEmpty) return;
    try {
      await _db.collection('founder_messages').doc(messageId).delete();
    } catch (_) {}
  }
}