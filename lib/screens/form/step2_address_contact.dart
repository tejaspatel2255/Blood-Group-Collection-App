import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/dropdown_data.dart';
import '../../models/family_model.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';

// ─── Country data model ────────────────────────────────────────────────────
class _Country {
  final String flag;
  final String name;
  final String dialCode;
  const _Country(this.flag, this.name, this.dialCode);
  @override
  String toString() => '$flag $dialCode';
}

// ─── Full country list ─────────────────────────────────────────────────────
const List<_Country> _countries = [
  _Country('🇦🇫', 'Afghanistan', '+93'),
  _Country('🇦🇱', 'Albania', '+355'),
  _Country('🇩🇿', 'Algeria', '+213'),
  _Country('🇦🇩', 'Andorra', '+376'),
  _Country('🇦🇴', 'Angola', '+244'),
  _Country('🇦🇬', 'Antigua & Barbuda', '+1-268'),
  _Country('🇦🇷', 'Argentina', '+54'),
  _Country('🇦🇲', 'Armenia', '+374'),
  _Country('🇦🇺', 'Australia', '+61'),
  _Country('🇦🇹', 'Austria', '+43'),
  _Country('🇦🇿', 'Azerbaijan', '+994'),
  _Country('🇧🇸', 'Bahamas', '+1-242'),
  _Country('🇧🇭', 'Bahrain', '+973'),
  _Country('🇧🇩', 'Bangladesh', '+880'),
  _Country('🇧🇧', 'Barbados', '+1-246'),
  _Country('🇧🇾', 'Belarus', '+375'),
  _Country('🇧🇪', 'Belgium', '+32'),
  _Country('🇧🇿', 'Belize', '+501'),
  _Country('🇧🇯', 'Benin', '+229'),
  _Country('🇧🇹', 'Bhutan', '+975'),
  _Country('🇧🇴', 'Bolivia', '+591'),
  _Country('🇧🇦', 'Bosnia & Herzegovina', '+387'),
  _Country('🇧🇼', 'Botswana', '+267'),
  _Country('🇧🇷', 'Brazil', '+55'),
  _Country('🇧🇳', 'Brunei', '+673'),
  _Country('🇧🇬', 'Bulgaria', '+359'),
  _Country('🇧🇫', 'Burkina Faso', '+226'),
  _Country('🇧🇮', 'Burundi', '+257'),
  _Country('🇨🇻', 'Cabo Verde', '+238'),
  _Country('🇰🇭', 'Cambodia', '+855'),
  _Country('🇨🇲', 'Cameroon', '+237'),
  _Country('🇨🇦', 'Canada', '+1'),
  _Country('🇨🇫', 'Central African Republic', '+236'),
  _Country('🇹🇩', 'Chad', '+235'),
  _Country('🇨🇱', 'Chile', '+56'),
  _Country('🇨🇳', 'China', '+86'),
  _Country('🇨🇴', 'Colombia', '+57'),
  _Country('🇰🇲', 'Comoros', '+269'),
  _Country('🇨🇬', 'Congo', '+242'),
  _Country('🇨🇷', 'Costa Rica', '+506'),
  _Country('🇭🇷', 'Croatia', '+385'),
  _Country('🇨🇺', 'Cuba', '+53'),
  _Country('🇨🇾', 'Cyprus', '+357'),
  _Country('🇨🇿', 'Czech Republic', '+420'),
  _Country('🇩🇰', 'Denmark', '+45'),
  _Country('🇩🇯', 'Djibouti', '+253'),
  _Country('🇩🇴', 'Dominican Republic', '+1-809'),
  _Country('🇪🇨', 'Ecuador', '+593'),
  _Country('🇪🇬', 'Egypt', '+20'),
  _Country('🇸🇻', 'El Salvador', '+503'),
  _Country('🇬🇶', 'Equatorial Guinea', '+240'),
  _Country('🇪🇷', 'Eritrea', '+291'),
  _Country('🇪🇪', 'Estonia', '+372'),
  _Country('🇸🇿', 'Eswatini', '+268'),
  _Country('🇪🇹', 'Ethiopia', '+251'),
  _Country('🇫🇯', 'Fiji', '+679'),
  _Country('🇫🇮', 'Finland', '+358'),
  _Country('🇫🇷', 'France', '+33'),
  _Country('🇬🇦', 'Gabon', '+241'),
  _Country('🇬🇲', 'Gambia', '+220'),
  _Country('🇬🇪', 'Georgia', '+995'),
  _Country('🇩🇪', 'Germany', '+49'),
  _Country('🇬🇭', 'Ghana', '+233'),
  _Country('🇬🇷', 'Greece', '+30'),
  _Country('🇬🇩', 'Grenada', '+1-473'),
  _Country('🇬🇹', 'Guatemala', '+502'),
  _Country('🇬🇳', 'Guinea', '+224'),
  _Country('🇬🇾', 'Guyana', '+592'),
  _Country('🇭🇹', 'Haiti', '+509'),
  _Country('🇭🇳', 'Honduras', '+504'),
  _Country('🇭🇺', 'Hungary', '+36'),
  _Country('🇮🇸', 'Iceland', '+354'),
  _Country('🇮🇳', 'India', '+91'),
  _Country('🇮🇩', 'Indonesia', '+62'),
  _Country('🇮🇷', 'Iran', '+98'),
  _Country('🇮🇶', 'Iraq', '+964'),
  _Country('🇮🇪', 'Ireland', '+353'),
  _Country('🇮🇱', 'Israel', '+972'),
  _Country('🇮🇹', 'Italy', '+39'),
  _Country('🇯🇲', 'Jamaica', '+1-876'),
  _Country('🇯🇵', 'Japan', '+81'),
  _Country('🇯🇴', 'Jordan', '+962'),
  _Country('🇰🇿', 'Kazakhstan', '+7'),
  _Country('🇰🇪', 'Kenya', '+254'),
  _Country('🇰🇷', 'South Korea', '+82'),
  _Country('🇰🇼', 'Kuwait', '+965'),
  _Country('🇰🇬', 'Kyrgyzstan', '+996'),
  _Country('🇱🇦', 'Laos', '+856'),
  _Country('🇱🇻', 'Latvia', '+371'),
  _Country('🇱🇧', 'Lebanon', '+961'),
  _Country('🇱🇸', 'Lesotho', '+266'),
  _Country('🇱🇷', 'Liberia', '+231'),
  _Country('🇱🇾', 'Libya', '+218'),
  _Country('🇱🇮', 'Liechtenstein', '+423'),
  _Country('🇱🇹', 'Lithuania', '+370'),
  _Country('🇱🇺', 'Luxembourg', '+352'),
  _Country('🇲🇬', 'Madagascar', '+261'),
  _Country('🇲🇼', 'Malawi', '+265'),
  _Country('🇲🇾', 'Malaysia', '+60'),
  _Country('🇲🇻', 'Maldives', '+960'),
  _Country('🇲🇱', 'Mali', '+223'),
  _Country('🇲🇹', 'Malta', '+356'),
  _Country('🇲🇷', 'Mauritania', '+222'),
  _Country('🇲🇺', 'Mauritius', '+230'),
  _Country('🇲🇽', 'Mexico', '+52'),
  _Country('🇲🇩', 'Moldova', '+373'),
  _Country('🇲🇨', 'Monaco', '+377'),
  _Country('🇲🇳', 'Mongolia', '+976'),
  _Country('🇲🇪', 'Montenegro', '+382'),
  _Country('🇲🇦', 'Morocco', '+212'),
  _Country('🇲🇿', 'Mozambique', '+258'),
  _Country('🇲🇲', 'Myanmar', '+95'),
  _Country('🇳🇦', 'Namibia', '+264'),
  _Country('🇳🇵', 'Nepal', '+977'),
  _Country('🇳🇱', 'Netherlands', '+31'),
  _Country('🇳🇿', 'New Zealand', '+64'),
  _Country('🇳🇮', 'Nicaragua', '+505'),
  _Country('🇳🇪', 'Niger', '+227'),
  _Country('🇳🇬', 'Nigeria', '+234'),
  _Country('🇲🇰', 'North Macedonia', '+389'),
  _Country('🇳🇴', 'Norway', '+47'),
  _Country('🇴🇲', 'Oman', '+968'),
  _Country('🇵🇰', 'Pakistan', '+92'),
  _Country('🇵🇦', 'Panama', '+507'),
  _Country('🇵🇬', 'Papua New Guinea', '+675'),
  _Country('🇵🇾', 'Paraguay', '+595'),
  _Country('🇵🇪', 'Peru', '+51'),
  _Country('🇵🇭', 'Philippines', '+63'),
  _Country('🇵🇱', 'Poland', '+48'),
  _Country('🇵🇹', 'Portugal', '+351'),
  _Country('🇶🇦', 'Qatar', '+974'),
  _Country('🇷🇴', 'Romania', '+40'),
  _Country('🇷🇺', 'Russia', '+7'),
  _Country('🇷🇼', 'Rwanda', '+250'),
  _Country('🇸🇦', 'Saudi Arabia', '+966'),
  _Country('🇸🇳', 'Senegal', '+221'),
  _Country('🇷🇸', 'Serbia', '+381'),
  _Country('🇸🇱', 'Sierra Leone', '+232'),
  _Country('🇸🇬', 'Singapore', '+65'),
  _Country('🇸🇰', 'Slovakia', '+421'),
  _Country('🇸🇮', 'Slovenia', '+386'),
  _Country('🇸🇴', 'Somalia', '+252'),
  _Country('🇿🇦', 'South Africa', '+27'),
  _Country('🇸🇸', 'South Sudan', '+211'),
  _Country('🇪🇸', 'Spain', '+34'),
  _Country('🇱🇰', 'Sri Lanka', '+94'),
  _Country('🇸🇩', 'Sudan', '+249'),
  _Country('🇸🇷', 'Suriname', '+597'),
  _Country('🇸🇪', 'Sweden', '+46'),
  _Country('🇨🇭', 'Switzerland', '+41'),
  _Country('🇸🇾', 'Syria', '+963'),
  _Country('🇹🇼', 'Taiwan', '+886'),
  _Country('🇹🇯', 'Tajikistan', '+992'),
  _Country('🇹🇿', 'Tanzania', '+255'),
  _Country('🇹🇭', 'Thailand', '+66'),
  _Country('🇹🇱', 'Timor-Leste', '+670'),
  _Country('🇹🇬', 'Togo', '+228'),
  _Country('🇹🇹', 'Trinidad & Tobago', '+1-868'),
  _Country('🇹🇳', 'Tunisia', '+216'),
  _Country('🇹🇷', 'Turkey', '+90'),
  _Country('🇹🇲', 'Turkmenistan', '+993'),
  _Country('🇺🇬', 'Uganda', '+256'),
  _Country('🇺🇦', 'Ukraine', '+380'),
  _Country('🇦🇪', 'United Arab Emirates', '+971'),
  _Country('🇬🇧', 'United Kingdom', '+44'),
  _Country('🇺🇸', 'United States', '+1'),
  _Country('🇺🇾', 'Uruguay', '+598'),
  _Country('🇺🇿', 'Uzbekistan', '+998'),
  _Country('🇻🇪', 'Venezuela', '+58'),
  _Country('🇻🇳', 'Vietnam', '+84'),
  _Country('🇾🇪', 'Yemen', '+967'),
  _Country('🇿🇲', 'Zambia', '+260'),
  _Country('🇿🇼', 'Zimbabwe', '+263'),
];

