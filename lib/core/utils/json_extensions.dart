extension JsonParsing on Map<String, dynamic> {
  String? optionalString(String key) => this[key]?.toString();
  String requiredString(String key) => this[key]?.toString() ?? '';

  int? optionalInt(String key) => this[key] != null ? int.parse(this[key].toString()) : null;
  int requiredInt(String key) => int.parse(this[key].toString());

  double? optionalDouble(String key) => this[key] != null ? double.parse(this[key].toString()) : null;
  double requiredDouble(String key) => double.parse(this[key].toString());
}
