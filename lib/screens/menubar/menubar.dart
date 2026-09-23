import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:docautomations/widgets/AddPrescrip.dart';
import 'package:docautomations/widgets/doctormaster.dart';
import 'package:docautomations/widgets/doctorwelcomescreen.dart';
import 'package:docautomations/screens/patient/patient_search_screen.dart';
import 'package:docautomations/widgets/sharelogsscreen.dart';

class Menubar extends StatefulWidget {
  final Widget body;
  final VoidCallback onLogout;

  const Menubar({
    super.key,
    required this.body,
    required this.onLogout,
  });

  static _MenubarState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MenubarState>();
  }

  @override
  State<Menubar> createState() => _MenubarState();
}

class _MenubarState extends State<Menubar> {
  //===========================================================================
  // STATE
  //===========================================================================

  int _selectedIndex = 1;

  String _doctorName = 'Dr. Prescriptor';
  String _doctorInitials = 'DP';

  late final List<Widget> _screens;

  //===========================================================================
  // LIFECYCLE
  //===========================================================================

  @override
  void initState() {
    super.initState();

    _screens = [
      //const DoctorWelcomeScreen(),

      // Initial screen supplied by AppEntryPoint.
      widget.body,

      // const Addprescrip(
      //   title: 'Patient Diagnosis',
      // ),

      // const DoctorMaster(
      //   title: 'Profile Settings',
      // ),

      ShareLogsScreen(),
    ];

    _loadDoctorInfo();
  }

  //===========================================================================
  // DOCTOR INFORMATION
  //===========================================================================

  Future<void> _loadDoctorInfo() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    final name = prefs.getString('doctor_name') ?? 'Prescriptor';

    setState(() {
      _doctorName = 'Dr. $name';
      _doctorInitials = _getInitials(name);
    });
  }

  String _getInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'DP';

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return (
      parts.first[0] + parts.last[0]
    ).toUpperCase();
  }

  //===========================================================================
  // SCREEN NAVIGATION
  //===========================================================================

  void changeScreen(int index) {
    if (index < 0 || index >= _screens.length) return;

    setState(() {
      _selectedIndex = index;
    });
  }

  void _onMenuItemSelected(int index) {
    Navigator.of(context).pop();
    changeScreen(index);
  }

  //===========================================================================
  // BACK BUTTON
  //===========================================================================

  Future<bool> _handleBack() async {
    // If not on Home, return to Home first.
    if (_selectedIndex != 0) {
      changeScreen(0);
      return false;
    }

    // Already on Home: allow normal system back behavior.
    return true;
  }

  //===========================================================================
  // BUILD
  //===========================================================================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _selectedIndex != 0) {
          changeScreen(0);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Prescriptor'),
          centerTitle: false,
        ),

        drawer: _buildDrawer(),

        body: SafeArea(
          child: IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
        ),
      ),
    );
  }

  //===========================================================================
  // DRAWER
  //===========================================================================

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          _buildDrawerHeader(),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  index: 0,
                  title: 'Home',
                  icon: Icons.home,
                ),

                _buildMenuItem(
                  index: 1,
                  title: 'Find Patient',
                  icon: Icons.search,
                ),

                _buildMenuItem(
                  index: 2,
                  title: 'Patient Diagnosis',
                  icon: Icons.medical_services,
                ),

                _buildMenuItem(
                  index: 3,
                  title: 'Profile Settings',
                  icon: Icons.settings,
                ),

                _buildMenuItem(
                  index: 4,
                  title: 'Share Logs',
                  icon: Icons.bug_report,
                ),

                const Divider(),

                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () {
                    Navigator.of(context).pop();
                    widget.onLogout();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //===========================================================================
  // DRAWER HEADER
  //===========================================================================

  Widget _buildDrawerHeader() {
    return SizedBox(
      height: 220,
      child: DrawerHeader(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/healthcare_2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.lightBlue,
                child: ClipOval(
                  child: Image.asset(
                    'assets/icon/app_logo.png',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          _doctorInitials,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _doctorName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //===========================================================================
  // MENU ITEM
  //===========================================================================

  Widget _buildMenuItem({
    required int index,
    required String title,
    required IconData icon,
  }) {
    final selected = _selectedIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        size: 26,
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 18),
      ),
      selected: selected,
      selectedTileColor:
          Theme.of(context).colorScheme.primaryContainer,
      selectedColor:
          Theme.of(context).colorScheme.onPrimaryContainer,
      onTap: () => _onMenuItemSelected(index),
    );
  }
}