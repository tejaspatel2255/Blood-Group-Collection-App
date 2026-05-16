import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/dropdown_data.dart';
import '../../core/constants/countries.dart';
import '../../models/family_model.dart';
import '../../models/country_model.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Step2AddressContact
// ─────────────────────────────────────────────────────────────────────────────
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

  late Country _mobileCountry;
  late Country _whatsappCountry;

  static final _addressRegex = RegExp(r'^[a-zA-Z0-9\s,\-/\.]+$');
  static final _lettersOnly  = RegExp(r'^[a-zA-Z\s]+$');
  static final _emailRegex   = RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w{2,4}$');

  // Validation: 10-digit Indian rule for +91, else 5–15 digits for others
  String? _validatePhone(String val, String label, Country country) {
    if (val.isEmpty) return '$label is required';
    if (!RegExp(r'^\d+$').hasMatch(val)) return 'Enter digits only for $label';
    
    if (country.dialCode == '+91') {
      if (val.length != 10) return 'Enter a valid 10-digit $label';
    } else {
      if (val.length < 5 || val.length > 15) return 'Enter a valid $label (5-15 digits)';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _addressController     = TextEditingController(text: widget.family.currentAddress);
    _nativePlaceController = TextEditingController(text: widget.family.nativePlace);
    _cityController        = TextEditingController(text: widget.family.city);
    _pincodeController     = TextEditingController(text: widget.family.pinCode);
    _mobileController      = TextEditingController(text: widget.family.mobile);
    _whatsappController    = TextEditingController(text: widget.family.whatsapp);
    _emailController       = TextEditingController(text: widget.family.email.trim());

    // Restore or default country codes
    _mobileCountry = Countries.fromDialCode(widget.family.mobileCountryCode);
    _whatsappCountry = Countries.fromDialCode(widget.family.whatsappCountryCode);

    // Default state to Gujarat if not already set
    if (widget.family.state.isEmpty) {
      widget.family.state = 'Gujarat';
    }
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

  void _fillWhatsAppFromMobile() {
    setState(() {
      _whatsappController.text = _mobileController.text;
      _whatsappCountry = _mobileCountry;
      widget.family.whatsappCountryCode = _mobileCountry.dialCode;
    });
  }

  // ── Country code picker bottom sheet ──────────────────────────────────────
  void _showCountryPicker(Country current, void Function(Country) onSelected) {
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
              // Handle bar
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
                  onChanged: (q) {
                    setSheet(() {
                      filtered = Countries.all
                          .where((c) =>
                              c.name.toLowerCase().contains(q.toLowerCase()) ||
                              c.dialCode.contains(q))
                          .toList();
                    });
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final c = filtered[i];
                    final selected = c.dialCode == current.dialCode &&
                        c.name == current.name;
                    return ListTile(
                      leading: Text(c.flag,
                          style: const TextStyle(fontSize: 24)),
                      title: Text(c.name),
                      trailing: Text(c.dialCode,
                          style: TextStyle(
                              color: selected
                                  ? const Color(0xFF00695C)
                                  : Colors.grey[600],
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                      selected: selected,
                      selectedTileColor: const Color(0xFF00695C).withOpacity(0.08),
                      onTap: () {
                        onSelected(c);
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

  // ── Inline country-code prefix button ─────────────────────────────────────
  Widget _countryPrefix(Country country, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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
            Text(country.flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 4),
            Text(country.dialCode,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
      ),
    );
  }

  // ── Phone field with country code prefix ──────────────────────────────────
  Widget _phoneField({
    required String label,
    required TextEditingController controller,
    required Country country,
    required void Function(Country) onCountryChange,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _countryPrefix(country, () => _showCountryPicker(country, (c) {
                setState(() {
                  onCountryChange(c);
                });
              })),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(15),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Enter number',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    isDense: false,
                    counterText: '',
                  ),
                  validator: validator,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Current Address ──────────────────────────────────────────────
          CustomTextField(
            label: 'Current Address *',
            controller: _addressController,
            maxLines: 3,
            validator: (v) {
              final val = v?.trim() ?? '';
              widget.family.currentAddress = val;
              if (val.isEmpty) return 'Current Address is required';
              if (val.length < 10) return 'Current Address must be at least 10 characters';
              if (val.length > 200) return 'Current Address too long (max 200 chars)';
              if (!_addressRegex.hasMatch(val)) return 'Invalid characters in Current Address';
              return null;
            },
          ),

          // ── Native Place ─────────────────────────────────────────────────
          CustomTextField(
            label: 'Native Place / Village *',
            controller: _nativePlaceController,
            textCapitalization: TextCapitalization.words,
            validator: (v) {
              final val = v?.trim() ?? '';
              widget.family.nativePlace = val;
              if (val.isEmpty) return 'Native Place is required';
              if (val.length < 2) return 'Native Place must be at least 2 characters';
              if (val.length > 100) return 'Native Place too long (max 100 chars)';
              if (!_lettersOnly.hasMatch(val)) return 'Enter a valid Native Place (letters only)';
              return null;
            },
          ),

          // ── City + PIN ───────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'City *',
                  controller: _cityController,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) {
                    final val = v?.trim() ?? '';
                    widget.family.city = val;
                    if (val.isEmpty) return 'City is required';
                    if (val.length < 2) return 'City must be at least 2 characters';
                    if (val.length > 50) return 'City too long (max 50 chars)';
                    if (!_lettersOnly.hasMatch(val)) return 'Enter a valid City name';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  label: 'PIN Code *',
                  controller: _pincodeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  validator: (v) {
                    final val = v?.trim() ?? '';
                    widget.family.pinCode = val;
                    if (val.isEmpty) return 'PIN Code is required';
                    if (val.length != 6) return 'Enter a valid 6-digit PIN Code';
                    if (val.startsWith('0')) return 'PIN Code cannot start with 0';
                    return null;
                  },
                ),
              ),
            ],
          ),

          // ── State (default Gujarat) ──────────────────────────────────────
          CustomDropdown(
            label: 'State *',
            items: DropdownData.indianStates,
            showSearchBox: true,
            selectedItem: widget.family.state.isNotEmpty
                ? widget.family.state
                : 'Gujarat',
            onChanged: (v) => setState(() => widget.family.state = v ?? 'Gujarat'),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'State is required' : null,
          ),

          // ── Mobile Number ────────────────────────────────────────────────
          _phoneField(
            label: 'Mobile Number *',
            controller: _mobileController,
            country: _mobileCountry,
            onCountryChange: (c) {
              _mobileCountry = c;
              widget.family.mobileCountryCode = c.dialCode;
            },
            validator: (v) {
              final val = v?.trim() ?? '';
              widget.family.mobile = val;
              return _validatePhone(val, 'Mobile number', _mobileCountry);
            },
          ),

          // ── WhatsApp Number ──────────────────────────────────────────────
          _phoneField(
            label: 'WhatsApp Number *',
            controller: _whatsappController,
            country: _whatsappCountry,
            onCountryChange: (c) {
              _whatsappCountry = c;
              widget.family.whatsappCountryCode = c.dialCode;
            },
            validator: (v) {
              final val = v?.trim() ?? '';
              widget.family.whatsapp = val;
              return _validatePhone(val, 'WhatsApp number', _whatsappCountry);
            },
          ),

          // "Same as Mobile" shortcut
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16, top: 0),
            child: GestureDetector(
              onTap: _fillWhatsAppFromMobile,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.copy_all, size: 16, color: Color(0xFF00695C)),
                  SizedBox(width: 4),
                  Text(
                    'Same as Mobile',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF00695C),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Email ────────────────────────────────────────────────────────
          CustomTextField(
            label: 'Email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              final val = v?.trim() ?? '';
              widget.family.email = val;
              if (val.isEmpty) return null; // Not compulsory
              if (!_emailRegex.hasMatch(val)) return 'Enter a valid email address';
              return null;
            },
          ),
        ],
      ),
    );
  }
}
