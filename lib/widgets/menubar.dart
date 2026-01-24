
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
    return Scaffold(
      appBar: AppBar(title: const Text("Prescriptor")),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage("images/healthcare_2.png"),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.lightBlue,
                    ),
                    //child:  Center(child: Text(doctorInitials, style: TextStyle(fontSize: 26))),
                     child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Image.asset(
            "assets/icon/app_logo.png",
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // 👇 fallback to initials if logo missing
              return Center(
                child: Text(
                  doctorInitials,
                  style: const TextStyle(fontSize: 26, color: Colors.white),
                ),
              );
            },
          ),
        ),
      
                  ),
                  const SizedBox(height: 20),
                  // Text(doctorName, style: TextStyle(color: Colors.black, fontSize: 26)),
                   // Semi-transparent black container behind the doctor name
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: Colors.black.withOpacity(0.5),
        child: Text(
          doctorName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
                ],
              ),
            ),
            ListTile(
               onTap: (){
               setState(() {
      currentBody = const DoctorWelcomeScreen();
    });
    Navigator.pop(context); // close drawer
  },
    // { Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => const DoctorWelcomeScreen()),
    // );},
              leading: const Icon(Icons.home, size: 26, color: Colors.black),
              title: const Text("HomePage", style: TextStyle(fontSize: 20)),
            ),
            ListTile(
              // onTap: () {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(builder: (context) => const Addprescrip(title: "PatientInfo")),
              //   );
              // },
               onTap: (){
               setState(() {
      currentBody = const Addprescrip(title: "Patient Diagnosis");
    });
    Navigator.pop(context); // close drawer
  },
              leading: const Icon(Icons.info, size: 26, color: Colors.black),
              title: const Text("Patient Diagnosis", style: TextStyle(fontSize: 20)),
            ),
            ListTile(
              onTap: () {setState(() {
      currentBody = const DoctorMaster(title: "Profile Settings");
    });
    Navigator.pop(context);},
              leading: const Icon(Icons.settings, size: 26, color: Colors.black),
              title: const Text("Profile Settings", style: TextStyle(fontSize: 20)),
             ),

             ListTile(
              onTap: () {setState(() {
      currentBody =  ShareLogsScreen();
    });
    Navigator.pop(context);},
              leading: const Icon(Icons.bug_report, size: 26, color: Colors.black),
              title: const Text("Share Logs", style: TextStyle(fontSize: 20)),
             ),
            // ListTile(
            //   onTap: () {},
            //   leading: const Icon(Icons.settings, size: 26, color: Colors.black),
            //   title: const Text("Settings", style: TextStyle(fontSize: 20)),
            // ),
            const Divider(color: Colors.black),
            ListTile(
              onTap: () {

                Navigator.pop(context); // close drawer
                 widget.onLogout();      // 👈 call parent logout
              },
              leading: const Icon(Icons.logout, size: 26, color: Colors.black),
              title: const Text("Logout", style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
      body: SafeArea(child:currentBody), //widget.body, // 👈 load dynamic body here
      resizeToAvoidBottomInset: false,
    );
  }
}




