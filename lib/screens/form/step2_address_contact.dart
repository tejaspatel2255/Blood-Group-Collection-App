import 'package:flutter/material.dart';
import '../../models/family_model.dart';
import '../../core/constants/dropdown_data.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';

class Step2AddressContact extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final HeadOfFamily hof;

  const Step2AddressContact({
    super.key,
    required this.formKey,
    required this.hof,
  });

  @override
  State<Step2AddressContact> createState() => _Step2AddressContactState();
}

class _Step2AddressContactState extends State<Step2AddressContact> {
  late TextEditingController _villageController;
  late TextEditingController _talukaController;
  late TextEditingController _pincodeController;
  late TextEditingController _mobileController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _villageController = TextEditingController(text: widget.hof.village);
    _talukaController = TextEditingController(text: widget.hof.taluka);
    _pincodeController = TextEditingController(text: widget.hof.pincode);
    _mobileController = TextEditingController(text: widget.hof.mobileNumber);
    _emailController = TextEditingController(text: widget.hof.email);

    _villageController.addListener(() => widget.hof.village = _villageController.text);
    _talukaController.addListener(() => widget.hof.taluka = _talukaController.text);
    _pincodeController.addListener(() => widget.hof.pincode = _pincodeController.text);
    _mobileController.addListener(() => widget.hof.mobileNumber = _mobileController.text);
    _emailController.addListener(() => widget.hof.email = _emailController.text);
    
    if (widget.hof.state.isEmpty) widget.hof.state = 'Gujarat';
  }

  @override
  void dispose() {
    _villageController.dispose();
    _talukaController.dispose();
    _pincodeController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            label: 'Village/City *',
            controller: _villageController,
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          CustomTextField(
            label: 'Taluka',
            controller: _talukaController,
          ),
          CustomDropdown(
            label: 'District *',
            items: DropdownData.gujaratDistricts,
            selectedItem: widget.hof.district.isNotEmpty ? widget.hof.district : null,
            showSearchBox: true,
            onChanged: (v) => widget.hof.district = v ?? '',
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          CustomDropdown(
            label: 'State *',
            items: DropdownData.indianStates,
            selectedItem: widget.hof.state.isNotEmpty ? widget.hof.state : 'Gujarat',
            showSearchBox: true,
            onChanged: (v) => widget.hof.state = v ?? '',
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          CustomTextField(
            label: 'Pincode *',
            controller: _pincodeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            validator: (v) => v!.length != 6 ? 'Enter 6 digit pincode' : null,
          ),
          const Divider(height: 32),
          Text('Contact Details', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Mobile Number *',
            controller: _mobileController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            prefixText: '+91 ',
            validator: (v) => v!.length != 10 ? 'Enter 10 digit mobile number' : null,
          ),
          CustomTextField(
            label: 'Email Address',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }
}
