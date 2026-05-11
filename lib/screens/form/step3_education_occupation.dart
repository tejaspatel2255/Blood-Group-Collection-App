import 'package:flutter/material.dart';
import '../../models/family_model.dart';
import '../../core/constants/dropdown_data.dart';
import '../../widgets/custom_dropdown.dart';

class Step3EducationOccupation extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final HeadOfFamily hof;

  const Step3EducationOccupation({
    super.key,
    required this.formKey,
    required this.hof,
  });

  @override
  State<Step3EducationOccupation> createState() => _Step3EducationOccupationState();
}

class _Step3EducationOccupationState extends State<Step3EducationOccupation> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomDropdown(
            label: 'Education Level *',
            items: DropdownData.educationLevels,
            selectedItem: widget.hof.education.isNotEmpty ? widget.hof.education : null,
            onChanged: (v) => widget.hof.education = v ?? '',
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          CustomDropdown(
            label: 'Occupation *',
            items: DropdownData.occupations,
            selectedItem: widget.hof.occupation.isNotEmpty ? widget.hof.occupation : null,
            onChanged: (v) => widget.hof.occupation = v ?? '',
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
        ],
      ),
    );
  }
}