_Country _defaultCountry() =>
    _countries.firstWhere((c) => c.dialCode == '+91');

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

  late _Country _mobileCountry;
  late _Country _whatsappCountry;

  static final _addressRegex = RegExp(r'^[a-zA-Z0-9\s,\-/\.]+$');
  static final _lettersOnly  = RegExp(r'^[a-zA-Z\s]+$');
  static final _emailRegex   = RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w{2,4}$');

  // Validation: 10-digit Indian rule for +91, else 5–15 digits for others
  String? _validatePhone(String val, String label) {
    if (val.isEmpty) return 'Enter a valid $label';
    if (!RegExp(r'^\d+$').hasMatch(val)) return 'Digits only';
    if (val.length < 5 || val.length > 15) return 'Enter a valid $label';
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
    _mobileCountry = _countries.firstWhere(
      (c) => c.dialCode == widget.family.mobileCountryCode,
      orElse: _defaultCountry,
    );
    _whatsappCountry = _countries.firstWhere(
      (c) => c.dialCode == widget.family.whatsappCountryCode,
      orElse: _defaultCountry,
    );

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
  void _showCountryPicker(_Country current, void Function(_Country) onSelected) {
    final searchCtrl = TextEditingController();
    List<_Country> filtered = List.from(_countries);

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
                      filtered = _countries
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
  Widget _countryPrefix(_Country country, VoidCallback onTap) {
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
    required _Country country,
    required void Function(_Country) onCountryChange,
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
              if (val.length < 10) return 'Enter a valid address (min 10 characters)';
              if (val.length > 200) return 'Address too long (max 200 chars)';
              if (!_addressRegex.hasMatch(val)) return 'Enter a valid address (min 10 characters)';
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
              if (val.length < 2) return 'Enter a valid native place (letters only)';
              if (val.length > 100) return 'Too long (max 100 chars)';
              if (!_lettersOnly.hasMatch(val)) return 'Enter a valid native place (letters only)';
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
                    if (val.length < 2) return 'Enter a valid city name';
                    if (val.length > 50) return 'Too long (max 50 chars)';
                    if (!_lettersOnly.hasMatch(val)) return 'Enter a valid city name';
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
                    if (val.length != 6) return 'Enter a valid 6-digit PIN code';
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
                (v == null || v.isEmpty) ? 'Please select a state' : null,
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
              return _validatePhone(val, '10-digit mobile number');
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
              return _validatePhone(val, 'WhatsApp number');
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
            label: 'Email *',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              final val = v?.trim() ?? '';
              widget.family.email = val;
              if (!_emailRegex.hasMatch(val)) return 'Enter a valid email address';
              return null;
            },
          ),
        ],
      ),
    );
  }
}
