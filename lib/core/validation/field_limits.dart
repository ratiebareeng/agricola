/// Single source of truth for field length caps and numeric ceilings.
///
/// Caps are enforced at the keyboard layer via `LengthLimitingTextInputFormatter`
/// in `AppTextField`, and again defensively by shared validators in
/// `validators.dart`. Numeric ceilings exist to prevent `double` infinity/NaN
/// from propagating into totals — they are not business rules.
library;

// --- Identifiers / short text -----------------------------------------------

const kMaxEmail = 254; // RFC 5321 path maximum
const kMinPassword = 8;
const kMaxPassword = 128;

const kMaxName = 50; // first/last name, display name
const kMaxBusinessName = 100;
const kMaxVillage = 100;
const kMaxSellerName = 100;
const kMaxCustomUnit = 30;
const kMaxCustomStorageLocation = 100;
const kMaxCustomFarmSize = 50;
const kMaxCropType = 50;
const kMaxListingTitle = 100;

// --- Long text --------------------------------------------------------------

const kMaxNotes = 500;
const kMaxDescription = 1000;

// --- Phone (Botswana) -------------------------------------------------------

/// Botswana mobile numbers are 8 digits. This app assumes all users have a
/// Botswana cellphone until country-code support is added.
const kBotswanaPhoneLength = 8;

// --- Numeric ceilings -------------------------------------------------------

/// Max quantity (kg, bags, etc.) for a single inventory/listing item.
const kMaxQuantity = 1000000.0;

/// Max digits the user can type into a quantity field.
/// 7 digits covers 9,999,999; ceiling above is 1,000,000 — leaves headroom.
const kMaxQuantityDigits = 7;

/// Max per-unit price (BWP). P10M covers agricultural machinery and bulk
/// assets; catches typos without rejecting realistic high-value listings.
const kMaxUnitPrice = 10000000.0;

/// Max digits (excluding decimal point) in a unit-price field.
const kMaxUnitPriceDigits = 10; // "10000000.00"

/// Max total offer/purchase amount (BWP). Headroom above unit-price × quantity.
const kMaxOfferAmount = 100000000.0;
const kMaxOfferDigits = 12;
