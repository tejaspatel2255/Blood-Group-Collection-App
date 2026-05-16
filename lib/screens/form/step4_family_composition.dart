import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/member_model.dart';
import '../../models/country_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/dropdown_data.dart';
import '../../core/constants/countries.dart';
import '../../core/utils/age_calculator.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/photo_picker_widget.dart';
import 'package:intl/intl.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Step4FamilyComposition
// ─────────────────────────────────────────────────────────────────────────────
class Step4FamilyComposition extends StatefulWidget {
  final List<MemberModel> members;
  final Function(List<MemberModel>) onMembersUpdated;

  const Step4FamilyComposition({
    super.key,
    required this.members,
    required this.onMembersUpdated,
  });

  @override
  Step4FamilyCompositionState createState() => Step4FamilyCompositionState();
}

/// Public state so FormStepperScreen can call validate() via GlobalKey
class Step4FamilyCompositionState extends State<Step4FamilyComposition> {
  late List<MemberModel> _members;

  // Per-member photo-error tracking (indexed to _members)
  final List<bool> _photoErrors = [];

  @override
  void initState() {
    super.initState();
    _members = List<MemberModel>.from(widget.members);
    _syncPhotoErrors();
  }

  void _syncPhotoErrors() {
    while (_photoErrors.length < _members.length) _photoErrors.add(false);
    while (_photoErrors.length > _members.length) _photoErrors.removeLast();
  }

  // Called by FormStepperScreen before advancing / submitting
  bool validate() {
    bool allValid = true;
    _syncPhotoErrors();
    for (int i = 0; i < _members.length; i++) {
      final m = _members[i];
      final hasPhoto = m.localPhotoBytes != null || m.photoUrl.isNotEmpty;
      if (!hasPhoto) {
        _photoErrors[i] = true;
        allValid = false;
      }
    }
    if (!allValid) setState(() {});
    return allValid;
  }

  // ── CRUD ───────────────────────────────────────────────────────────────────
  void _addMember() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _MemberFormSheet(
        onSave: (member) {
          setState(() {
            _members.add(member);
            _photoErrors.add(false);
            widget.onMembersUpdated(_members);
          });
        },
      ),
    );
  }

  void _editMember(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _MemberFormSheet(
        initialMember: _members[index],
        onSave: (member) {
          setState(() {
            _members[index] = member;
            // Clear photo error once member has a photo
            if (_photoErrors.length > index) {
              _photoErrors[index] =
                  !(member.localPhotoBytes != null || member.photoUrl.isNotEmpty);
            }
            widget.onMembersUpdated(_members);
          });
        },
      ),
    );
  }

  void _removeMember(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Remove "${_members[index].name}" from the family?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _members.removeAt(index);
                if (_photoErrors.length > index) _photoErrors.removeAt(index);
                widget.onMembersUpdated(_members);
              });
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  ImageProvider? _memberPhoto(MemberModel m) {
    if (m.localPhotoBytes != null) return MemoryImage(m.localPhotoBytes!);
    if (m.photoUrl.isNotEmpty) return NetworkImage(m.photoUrl);
    return null;
  }

  // ── Build ──────────────────────────────────────────────────────────────────
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
        if (_members.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: Text('No additional members added yet.')),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _members.length,
            itemBuilder: (context, index) {
              final member = _members[index];
              final hasPhotoError =
                  index < _photoErrors.length && _photoErrors[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: hasPhotoError
                      ? Border.all(color: AppColors.error, width: 1.5)
                      : null,
                ),
                child: Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: _memberPhoto(member),
                          child: _memberPhoto(member) == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(
                          member.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${member.relationship} • ${member.age} yrs • ${member.bloodGroup}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: AppColors.primary),
                              onPressed: () => _editMember(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: AppColors.error),
                              onPressed: () => _removeMember(index),
                            ),
                          ],
                        ),
                      ),
                      // Inline photo error indicator
                      if (hasPhotoError)
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 8),
                          child: Row(
                            children: const [
                              Icon(Icons.error_outline,
                                  size: 14, color: AppColors.error),
                              SizedBox(width: 4),
                              Text(
                                'Member photo is required',
                                style: TextStyle(
                                    fontSize: 12, color: AppColors.error),
                              ),
                            ],
                          ),
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

