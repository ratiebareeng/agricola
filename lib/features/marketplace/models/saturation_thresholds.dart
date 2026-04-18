/// Market-saturation thresholds used by the Crop Availability banner.
///
/// These defaults are intentionally cautious for MVP. Calibrate against
/// production data once the telemetry described in tasks/todo.md
/// ("Prod telemetry to calibrate thresholds") is in place:
///   1. marketplace_listings.sold_at lifecycle (time-to-sell)
///   2. weekly supply_snapshots table (supply-vs-demand baseline)
///   3. loss_calculations join (unsold / wasted volume)
///   4. weekly price trajectory per crop (falling price = glut signal)
///   5. app events around saturation screen views + preorder tap-through
///
/// Thresholds are flat (per-window) rather than per-crop for the MVP.
/// Per-crop tuning only makes sense once we have a per-crop demand baseline.
enum SaturationLevel { low, moderate, saturated }

/// Above this many kilograms of expected supply in a single window across
/// all farmers, treat the window as likely oversupplied.
const int kSaturatedKgThreshold = 500;

/// Between the moderate and saturated thresholds is a healthy supply band.
const int kModerateKgThreshold = 150;

/// Alternative signal: if enough distinct farmers are growing the same crop
/// for the same window, we flag saturation even if total kg is modest.
/// Kept permissive for MVP since seller count is a weaker signal than volume.
const int kSaturatedSellerCount = 10;

SaturationLevel saturationLevelFor({
  required int totalKg,
  required int sellerCount,
}) {
  if (totalKg >= kSaturatedKgThreshold || sellerCount >= kSaturatedSellerCount) {
    return SaturationLevel.saturated;
  }
  if (totalKg >= kModerateKgThreshold) return SaturationLevel.moderate;
  return SaturationLevel.low;
}
