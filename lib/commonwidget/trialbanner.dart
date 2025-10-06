import 'package:docautomations/common/licenseprovider.dart';
import 'package:flutter/material.dart';
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
          "🎉 Free trial expires on ${license.trialEndDate ?? '-'} | "
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



// import 'package:docautomations/common/licenseprovider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:marquee/marquee.dart';

// class TrialBanner extends StatelessWidget {
//   final Color backgroundColor;
//   final Color textColor;

//   const TrialBanner({
//     super.key,
//     this.backgroundColor = Colors.orange,
//     this.textColor = Colors.white,
//   });

//   int _calculateDaysLeft(DateTime? trialEndDate) {
//     if (trialEndDate == null) return 0;
//     final now = DateTime.now();
//     final diff = trialEndDate.difference(now).inDays;
//     return diff > 0 ? diff : 0;
//   }

//   @override
//   Widget build(BuildContext context) {
    
//     final license = context.watch<LicenseProvider>();

//     final int usedPrescriptions = license.prescriptionCount ?? 0;
// final int presRemaining = 100 - usedPrescriptions;
// final int daysLeft = _calculateDaysLeft(license.trialEndDate);


    
    

//     final String message =
//         "Your free trial expires on ${license.trialEndDate?.toLocal().toString().split(' ')[0] ?? 'N/A'}, "
//         "Days left: $daysLeft   "
//         "Prescriptions used: $usedPrescriptions / 100 "
//         "(Remaining: $presRemaining)";

//     return Container(
//       width: double.infinity,
//       height: 40, // fixed height for marquee
//       color: backgroundColor,
//       child: Marquee(
//         text: message,
//         style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//               color: textColor,
//               fontWeight: FontWeight.bold,
//             ),
//         scrollAxis: Axis.horizontal,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         blankSpace: 50.0,
//         velocity: 50.0,
//         pauseAfterRound: const Duration(seconds: 1),
//         startPadding: 10.0,
//         accelerationDuration: const Duration(seconds: 1),
//         decelerationDuration: const Duration(milliseconds: 500),
//       ),
//     );
//   }
// }


// import 'package:docautomations/common/licenseprovider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class TrialBanner extends StatelessWidget {
//   final Color backgroundColor;
//   final Color textColor;

//   const TrialBanner({
//     super.key,
//     this.backgroundColor = Colors.orange,
//     this.textColor = Colors.white,
//   });

//   int _calculateDaysLeft(DateTime? trialEndDate) {
//     if (trialEndDate == null) return 0;
//     final now = DateTime.now();
//     final diff = trialEndDate.difference(now).inDays;
//     return diff > 0 ? diff : 0;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final license = context.watch<LicenseProvider>();

//     final int presRemaining = 100 - (license.prescriptionCount);
//     final int daysLeft = _calculateDaysLeft(license.trialEndDate);

//     final String message = 
//         "Your free trial expires on ${license.trialEndDate?.toLocal().toString().split(' ')[0] ?? 'N/A'}, "
//         "Days left: $daysLeft   "
//         "Prescriptions used: ${license.prescriptionCount} / 100 "
//         "(Remaining: $presRemaining)";

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       color: backgroundColor,
//       child: Text(
//         message,
//         style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//               color: textColor,
//               fontWeight: FontWeight.bold,
//             ),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }
// }



// import 'package:docautomations/common/licenseprovider.dart';
// import 'package:flutter/material.dart';

// class TrialBanner extends StatelessWidget {
//   final String message;
//   final Color backgroundColor;
//   final Color textColor;

//   const TrialBanner({

//     int prescountremainining = 100-context.read<LicenseProvider>().prescriptionCount;
//     _message=  "Your free trial expires on ${context.read<LicenseProvider>().trialEndDate}, Days left: ${_calculateDaysLeft(context.read<LicenseProvider>().trialEndDate)}   "
//           "Prescriptions used: $prescountremainining of 100";
          
//     super.key,
//     this.message = "🎉 You are on 30-day Free Trial",
//     this.backgroundColor = Colors.orange,
//     this.textColor = Colors.white,
//   });

//   int _calculateDaysLeft(DateTime? trialEndDate) {
//   if (trialEndDate == null) return 0;
//   final now = DateTime.now();
//   final diff = trialEndDate.difference(now).inDays;
//   return diff > 0 ? diff : 0;
// }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       color: backgroundColor,
//       child: Text(
//         message,
//         style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//               color: textColor,
//               fontWeight: FontWeight.bold,
//             ),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }
// }
