import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/family_model.dart';
import '../../core/constants/dropdown_data.dart';
import '../../core/utils/age_calculator.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/photo_picker_widget.dart';
import 'package:intl/intl.dart';

class Step1BasicInfo extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final HeadOfFamily hof;
  final Function(File?) onPhotoSelected;
  final File? initialPhoto;

  const Step1BasicInfo({
    super.key,
    required this.formKey,
    required this.hof,
    required this.onPhotoSelected,
    this.initialPhoto,
  });

  @override
  State<Step1BasicInfo> createState() => _Step1BasicInfoState();
}

class _Step1BasicInfoState extends State<Step1BasicInfo> {
  late TextEditingController _firstNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _dobController;
  late TextEditingController _ageController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.hof.firstName);
    _middleNameController = TextEditingController(text: widget.hof.middleName);
    _lastNameController = TextEditingController(text: widget.hof.lastName);
    _dobController = TextEditingController(
      text: widget.hof.dob != null && widget.hof.age > 0 ? DateFormat('dd/MM/yyyy').format(widget.hof.dob!) : '',
    );
    _ageController = TextEditingController(text: widget.hof.age > 0 ? widget.hof.age.toString() : '');
    
    _firstNameController.addListener(() => widget.hof.firstName = _firstNameController.text);
    _middleNameController.addListener(() => widget.hof.middleName = _middleNameController.text);
    _lastNameController.addListener(() => widget.hof.lastName = _lastNameController.text);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.hof.dob ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        widget.hof.dob = picked;
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
        
        final age = AgeCalculator.calculateAge(picked);
        widget.hof.age = age;
        _ageController.text = age.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: PhotoPickerWidget(
              initialImage: widget.initialPhoto,
              onImageSelected: widget.onPhotoSelected,
              radius: 60,
            ),
          ),
          const SizedBox(height: 24),
          CustomTextField(
            label: 'First Name *',
            controller: _firstNameController,
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          CustomTextField(
            label: 'Middle Name',
            controller: _middleNameController,
          ),
          CustomTextField(
            label: 'Last Name *',
            controller: _lastNameController,
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          CustomDropdown(
            label: 'Blood Group *',
            items: DropdownData.bloodGroups,
            selectedItem: widget.hof.bloodGroup.isNotEmpty ? widget.hof.bloodGroup : null,
            onChanged: (v) => widget.hof.bloodGroup = v ?? '',
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          InkWell(
            onTap: () => _selectDate(context),
            child: IgnorePointer(
              child: CustomTextField(
                label: 'Date of Birth *',
                controller: _dobController,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
            ),
          ),
          CustomTextField(
            label: 'Age',
            controller: _ageController,
            readOnly: true,
          ),
          CustomDropdown(
            label: 'Marital Status *',
            items: DropdownData.maritalStatuses,
            selectedItem: widget.hof.maritalStatus.isNotEmpty ? widget.hof.maritalStatus : null,
            onChanged: (v) => widget.hof.maritalStatus = v ?? '',
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
        ],
      ),
    );
  }
}
