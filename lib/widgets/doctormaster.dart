import 'package:docautomations/services/license_api_service.dart';
import 'package:docautomations/widgets/doctorinfo.dart';
import 'package:docautomations/widgets/doctormasterscr.dart';
import 'package:flutter/material.dart';


class DoctorMaster extends StatefulWidget {
   final String title;
  const DoctorMaster({super.key, required this.title});

  @override
  State<DoctorMaster> createState() => _DoctorMasterState();
}

class _DoctorMasterState extends State<DoctorMaster> {
   DoctorInfo? _doctorInfo;
  bool _loading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _loadLoggedInDoctor();
  }
  Future<void> _loadLoggedInDoctor() async {
    try {
      // Uses your authenticated GET -> /api/doctor/me
      final doc = await LicenseApiService.fetchCurrentDoctor();
      if (!mounted) return;

      if (doc != null) {
        setState(() {
          _doctorInfo = doc;
          _loading = false;
        });
      } else {
        setState(() {
          _error = "Couldn’t load doctor profile.";
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = "Error loading profile: $e";
        _loading = false;
      });
    }
  }

  Future<void> _handleUpdated(DoctorInfo updated) async {
    setState(() => _doctorInfo = updated);

    // Optionally persist immediately:
    final ok = await LicenseApiService.updateDoctorOnServer(updated);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? "Doctor updated." : "Update failed. Please retry."),
      ),
    );

    if (!ok) {
      // Reload from server to avoid stale UI if update failed
      _loadLoggedInDoctor();
    }
  }


  @override
  Widget build(BuildContext context) {

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

   if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _loading = true;
                  });
                  _loadLoggedInDoctor();
                },
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(color: Theme.of(context).colorScheme.onSecondary),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: DoctorMasterScr(
        doctorInfo: _doctorInfo!,     // <-- pass loaded doctor down
        onUpdated: _handleUpdated,    // <-- receive edited info back
      ),
    );
  }
  
}
  