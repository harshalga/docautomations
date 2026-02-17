
import 'package:docautomations/widgets/AddPrescrip.dart';
import 'package:docautomations/widgets/doctormaster.dart';
import 'package:docautomations/widgets/doctorwelcomescreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import  'package:docautomations/widgets/sharelogsscreen.dart';




class Menubar extends StatefulWidget {
  final Widget body; // 👈 new
  final VoidCallback onLogout; // 👈 new

  const Menubar({super.key, required this.body,required this.onLogout});

 // ⭐ ADD THIS
  static _MenubarState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MenubarState>();
  }

  @override
  State<Menubar> createState() => _MenubarState();
}

class _MenubarState extends State<Menubar> {
  bool isHome = false; // 👈 track if we're on home screen or not 
String doctorName = ""; // store doctor name here
 String doctorInitials = "";
  late Widget currentBody; // 👈 this will hold the page shown in the body
  @override
  void initState() {
    super.initState();
    _loadDoctorInfo(); // load on widget creation
     currentBody = widget.body; // 👈 start with the body passed from AppEntryPoint
  }

  void changeScreen(Widget screen) {
  setState(() {
    currentBody = screen;
  });
}

  Future<void> _loadDoctorInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('doctor_name') ?? "Dr. Prescriptor";
    setState(() {
      doctorName ="Dr. $name" ;
      doctorInitials = _getInitials(name);
    });
  }
  String _getInitials(String name) {
    final parts = name.trim().split(" ");
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    } else {
      return (parts[0][0] + parts.last[0]).toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return 
    PopScope(
  canPop: isHome,
  onPopInvokedWithResult: (didPop, result) {
    if (!didPop && !isHome) {
      setState(() {
        currentBody = const DoctorWelcomeScreen();
        isHome = true;
      });
    }
  },
    child: Scaffold(
      appBar: AppBar(title: const Text("Prescriptor")),
      drawer: Drawer(
  child: Column(
    children: [
      // ================= HEADER =================
      SizedBox(
        height: 220, // ✅ FIXED HEIGHT (important)
        child: DrawerHeader(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage("images/healthcare_2.png"),
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Dark overlay
  //            Container(color: Colors.black.withOpacity(0.4)),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar / Logo
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.lightBlue,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          "assets/icon/app_logo.png",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                doctorInitials,
                                style: const TextStyle(
                                  fontSize: 26,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
// 👇 DARK OVERLAY ONLY HERE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              borderRadius: BorderRadius.circular(8),
            ),
                    // Doctor name (SAFE)
                    child :Text(
                      doctorName,
                      maxLines: 2, // ✅ prevents overflow
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20, // ⬅ reduced from 26
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // ================= MENU =================
      Expanded(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              leading: const Icon(Icons.home, size: 26),
              title: const Text("HomePage", style: TextStyle(fontSize: 20)),
              onTap: () {
                setState(() {
                  currentBody = const DoctorWelcomeScreen();
                  isHome = true;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, size: 26),
              title: const Text("Patient Diagnosis", style: TextStyle(fontSize: 20)),
              onTap: () {
                setState(() {
                  currentBody = const Addprescrip(title: "Patient Diagnosis");
                  isHome = false;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, size: 26),
              title: const Text("Profile Settings", style: TextStyle(fontSize: 20)),
              onTap: () {
                setState(() {
                  currentBody = const DoctorMaster(title: "Profile Settings");
                  isHome = false;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bug_report, size: 26),
              title: const Text("Share Logs", style: TextStyle(fontSize: 20)),
              onTap: () {
                setState(() {
                  currentBody = ShareLogsScreen();
                  isHome = false;
                });
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, size: 26),
              title: const Text("Logout", style: TextStyle(fontSize: 20)),
              onTap: () {
                Navigator.pop(context);
                widget.onLogout();
              },
            ),
          ],
        ),
      ),
    ],
  ),
),

        body: SafeArea(child:currentBody), //widget.body, // 👈 load dynamic body here
      resizeToAvoidBottomInset: false,
    )
    );
  }
}




