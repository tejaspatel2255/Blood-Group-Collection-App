import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _educationOtherController = TextEditingController(text: widget.family.educationOther);
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
        children: [
          CustomDropdown(
            label: 'Education',
            items: DropdownData.educationList,
            selectedItem: widget.family.education.isNotEmpty ? widget.family.education : null,
            onChanged: (v) {
              setState(() => widget.family.education = v ?? '');
            },
            validator: (v) => v == null ? 'Required' : null,
          ),
          if (widget.family.education == 'Other')
            CustomTextField(
              label: 'Specify Education',
              controller: _educationOtherController,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                widget.family.educationOther = v;
                return null;
              },
            ),
          const SizedBox(height: 16),
          CustomDropdown(
            label: 'Occupation',
            items: DropdownData.occupationList,
            selectedItem: widget.family.occupation.isNotEmpty ? widget.family.occupation : null,
            onChanged: (v) {
              setState(() => widget.family.occupation = v ?? '');
            },
            validator: (v) => v == null ? 'Required' : null,
          ),
          if (widget.family.occupation == 'Other')
            CustomTextField(
              label: 'Specify Occupation',
              controller: _occupationOtherController,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                widget.family.occupationOther = v;
                return null;
              },
            ),
          const SizedBox(height: 16),
          CustomDropdown(
            label: 'Annual Income',
            items: DropdownData.annualIncomeList,
            selectedItem: widget.family.annualIncome.isNotEmpty ? widget.family.annualIncome : null,
            onChanged: (v) {
              setState(() => widget.family.annualIncome = v ?? '');
            },
            validator: (v) => v == null ? 'Required' : null,
          ),
        ],
      ),
    );
  }
}
