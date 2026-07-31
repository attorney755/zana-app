import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/opportunity_model.dart';
import '../../../data/services/firestore_service.dart';
import '../../widgets/startup_bottom_nav_bar.dart';

class EditPostScreen extends StatefulWidget {
  final String opportunityId;

  const EditPostScreen({super.key, required this.opportunityId});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _hoursController = TextEditingController();

  final _firestoreService = FirestoreService();

  OpportunityModel? _existingOpp;
  String _category = 'Internship';
  String _workType = 'Remote';
  String _commitment = 'Part Time';
  List<String> _selectedEligibleCountries = ['Rwanda'];
  bool _isLoading = true;
  bool _isSubmitting = false;

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
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    final opp = await _firestoreService.getOpportunityById(
      widget.opportunityId,
    );
    if (opp != null && mounted) {
      setState(() {
        _existingOpp = opp;
        _titleController.text = opp.title;
        _descriptionController.text = opp.description;
        _locationController.text = opp.location;
        _hoursController.text = opp.hoursPerWeek;
        _category = _categories.contains(opp.category)
            ? opp.category
            : 'Internship';
        _workType = opp.workType.isNotEmpty ? opp.workType : 'Remote';
        _commitment = opp.commitment.isNotEmpty ? opp.commitment : 'Part Time';
        _selectedEligibleCountries = opp.eligibleCountries.isNotEmpty
            ? List<String>.from(opp.eligibleCountries)
            : ['Rwanda'];
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _submitUpdate() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an opportunity title')),
      );
      return;
    }

    if (_category.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
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
        const SnackBar(
          content: Text('Please select at least one eligible country'),
        ),
      );
      return;
    }

    if (_existingOpp == null) return;

    final user = FirebaseAuth.instance.currentUser;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final updatedOpp = OpportunityModel(
        id: _existingOpp!.id,
        category: _category,
        title: title,
        provider: _existingOpp!.provider,
        subtitle:
            '$_commitment · $_workType · ${_locationController.text.trim().isNotEmpty ? _locationController.text.trim() : 'Kigali, Rwanda'}',
        description: description,
        eligibility:
            'Open to candidates from ${_selectedEligibleCountries.join(', ')}',
        eligibleCountries: _selectedEligibleCountries,
        deadline: _existingOpp!.deadline,
        applicationUrl: _existingOpp!.applicationUrl,
        createdAt: _existingOpp!.createdAt,
        postedByUid: user?.uid ?? _existingOpp!.postedByUid,
        isActive: _existingOpp!.isActive,
        workType: _workType,
        commitment: _commitment,
        location: _locationController.text.trim().isNotEmpty
            ? _locationController.text.trim()
            : 'Kigali, Rwanda',
        hoursPerWeek: _hoursController.text.trim().isNotEmpty
            ? _hoursController.text.trim()
            : '20 hrs/week',
        skills: _existingOpp!.skills,
        viewsCount: _existingOpp!.viewsCount,
        applicantsCount: _existingOpp!.applicantsCount,
      );

      await _firestoreService.updateOpportunity(updatedOpp);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opportunity updated successfully!'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 2),
          ),
        );

        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          context.go('/startup/my-posts');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating opportunity: $e')),
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
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textColor,
            size: 20,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.pop();
            }
          },
        ),
        title: const Text(
          'Edit Opportunity',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0F4C81)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card 1: Title & Category
                  Card(
                    color: cardBg,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Opportunity Title',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              hintText: 'e.g. Software Engineer Intern',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Category',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
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
                                  color: selected
                                      ? const Color(0xFF0F4C81)
                                      : const Color(0xFFCBD5E1),
                                  width: selected ? 1.5 : 1,
                                ),
                                labelStyle: TextStyle(
                                  color: selected
                                      ? const Color(0xFF0F4C81)
                                      : textColor,
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                ),
                                onSelected: (val) {
                                  if (val) setState(() => _category = c);
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _descriptionController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText: 'Describe the role...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Eligible Countries',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _availableCountries.map((country) {
                              final flag = _countryFlags[country] ?? '';
                              final selected = _selectedEligibleCountries
                                  .contains(country);
                              return FilterChip(
                                label: Text('$flag  $country'),
                                selected: selected,
                                selectedColor: const Color(0xFFEEF2FF),
                                backgroundColor: const Color(0xFFF8FAFC),
                                checkmarkColor: const Color(0xFF0F4C81),
                                side: BorderSide(
                                  color: selected
                                      ? const Color(0xFF0F4C81)
                                      : const Color(0xFFCBD5E1),
                                  width: selected ? 1.5 : 1,
                                ),
                                labelStyle: TextStyle(
                                  color: selected
                                      ? const Color(0xFF0F4C81)
                                      : textColor,
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                ),
                                onSelected: (val) {
                                  setState(() {
                                    if (val) {
                                      _selectedEligibleCountries.add(country);
                                    } else {
                                      _selectedEligibleCountries.remove(
                                        country,
                                      );
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Work Type',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
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
                                  color: selected
                                      ? const Color(0xFF0F4C81)
                                      : const Color(0xFFCBD5E1),
                                  width: selected ? 1.5 : 1,
                                ),
                                labelStyle: TextStyle(
                                  color: selected
                                      ? const Color(0xFF0F4C81)
                                      : textColor,
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                ),
                                onSelected: (val) {
                                  if (val) setState(() => _workType = wt);
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Commitment',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
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
                                  color: selected
                                      ? const Color(0xFF0F4C81)
                                      : const Color(0xFFCBD5E1),
                                  width: selected ? 1.5 : 1,
                                ),
                                labelStyle: TextStyle(
                                  color: selected
                                      ? const Color(0xFF0F4C81)
                                      : textColor,
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                ),
                                onSelected: (val) {
                                  if (val) setState(() => _commitment = cm);
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Location',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _locationController,
                            decoration: const InputDecoration(
                              hintText: 'e.g. Kigali, Rwanda',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Hours per week',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
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
                      onPressed: _isSubmitting ? null : _submitUpdate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F4C81),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Update Opportunity',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
      bottomNavigationBar: StartupBottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) context.go('/startup/feed');
          if (index == 1) context.go('/startup/my-posts');
          if (index == 2) context.go('/startup/applicants');
          if (index == 3) context.go('/startup/profile');
        },
      ),
    );
  }
}