// ─────────────────────────────────────────────────────────────────────────────
// _MemberFormSheet — modal for Add / Edit a single member
// ─────────────────────────────────────────────────────────────────────────────
class _MemberFormSheet extends StatefulWidget {
  final MemberModel? initialMember;
  final Function(MemberModel) onSave;

  const _MemberFormSheet({this.initialMember, required this.onSave});

  @override
  State<_MemberFormSheet> createState() => _MemberFormSheetState();
}

class _MemberFormSheetState extends State<_MemberFormSheet> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _ageController;
  late TextEditingController _mobileController;

  // Field values
  String _relationship = '';
  String _gender = '';
  String _bloodGroup = '';
  String _maritalStatus = '';
  String _area = '';
  String _education = '';
  String _occupation = '';
  DateTime? _dob;
  Uint8List? _photo;
  String _existingPhotoUrl = '';
  bool _photoError = false;
  late Country _mobileCountry;

  // Validation constants
  static const int _minPhotoBytes = 10240;  // 10 KB
  static const int _maxPhotoBytes = 102400; // 100 KB

  static final _nameRegex = RegExp(r'^[a-zA-Z\s\.\-]+$');

  bool get _isMinor {
    final age = int.tryParse(_ageController.text.trim()) ?? 0;
    return age < 18;
  }

  List<String> get _maritalItems =>
      _isMinor ? ['Single'] : DropdownData.maritalStatuses;

  @override
  void initState() {
    super.initState();
    final m = widget.initialMember;

    _nameController = TextEditingController(text: m?.name ?? '');
    _dobController = TextEditingController(
      text: m?.dob != null ? DateFormat('dd/MM/yyyy').format(m!.dob!) : '',
    );

    if (m?.dob != null) {
      _ageController = TextEditingController(
        text: AgeCalculator.calculateAge(m!.dob!).toString(),
      );
    } else {
      _ageController = TextEditingController(
        text: m != null ? m.age.toString() : '',
      );
    }

    _mobileController = TextEditingController(text: m?.mobile ?? '');
    _relationship = m?.relationship ?? '';
    _gender = m?.gender ?? '';
    _bloodGroup = m?.bloodGroup ?? '';
    _maritalStatus = m?.maritalStatus ?? '';
    _area = m?.area ?? '';
    _education = m?.education ?? '';
    _occupation = m?.occupation ?? '';
    _dob = m?.dob;
    _photo = m?.localPhotoBytes;
    _existingPhotoUrl = m?.photoUrl ?? '';
    _mobileCountry = Countries.fromDialCode(m?.mobileCountryCode ?? '+91');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _ageController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  // ── Photo picker with size validation ──────────────────────────────────────
  void _onPhotoSelected(Uint8List? bytes) {
    if (bytes == null) return;
    if (bytes.lengthInBytes < _minPhotoBytes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image size must be at least 10 KB')),
      );
      return;
    }
    if (bytes.lengthInBytes > _maxPhotoBytes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image size must not exceed 100 KB')),
      );
      return;
    }
    setState(() {
      _photo = bytes;
      _photoError = false;
    });
  }

  // ── Date picker ────────────────────────────────────────────────────────────
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final calcAge = AgeCalculator.calculateAge(picked);
      setState(() {
        _dob = picked;
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
        _ageController.text = calcAge.toString();
        // Auto-set marital status for minors
        if (calcAge < 18) _maritalStatus = 'Single';
      });
    }
  }

  // ── Country picker ────────────────────────────────────────────────────────
  void _showCountryPicker() {
    final searchCtrl = TextEditingController();
    List<Country> filtered = List.from(Countries.all);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.75,
          child: Column(
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text('Select Country Code',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: searchCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Search country...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (q) => setSheet(() {
                    filtered = Countries.all
                        .where((c) =>
                            c.name.toLowerCase().contains(q.toLowerCase()) ||
                            c.dialCode.contains(q))
                        .toList();
                  }),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final c = filtered[i];
                    final sel = c.dialCode == _mobileCountry.dialCode &&
                        c.name == _mobileCountry.name;
                    return ListTile(
                      leading: Text(c.flag,
                          style: const TextStyle(fontSize: 24)),
                      title: Text(c.name),
                      trailing: Text(c.dialCode,
                          style: TextStyle(
                            color: sel ? AppColors.primary : Colors.grey[600],
                            fontWeight:
                                sel ? FontWeight.bold : FontWeight.normal,
                          )),
                      selected: sel,
                      selectedTileColor:
                          AppColors.primary.withOpacity(0.08),
                      onTap: () {
                        setState(() => _mobileCountry = c);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _countryPrefix() {
    return GestureDetector(
      onTap: _showCountryPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            bottomLeft: Radius.circular(8),
          ),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_mobileCountry.flag,
                style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 4),
            Text(_mobileCountry.dialCode,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
      ),
    );
  }

  void _save() {
    // 1. Photo check first
    final hasPhoto = _photo != null || _existingPhotoUrl.isNotEmpty;
    if (!hasPhoto) {
      setState(() => _photoError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member photo is required')),
      );
      return;
    }

    // 2. Form validation
    if (!_formKey.currentState!.validate()) return;

    // 3. DOB required check (separate because it's not a TextFormField)
    if (_dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Date of birth is required')),
      );
      return;
    }

    final member = MemberModel(
      id: widget.initialMember?.id,
      name: _nameController.text.trim(),
      relationship: _relationship,
      gender: _gender,
      bloodGroup: _bloodGroup,
      dob: _dob,
      age: int.tryParse(_ageController.text.trim()) ?? 0,
      maritalStatus: _maritalStatus,
      area: _area,
      education: _education,
      occupation: _occupation,
      mobile: _mobileController.text.trim(),
      mobileCountryCode: _mobileCountry.dialCode,
      localPhotoBytes: _photo,
      photoUrl: _photo != null && _existingPhotoUrl.isEmpty
          ? ''
          : _existingPhotoUrl,
    );

    widget.onSave(member);
    Navigator.of(context).pop();
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                widget.initialMember == null ? 'Add Member' : 'Edit Member',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // ── Photo (REQUIRED) ──────────────────────────────────────────
              PhotoPickerWidget(
                initialImage: _photo,
                imageUrl: _existingPhotoUrl,
                onImageSelected: _onPhotoSelected,
                radius: 40,
              ),
              if (_photoError)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.error_outline, size: 14, color: AppColors.error),
                      SizedBox(width: 4),
                      Text(
                        'Member photo is required',
                        style: TextStyle(fontSize: 12, color: AppColors.error),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 12),
                child: Text(
                  'Photo required • 10 KB – 100 KB • JPG / PNG',
                  style: TextStyle(
                      fontSize: 11,
                      color: _photoError ? AppColors.error : AppColors.textSecondary),
                ),
              ),

              // ── Full Name ─────────────────────────────────────────────────
              CustomTextField(
                label: 'Full Name *',
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  final val = v?.trim() ?? '';
                  if (val.isEmpty) return 'Full Name is required';
                  if (val.length < 2) return 'Full Name must be at least 2 characters';
                  if (val.length > 100) return 'Full Name too long (max 100 chars)';
                  if (!_nameRegex.hasMatch(val)) return 'Enter a valid Full Name (letters and spaces only)';
                  return null;
                },
              ),

              // ── Relationship ──────────────────────────────────────────────
              CustomDropdown(
                label: 'Relationship with HOF *',
                items: DropdownData.relationshipList,
                selectedItem: _relationship.isNotEmpty ? _relationship : null,
                onChanged: (v) => setState(() => _relationship = v ?? ''),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Relationship is required' : null,
              ),

              // ── Gender ────────────────────────────────────────────────────
              CustomDropdown(
                label: 'Gender *',
                items: DropdownData.genders,
                selectedItem: _gender.isNotEmpty ? _gender : null,
                onChanged: (v) => setState(() => _gender = v ?? ''),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Gender is required' : null,
              ),

              // ── Blood Group ───────────────────────────────────────────────
              CustomDropdown(
                label: 'Blood Group *',
                items: DropdownData.bloodGroups,
                selectedItem: _bloodGroup.isNotEmpty ? _bloodGroup : null,
                onChanged: (v) => setState(() => _bloodGroup = v ?? ''),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Blood Group is required' : null,
              ),

              // ── Date of Birth (REQUIRED) ──────────────────────────────────
              InkWell(
                onTap: _selectDate,
                child: IgnorePointer(
                  child: CustomTextField(
                    label: 'Date of Birth *',
                    controller: _dobController,
                    validator: (_) {
                      if (_dob == null) return 'Date of Birth is required';
                      if (_dob!.isAfter(DateTime.now())) {
                        return 'Date cannot be in the future';
                      }
                      return null;
                    },
                  ),
                ),
              ),

              // ── Age (auto-filled / manual) ────────────────────────────────
              CustomTextField(
                label: 'Age *',
                controller: _ageController,
                keyboardType: TextInputType.number,
                readOnly: _dob != null,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                validator: (v) {
                  final val = v?.trim() ?? '';
                  if (val.isEmpty) return 'Age is required';
                  final age = int.tryParse(val);
                  if (age == null || age < 0 || age > 120) {
                    return 'Enter a valid Age (0–120)';
                  }
                  return null;
                },
              ),

              // ── Marital Status (age-aware) ─────────────────────────────────
              if (_isMinor) ...[
                CustomDropdown(
                  label: 'Marital Status *',
                  items: const ['Single'],
                  selectedItem: 'Single',
                  onChanged: (_) {},
                  validator: (_) => null,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 4),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline, size: 14, color: Colors.orange),
                      SizedBox(width: 4),
                      Text(
                        'Auto-set to Unmarried for age below 18',
                        style: TextStyle(fontSize: 11, color: Colors.orange),
                      ),
                    ],
                  ),
                ),
              ] else
                CustomDropdown(
                  label: 'Marital Status *',
                  items: DropdownData.maritalStatuses,
                  selectedItem: _maritalStatus.isNotEmpty ? _maritalStatus : null,
                  onChanged: (v) => setState(() => _maritalStatus = v ?? ''),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Marital Status is required' : null,
                ),

              // ── Area ──────────────────────────────────────────────────────
              CustomDropdown(
                label: 'Area *',
                items: const ['Motapore', 'Nanapore', 'Vachewad'],
                selectedItem: _area.isNotEmpty ? _area : null,
                onChanged: (v) => setState(() => _area = v ?? ''),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Area is required' : null,
              ),

              // ── Education ─────────────────────────────────────────────────
              CustomDropdown(
                label: 'Education *',
                items: DropdownData.educationList,
                selectedItem: _education.isNotEmpty ? _education : null,
                onChanged: (v) => setState(() => _education = v ?? ''),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Education Level is required' : null,
              ),

              // ── Occupation ────────────────────────────────────────────────
              CustomDropdown(
                label: 'Occupation *',
                items: DropdownData.occupationList,
                selectedItem: _occupation.isNotEmpty ? _occupation : null,
                onChanged: (v) => setState(() => _occupation = v ?? ''),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Occupation is required' : null,
              ),

              // ── Mobile (REQUIRED) with country code ───────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Mobile Number *',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _countryPrefix(),
                        Expanded(
                          child: TextFormField(
                            controller: _mobileController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(15),
                            ],
                            decoration: const InputDecoration(
                              hintText: 'Enter mobile number',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                              ),
                              counterText: '',
                            ),
                            validator: (v) {
                              final val = v?.trim() ?? '';
                              if (val.isEmpty) return 'Mobile Number is required';
                              if (!RegExp(r'^\d+$').hasMatch(val)) return 'Enter digits only for Mobile Number';
                              
                              if (_mobileCountry.dialCode == '+91') {
                                if (val.length != 10) return 'Enter a valid 10-digit Mobile Number';
                              } else {
                                if (val.length < 5 || val.length > 15) return 'Enter a valid Mobile Number (5-15 digits)';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Save Button ───────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 55,
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
