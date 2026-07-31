import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/opportunity_model.dart';
import '../../../data/services/firestore_service.dart';
import '../../widgets/startup_bottom_nav_bar.dart';

class PostOpportunityScreen extends StatefulWidget {
  final ValueChanged<int>? onNavTap;

  const PostOpportunityScreen({
    super.key,
    this.onNavTap,
  });

  @override
  State<PostOpportunityScreen> createState() => _PostOpportunityScreenState();
}

class _PostOpportunityScreenState extends State<PostOpportunityScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController(); // Empty by default
  final _hoursController = TextEditingController(); // Empty by default

  final _firestoreService = FirestoreService();

  String _category = '';
  String _workType = '';
  String _commitment = '';
  final List<String> _selectedEligibleCountries = [];
  bool _isLoading = false;

  final List<String> _categories = [
    'Scholarship',
    'Internship',
    'Fellowship',
    'Engineering',
    'Design',
    'Technology',
    'Business',
    'Grants',
  ];

  final Map<String, String> _countryFlags = {
    'Rwanda': '🇷🇼',
    'Kenya': '🇰🇪',
    'Uganda': '🇺🇬',
    'Tanzania': '🇹🇿',
    'Ghana': '🇬🇭',
    'Nigeria': '🇳🇬',
    'Global': '🌐',
  };

  final List<String> _availableCountries = [
    'Rwanda',
    'Kenya',
    'Uganda',
    'Tanzania',
    'Ghana',
    'Nigeria',
    'Global',
  ];

  final List<String> _workTypes = ['Remote', 'On Campus', 'Hybrid'];
  final List<String> _commitments = ['Part Time', 'Full Time', 'Project Based'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _submitOpportunity() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an opportunity title')),
      );
      return;
    }

    if (_category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description')),
      );
      return;
    }

    if (_selectedEligibleCountries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one eligible country')),
      );
      return;
    }

    if (_workType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a work type')),
      );
      return;
    }

    if (_commitment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a commitment level')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to post an opportunity.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userProfile = await _firestoreService.getUserProfile(user.uid);
      final providerName = userProfile?.companyName?.isNotEmpty == true
          ? userProfile!.companyName!
          : (userProfile?.fullName.isNotEmpty == true ? userProfile!.fullName : 'Startup Partner');

      final opportunity = OpportunityModel(
        id: '',
        category: _category,
        title: title,
        provider: providerName,
        subtitle: '$_commitment · $_workType · ${_locationController.text.trim().isNotEmpty ? _locationController.text.trim() : 'Kigali, Rwanda'}',
        description: description,
        eligibility: 'Open to candidates from ${_selectedEligibleCountries.join(', ')}',
        eligibleCountries: _selectedEligibleCountries,
        deadline: DateTime.now().add(const Duration(days: 30)),
        applicationUrl: 'https://zana.app',
        postedByUid: user.uid,
        isActive: true,
        workType: _workType,
        commitment: _commitment,
        location: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : 'Kigali, Rwanda',
        hoursPerWeek: _hoursController.text.trim().isNotEmpty ? _hoursController.text.trim() : '20 hrs/week',
        skills: const ['Problem Solving'],
      );

      await _firestoreService.createOpportunity(opportunity);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opportunity posted successfully! Redirecting...'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) {
          context.go('/startup/my-posts');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error posting opportunity: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgClr = Color(0xFFF3F0FF);
    const cardBg = Colors.white;
    const textColor = Color(0xFF1E1B4B);

    return Scaffold(
      backgroundColor: bgClr,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go('/startup/feed');
            }
          },
        ),
        title: const Text(
          'Post Opportunity',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card 1: Title & Category
            Card(
              color: cardBg,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Opportunity Title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Software Engineer Intern',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _categories.map((c) {
                        final selected = _category == c;
                        return ChoiceChip(
                          label: Text(c),
                          selected: selected,
                          selectedColor: const Color(0xFFEEF2FF),
                          backgroundColor: const Color(0xFFF8FAFC),
                          side: BorderSide(
                            color: selected ? const Color(0xFF0F4C81) : const Color(0xFFCBD5E1),
                            width: selected ? 1.5 : 1,
                          ),
                          labelStyle: TextStyle(
                            color: selected ? const Color(0xFF0F4C81) : textColor,
                            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                          ),
                          onSelected: (val) {
                            setState(() => _category = val ? c : '');
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Card 2: Description & Eligible Countries
            Card(
              color: cardBg,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Describe the role and responsibilities...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Eligible Countries', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableCountries.map((country) {
                        final flag = _countryFlags[country] ?? '';
                        final selected = _selectedEligibleCountries.contains(country);
                        return FilterChip(
                          label: Text('$flag  $country'),
                          selected: selected,
                          selectedColor: const Color(0xFFEEF2FF),
                          backgroundColor: const Color(0xFFF8FAFC),
                          checkmarkColor: const Color(0xFF0F4C81),
                          side: BorderSide(
                            color: selected ? const Color(0xFF0F4C81) : const Color(0xFFCBD5E1),
                            width: selected ? 1.5 : 1,
                          ),
                          labelStyle: TextStyle(
                            color: selected ? const Color(0xFF0F4C81) : textColor,
                            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                          ),
                          onSelected: (val) {
                            setState(() {
                              if (val) {
                                _selectedEligibleCountries.add(country);
                              } else {
                                _selectedEligibleCountries.remove(country);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Card 3: Work Parameters
            Card(
              color: cardBg,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Work Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _workTypes.map((wt) {
                        final selected = _workType == wt;
                        return ChoiceChip(
                          label: Text(wt),
                          selected: selected,
                          selectedColor: const Color(0xFFEEF2FF),
                          backgroundColor: const Color(0xFFF8FAFC),
                          side: BorderSide(
                            color: selected ? const Color(0xFF0F4C81) : const Color(0xFFCBD5E1),
                            width: selected ? 1.5 : 1,
                          ),
                          labelStyle: TextStyle(
                            color: selected ? const Color(0xFF0F4C81) : textColor,
                            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                          ),
                          onSelected: (val) {
                            setState(() => _workType = val ? wt : '');
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('Commitment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _commitments.map((cm) {
                        final selected = _commitment == cm;
                        return ChoiceChip(
                          label: Text(cm),
                          selected: selected,
                          selectedColor: const Color(0xFFEEF2FF),
                          backgroundColor: const Color(0xFFF8FAFC),
                          side: BorderSide(
                            color: selected ? const Color(0xFF0F4C81) : const Color(0xFFCBD5E1),
                            width: selected ? 1.5 : 1,
                          ),
                          labelStyle: TextStyle(
                            color: selected ? const Color(0xFF0F4C81) : textColor,
                            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                          ),
                          onSelected: (val) {
                            setState(() => _commitment = val ? cm : '');
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Kigali, Rwanda',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Hours per week', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _hoursController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. 20 hrs/week',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitOpportunity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F4C81),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('Post Opportunity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: StartupBottomNavBar(
        currentIndex: 1,
        onTap: widget.onNavTap ?? (index) {
          if (index == 0) context.go('/startup/feed');
          if (index == 1) context.go('/startup/my-posts');
          if (index == 2) context.go('/startup/applicants');
          if (index == 3) context.go('/startup/profile');
        },
      ),
    );
  }
}
