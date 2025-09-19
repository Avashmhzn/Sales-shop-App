import 'package:flutter/material.dart';
import 'package:saleup_app/screen/setting/view/persnal_detail_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _currentIndex = 3; // Changed to 3 to match a valid index in BottomNav

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Add navigation logic here if needed for other tabs
    if (index == 3) {
      // Already on settings, no navigation needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 20),
          // "Settings" title
          const Text(
            'Settings',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          // Search bar with centered "SETTINGS" text
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search settings',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
              ),
            ],
          ),
          // Account Settings Section
          const Text(
            'Account Settings',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(
              Icons.person_outline,
              color: Colors.orange,
              size: 24,
            ),
            title: const Text(
              'Personal Details',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PersonalDetailsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.lock_outline,
              color: Colors.orange,
              size: 24,
            ),
            title: const Text(
              'Password and Security',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(
              Icons.info_outline,
              color: Colors.orange,
              size: 24,
            ),
            title: const Text(
              'Your information and permissions',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(
              Icons.notifications_outlined,
              color: Colors.orange,
              size: 24,
            ),
            title: const Text(
              'Notifications & Alert',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            onTap: () {},
          ),
          const SizedBox(height: 20),
          // Miscellaneous Section
          const Text(
            'Miscellaneous',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(
              Icons.language_outlined,
              color: Colors.orange,
              size: 24,
            ),
            title: const Text(
              'Language Preferences',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(
              Icons.access_time,
              color: Colors.orange,
              size: 24,
            ),
            title: const Text(
              'Time Zone',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(
              Icons.phone_android,
              color: Colors.orange,
              size: 24,
            ),
            title: const Text(
              'App Version',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}