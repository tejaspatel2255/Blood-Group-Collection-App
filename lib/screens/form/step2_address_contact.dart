import 'package:flutter/material.dart';
import '../../core/constants/dropdown_data.dart';
import '../../models/family_model.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';

class Step2AddressContact extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final FamilyModel family;

  const Step2AddressContact({
    super.key,
    required this.formKey,
    required this.family,
  });

  @override
  State<Step2AddressContact> createState() => _Step2AddressContactState();
}

class _Step2AddressContactState extends State<Step2AddressContact> {
  late TextEditingController _addressController;
  late TextEditingController _nativePlaceController;
  late TextEditingController _cityController;
  late TextEditingController _pincodeController;
  late TextEditingController _mobileController;
  late TextEditingController _whatsappController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.family.currentAddress);
    _nativePlaceController = TextEditingController(text: widget.family.nativePlace);
    _cityController = TextEditingController(text: widget.family.city);
    _pincodeController = TextEditingController(text: widget.family.pinCode);
    _mobileController = TextEditingController(text: widget.family.mobile);
    _whatsappController = TextEditingController(text: widget.family.whatsapp);
    _emailController = TextEditingController(text: widget.family.email);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _nativePlaceController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _mobileController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          CustomTextField(
            label: 'Current Address',
            controller: _addressController,
            maxLines: 3,
            validator: (v) {
              if (v != null) widget.family.currentAddress = v;
              return null;
            },
          ),
          CustomTextField(
            label: 'Native Place',
            controller: _nativePlaceController,
            validator: (v) {
              if (v != null) widget.family.nativePlace = v;
              return null;
            },
          ),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'City',
                  controller: _cityController,
                  validator: (v) {
                    if (v != null) widget.family.city = v;
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  label: 'Pincode',
                  controller: _pincodeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  validator: (v) {
                    if (v != null) widget.family.pinCode = v;
                    return null;
                  },
                ),
              ),
            ],
          ),
          CustomDropdown(
            label: 'State',
            items: DropdownData.indianStates,
            showSearchBox: true,
            selectedItem: widget.family.state.isNotEmpty ? widget.family.state : null,
            onChanged: (v) {
              setState(() => widget.family.state = v ?? '');
            },
            validator: (v) => v == null ? 'Required' : null,
          ),
          CustomTextField(
            label: 'Mobile Number',
            controller: _mobileController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            validator: (v) {
              if (v == null || v.length != 10) return 'Enter 10 digit mobile number';
              widget.family.mobile = v;
              return null;
            },
          ),
          CustomTextField(
            label: 'WhatsApp Number (Optional)',
            controller: _whatsappController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            validator: (v) {
              if (v != null) widget.family.whatsapp = v;
              return null;
            },
          ),
          CustomTextField(
            label: 'Email (Optional)',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v != null) widget.family.email = v;
              return null;
            },
          ),
        ],
      ),
    );
  }
}
