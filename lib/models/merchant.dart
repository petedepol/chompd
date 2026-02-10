import 'package:isar/isar.dart';

part 'merchant.g.dart';

/// Recognition tier for the 3-tier intelligence flywheel.
///
/// - Tier 1: Auto-detect — unambiguous merchants, no API call needed.
/// - Tier 2: Quick Confirm — learned from users, single-tap confirm.
/// - Tier 3: Full Question — new/ambiguous, needs multiple-choice Q&A.
enum MerchantTier {
  autoDetect, // Tier 1
  quickConfirm, // Tier 2
  fullQuestion, // Tier 3
}

/// Merchant intelligence database model.
///
/// Stores learned patterns from AI scans so repeat encounters
/// can be resolved instantly without an API call (Tier 1/2).
/// This is the local side of the "intelligence flywheel".
@collection
class Merchant {
  Id id = Isar.autoIncrement;

  /// The raw pattern string from a bank statement or receipt.
  /// e.g. "AMZN DIGITAL*7.99", "NETFLIX.COM"
  @Index(unique: true, caseSensitive: false)
  String pattern = '';

  /// The human-readable resolved name.
  /// e.g. "Kindle Unlimited", "Netflix"
  String resolvedName = '';

  /// Confidence score from 0.0 to 1.0.
  double confidence = 0.0;

  /// Recognition tier (1, 2, or 3).
  @enumerated
  MerchantTier tier = MerchantTier.fullQuestion;

  /// How many users/scans have confirmed this mapping.
  int confirmCount = 0;

  /// Default category for this merchant.
  String? category;

  /// Icon identifier.
  String? icon;

  /// Brand colour hex string.
  String? color;

  /// Default billing cycle if known.
  String? defaultCycle;

  /// When this record was first created.
  DateTime createdAt = DateTime.now();

  /// When this record was last updated/confirmed.
  DateTime updatedAt = DateTime.now();
}
