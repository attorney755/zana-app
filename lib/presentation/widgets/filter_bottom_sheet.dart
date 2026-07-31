import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class FilterBottomSheet extends StatefulWidget {
  final String selectedCategory;
  final String selectedWorkType;
  final String selectedCommitment;
  final Function(String category, String workType, String commitment) onApplyFilters;

  const FilterBottomSheet({
    super.key,
    this.selectedCategory = 'All',
    this.selectedWorkType = 'All',
    this.selectedCommitment = 'All',
    required this.onApplyFilters,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _category;
  late String _workType;
  late String _commitment;

  final List<String> _categories = ['All', 'Design', 'Engineering', 'Marketing', 'Data', 'Other'];
  final List<String> _workTypes = ['All', 'Remote', 'On Campus', 'Hybrid'];
  final List<String> _commitments = ['All', 'Part Time', 'Full Time', 'Project Based'];

  @override
  void initState() {
    super.initState();
    _category = widget.selectedCategory;
    _workType = widget.selectedWorkType;
    _commitment = widget.selectedCommitment;
  }

  void _reset() {
    setState(() {
      _category = 'All';
      _workType = 'All';
      _commitment = 'All';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header: "Filters" + "Reset"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: _reset,
                child: const Text(
                  'Reset',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 12),

          // Category Section
          const Text(
            'Category',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((cat) => _buildChip(cat, _category == cat, (selected) {
              setState(() => _category = cat);
            })).toList(),
          ),
          const SizedBox(height: 20),

          // Work Type Section
          const Text(
            'Work Type',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _workTypes.map((type) => _buildChip(type, _workType == type, (selected) {
              setState(() => _workType = type);
            })).toList(),
          ),
          const SizedBox(height: 20),

          // Commitment Section
          const Text(
            'Commitment',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _commitments.map((com) => _buildChip(com, _commitment == com, (selected) {
              setState(() => _commitment = com);
            })).toList(),
          ),
          const SizedBox(height: 28),

          // Apply Filters Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onApplyFilters(_category, _workType, _commitment);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, Function(bool) onSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: const Color(0xFFF3F4F6),
      selectedColor: AppColors.primaryLight,
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
        ),
      ),
      showCheckmark: false,
    );
  }
}