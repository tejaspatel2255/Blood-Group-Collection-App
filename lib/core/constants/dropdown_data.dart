class DropdownData {
  static const List<String> bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  static const List<String> genders = ['Male', 'Female', 'Other'];
  static const List<String> maritalStatus = ['Single', 'Married', 'Divorced', 'Widowed'];
  static const List<String> maritalStatuses = maritalStatus; // Alias for UI
  
  static const List<String> indianStates = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram',
    'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu',
    'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
    'Andaman and Nicobar Islands', 'Chandigarh', 'Dadra and Nagar Haveli and Daman and Diu',
    'Delhi', 'Jammu and Kashmir', 'Ladakh', 'Lakshadweep', 'Puducherry'
  ];

  static const List<String> educationList = [
    'No Education', 'Primary', 'Secondary/SSC',
    'HSC', 'ITI/Diploma', 'BA',
    'BCom', 'BSc',
    'BE/BTech', 'BEd',
    'LLB', 'MBBS',
    'BPharm', 'BCA',
    'BBA', 'BArch',
    'MA', 'MCom', 'MSc',
    'ME/MTech', 'MBA',
    'MCA', 'LLM',
    'MEd', 'MPharm',
    'MD', 'PhD',
    'CA', 'CS', 'CMA/ICWA', 'Other'
  ];

  static const List<String> occupationList = [
    'Student', 'Government Job', 'Private Job', 'Business/Self-Employed',
    'Farmer', 'Doctor', 'Engineer', 'Lawyer', 'Teacher', 'Police/Military',
    'Homemaker', 'Retired', 'Unemployed', 'Other'
  ];

  static const List<String> annualIncomeList = [
    'Below 1 Lakh', '1-3 Lakh', '3-5 Lakh', '5-10 Lakh', 'Above 10 Lakh'
  ];

  static const List<String> relationshipList = [
    'Father', 'Mother', 'Husband', 'Wife',
    'Son', 'Daughter', 'Daughter-in-law', 'Brother', 'Sister',
    'Uncle', 'Aunty', 'Grand Son', 'Grand Daughter', 'Other'
  ];
}
