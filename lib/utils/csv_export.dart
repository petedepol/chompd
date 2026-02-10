import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';

class CsvExport {
  static const String _dateFormat = 'dd/MM/yyyy';
  static const String _headers =
      'Name,Price,Currency,Cycle,Next Renewal,Category,Status,Trial End Date,Cancelled Date';

  /// Generates a CSV string from a list of subscriptions
  /// Includes headers, subscription data, and a summary row with total monthly spend
  static String generate(List<Subscription> subscriptions) {
    final buffer = StringBuffer();

    // Add headers
    buffer.writeln(_headers);

    // Add subscription rows
    for (final subscription in subscriptions) {
      buffer.writeln(_buildSubscriptionRow(subscription));
    }

    // Calculate and add summary row
    final totalMonthlySpend = _calculateTotalMonthlySpend(subscriptions);
    buffer.writeln(_buildSummaryRow(totalMonthlySpend));

    return buffer.toString();
  }

  /// Exports subscriptions to a CSV file in the app's documents directory
  /// Returns the file path where the CSV was saved
  static Future<String> exportToFile(List<Subscription> subscriptions) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'subscriptions_$timestamp.csv';
    final filePath = '${directory.path}/$fileName';

    final file = File(filePath);
    final csvContent = generate(subscriptions);
    await file.writeAsString(csvContent);

    return filePath;
  }

  /// Builds a single CSV row for a subscription with proper escaping
  static String _buildSubscriptionRow(Subscription subscription) {
    final formatter = DateFormat(_dateFormat);

    final name = _escapeCsvField(subscription.name);
    final price = subscription.price.toStringAsFixed(2);
    final currency = subscription.currency;
    final cycle = subscription.cycle.label;
    final nextRenewal = formatter.format(subscription.nextRenewal);
    final category = _escapeCsvField(subscription.category);
    final status = _getStatus(subscription);
    final trialEndDate = subscription.trialEndDate != null
        ? formatter.format(subscription.trialEndDate!)
        : '';
    final cancelledDate = subscription.cancelledDate != null
        ? formatter.format(subscription.cancelledDate!)
        : '';

    return '$name,$price,$currency,$cycle,$nextRenewal,$category,$status,$trialEndDate,$cancelledDate';
  }

  /// Determines the status of a subscription
  static String _getStatus(Subscription subscription) {
    if (subscription.isTrial) {
      return 'Trial';
    } else if (!subscription.isActive) {
      return 'Cancelled';
    } else {
      return 'Active';
    }
  }

  /// Builds the summary row with total monthly spend
  static String _buildSummaryRow(double totalMonthlySpend) {
    final formattedSpend = totalMonthlySpend.toStringAsFixed(2);
    return 'TOTAL MONTHLY SPEND,,$formattedSpend';
  }

  /// Calculates total monthly spend from active subscriptions only
  /// Converts all cycles (weekly, quarterly, yearly) to monthly equivalent
  static double _calculateTotalMonthlySpend(List<Subscription> subscriptions) {
    double total = 0.0;

    for (final subscription in subscriptions) {
      // Only include active subscriptions
      if (!subscription.isActive) {
        continue;
      }

      total += subscription.monthlyEquivalent;
    }

    return total;
  }

  /// Escapes CSV fields according to RFC 4180
  /// If field contains comma, quote, or newline, wrap in quotes and escape quotes
  static String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}
