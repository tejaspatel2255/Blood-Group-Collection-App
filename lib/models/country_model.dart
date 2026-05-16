class Country {
  final String flag;
  final String name;
  final String dialCode;

  const Country({
    required this.flag,
    required this.name,
    required this.dialCode,
  });

  @override
  String toString() => '$flag $dialCode';
}
