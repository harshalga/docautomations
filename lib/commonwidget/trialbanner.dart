import 'package:docautomations/common/licenseprovider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:marquee/marquee.dart';

class TrialBanner extends StatelessWidget {
  const TrialBanner({super.key});

  int _calculateDaysLeft(DateTime? trialEndDate) {
    if (trialEndDate == null) return 0;
    final now = DateTime.now();
    final diff = trialEndDate.difference(now).inDays;
    return diff > 0 ? diff : 0;
  }

  @override
  Widget build(BuildContext context) {
    try {
      final license = context.watch<LicenseProvider>();

      final int usedPrescriptions = license.prescriptionCount;
      final int presRemaining = 100 - usedPrescriptions;
      final int daysLeft = _calculateDaysLeft(license.trialEndDate);
      
      final message =
          "🎉 Free trial expires on ${DateFormat('dd/MM/yyyy HH:mm:ss').format(license.trialEndDate!) } | "
          "Days left: $daysLeft | "
          "Used: $usedPrescriptions / 100 | "
          "Remaining: $presRemaining";

      return Container(
        height: 40,
        color: Colors.orange,
        child: Marquee(
          text: message,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
          scrollAxis: Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.center,
          blankSpace: 50.0,
          velocity: 50.0,
          pauseAfterRound: const Duration(seconds: 1),
          startPadding: 10.0,
        ),
      );
    } catch (e, st) {
      debugPrint("⚠️ TrialBanner error: $e\n$st");
      return Container(
        padding: const EdgeInsets.all(8),
        color: Colors.orange,
        child: const Text(
          "🎉 Free trial active",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );
    }
  }
}




