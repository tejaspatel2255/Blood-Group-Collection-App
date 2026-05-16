import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/dropdown_data.dart';
import '../../models/family_model.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';

class Step3EducationOccupation extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final FamilyModel family;

  const Step3EducationOccupation({
    super.key,
    required this.formKey,
    required this.family,
  });

  @override
  State<Step3EducationOccupation> createState() => _Step3EducationOccupationState();
}

class _Step3EducationOccupationState extends State<Step3EducationOccupation> {
  late TextEditingController _educationOtherController;
  late TextEditingController _occupationOtherController;

  static final _textRegex = RegExp(r'^[a-zA-Z\s\.]+$');

  @override
  void initState() {
    super.initState();
    _educationOtherController  = TextEditingController(text: widget.family.educationOther);
    _occupationOtherController = TextEditingController(text: widget.family.occupationOther);
  }

  @override
  void dispose() {
    _educationOtherController.dispose();
    _occupationOtherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Education Dropdown
          CustomDropdown(
            label: 'Education Level *',
            items: DropdownData.educationList,
            selectedItem: widget.family.education.isNotEmpty ? widget.family.education : null,
            onChanged: (v) => setState(() => widget.family.education = v ?? ''),
            validator: (v) => (v == null || v.isEmpty) ? 'Education Level is required' : null,
          ),
          if (widget.family.education == 'Other')
            CustomTextField(
              label: 'Please specify education *',
              controller: _educationOtherController,
              textCapitalization: TextCapitalization.words,
              validator: (v) {
                final val = v?.trim() ?? '';
                widget.family.educationOther = val;
                if (val.isEmpty) return 'Education details are required';
                if (val.length < 2) return 'Education must be at least 2 characters';
                if (val.length > 100) return 'Too long (max 100 chars)';
                if (!_textRegex.hasMatch(val)) return 'Invalid characters in education';
                return null;
              },
            ),
          const SizedBox(height: 8),

          // Occupation Dropdown
          CustomDropdown(
            label: 'Occupation *',
            items: DropdownData.occupationList,
            selectedItem: widget.family.occupation.isNotEmpty ? widget.family.occupation : null,
            onChanged: (v) => setState(() => widget.family.occupation = v ?? ''),
            validator: (v) => (v == null || v.isEmpty) ? 'Occupation is required' : null,
          ),
          if (widget.family.occupation == 'Other')
            CustomTextField(
              label: 'Please specify occupation *',
              controller: _occupationOtherController,
              textCapitalization: TextCapitalization.words,
              validator: (v) {
                final val = v?.trim() ?? '';
                widget.family.occupationOther = val;
                if (val.isEmpty) return 'Occupation details are required';
                if (val.length < 2) return 'Occupation must be at least 2 characters';
                if (val.length > 100) return 'Too long (max 100 chars)';
                if (!_textRegex.hasMatch(val)) return 'Invalid characters in occupation';
                return null;
              },
            ),
          const SizedBox(height: 8),

          // Annual Income Dropdown
          CustomDropdown(
            label: 'Annual Income *',
            items: DropdownData.annualIncomeList,
            selectedItem: widget.family.annualIncome.isNotEmpty ? widget.family.annualIncome : null,
            onChanged: (v) => setState(() => widget.family.annualIncome = v ?? ''),
            validator: (v) => (v == null || v.isEmpty) ? 'Annual Income is required' : null,
          ),
        ],
      ),
    );
  }
}
