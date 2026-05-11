import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/member_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/dropdown_data.dart';
import '../../core/utils/age_calculator.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/photo_picker_widget.dart';
import 'package:intl/intl.dart';

class Step4FamilyComposition extends StatefulWidget {
  final List<MemberModel> members;
  final Function(List<MemberModel>) onMembersUpdated;

  const Step4FamilyComposition({
    super.key,
    required this.members,
    required this.onMembersUpdated,
  });

  @override
  State<Step4FamilyComposition> createState() => _Step4FamilyCompositionState();
}

class _Step4FamilyCompositionState extends State<Step4FamilyComposition> {
  void _addMember() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _MemberFormSheet(
        onSave: (member) {
          setState(() {
            widget.members.add(member);
            widget.onMembersUpdated(widget.members);
          });
        },
      ),
    );
  }

  void _editMember(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _MemberFormSheet(
        initialMember: widget.members[index],
        onSave: (member) {
          setState(() {
            widget.members[index] = member;
            widget.onMembersUpdated(widget.members);
          });
        },
      ),
    );
  }

  void _removeMember(int index) {
    setState(() {
      widget.members.removeAt(index);
      widget.onMembersUpdated(widget.members);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Family Members', style: Theme.of(context).textTheme.titleLarge),
            ElevatedButton.icon(
              onPressed: _addMember,
              icon: const Icon(Icons.add),
              label: const Text('Add Member'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (widget.members.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: Text('No members added yet.')),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.members.length,
            itemBuilder: (context, index) {
              final member = widget.members[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: member.localPhotoPath != null ? FileImage(File(member.localPhotoPath!)) : null,
                    child: member.localPhotoPath == null ? const Icon(Icons.person) : null,
                  ),
                  title: Text('${member.firstName} ${member.lastName}'),
                  subtitle: Text('${member.relationWithHOF} • ${member.age} yrs • ${member.bloodGroup}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.primary),
                        onPressed: () => _editMember(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.error),
                        onPressed: () => _removeMember(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _MemberFormSheet extends StatefulWidget {
  final MemberModel? initialMember;
  final Function(MemberModel) onSave;

  const _MemberFormSheet({this.initialMember, required this.onSave});

  @override
  State<_MemberFormSheet> createState() => _MemberFormSheetState();
}

class _MemberFormSheetState extends State<_MemberFormSheet> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _dobController;
  late TextEditingController _ageController;

  String _relation = '';
  String _bloodGroup = '';
  String _maritalStatus = '';
  String _education = '';
  String _occupation = '';
  DateTime? _dob;
  File? _photo;

  @override
  void initState() {
    super.initState();
    final m = widget.initialMember;
    
    _firstNameController = TextEditingController(text: m?.firstName ?? '');
    _lastNameController = TextEditingController(text: m?.lastName ?? '');
    _dobController = TextEditingController(
      text: m?.dob != null && m!.age > 0 ? DateFormat('dd/MM/yyyy').format(m.dob!) : '',
    );
    _ageController = TextEditingController(text: m != null && m.age > 0 ? m.age.toString() : '');
    
    _relation = m?.relationWithHOF ?? '';
    _bloodGroup = m?.bloodGroup ?? '';
    _maritalStatus = m?.maritalStatus ?? '';
    _education = m?.education ?? '';
    _occupation = m?.occupation ?? '';
    _dob = m?.dob;
    _photo = m?.localPhotoPath != null ? File(m!.localPhotoPath!) : null;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dob = picked;
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
        _ageController.text = AgeCalculator.calculateAge(picked).toString();
      });
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      if (_photo == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload member photo')));
        return;
      }
      
      final member = MemberModel(
        id: widget.initialMember?.id ?? const Uuid().v4(),
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        relationWithHOF: _relation,
        bloodGroup: _bloodGroup,
        dob: _dob,
        age: int.tryParse(_ageController.text) ?? 0,
        maritalStatus: _maritalStatus,
        education: _education,
        occupation: _occupation,
        localPhotoPath: _photo?.path,
      );
      
      widget.onSave(member);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16, right: 16, top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.initialMember == null ? 'Add Member' : 'Edit Member', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              PhotoPickerWidget(
                initialImage: _photo,
                onImageSelected: (f) => _photo = f,
                radius: 40,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'First Name *',
                controller: _firstNameController,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              CustomTextField(
                label: 'Last Name *',
                controller: _lastNameController,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              CustomDropdown(
                label: 'Relation with HOF *',
                items: DropdownData.relations,
                selectedItem: _relation.isNotEmpty ? _relation : null,
                onChanged: (v) => _relation = v ?? '',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              CustomDropdown(
                label: 'Blood Group *',
                items: DropdownData.bloodGroups,
                selectedItem: _bloodGroup.isNotEmpty ? _bloodGroup : null,
                onChanged: (v) => _bloodGroup = v ?? '',
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
                selectedItem: _maritalStatus.isNotEmpty ? _maritalStatus : null,
                onChanged: (v) => _maritalStatus = v ?? '',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              CustomDropdown(
                label: 'Education *',
                items: DropdownData.educationLevels,
                selectedItem: _education.isNotEmpty ? _education : null,
                onChanged: (v) => _education = v ?? '',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              CustomDropdown(
                label: 'Occupation *',
                items: DropdownData.occupations,
                selectedItem: _occupation.isNotEmpty ? _occupation : null,
                onChanged: (v) => _occupation = v ?? '',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save Member'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
