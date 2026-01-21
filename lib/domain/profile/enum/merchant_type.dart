enum MerchantType {
  agriShop,
  supermarketVendor,
  nursery,
  vetClinic,
  feedSupplier,
  equipmentSupplier,
  transportService,
  processingUnit,
  other;

  String get displayName {
    switch (this) {
      case MerchantType.agriShop:
        return 'Agri Shop';
      case MerchantType.supermarketVendor:
        return 'Supermarket Vendor';
      case MerchantType.nursery:
        return 'Nursery';
      case MerchantType.vetClinic:
        return 'Vet Clinic';
      case MerchantType.feedSupplier:
        return 'Feed Supplier';
      case MerchantType.equipmentSupplier:
        return 'Equipment Supplier';
      case MerchantType.transportService:
        return 'Transport Service';
      case MerchantType.processingUnit:
        return 'Processing Unit';
      case MerchantType.other:
        return 'Other';
    }
  }

  static MerchantType fromString(String value) {
    return MerchantType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MerchantType.other,
    );
  }
}
