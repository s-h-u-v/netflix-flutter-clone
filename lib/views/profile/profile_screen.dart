import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_provider.dart';
import '../../utils/constants.dart';
import 'downloads_screen.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _wifiOnlyDownloads = true;
  bool _smartDownloads = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profiles & More'),
        backgroundColor: Constants.backgroundColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // User Avatar
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user?.displayName ?? 'User Name',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // App settings
            _buildToggleTile(
              Icons.notifications_active_outlined, 
              'Allow Notifications', 
              _notificationsEnabled, 
              (val) => setState(() => _notificationsEnabled = val)
            ),
            _buildToggleTile(
              Icons.wifi, 
              'Wi-Fi Only Downloads', 
              _wifiOnlyDownloads, 
              (val) => setState(() => _wifiOnlyDownloads = val)
            ),
            _buildToggleTile(
              Icons.download_for_offline, 
              'Smart Downloads', 
              _smartDownloads, 
              (val) => setState(() => _smartDownloads = val)
            ),
            
            const Divider(color: Colors.grey),
            _buildListTile(Icons.download, 'My Downloads', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DownloadsScreen()));
            }),
            _buildListTile(Icons.person_outline, 'Account Setting', () {
              _showPlaceholderDialog(context, 'Account Settings', 'Here you can update your email, password, and subscription details.');
            }),
            _buildListTile(Icons.help_outline, 'Help Center', () {
              _showPlaceholderDialog(context, 'Help Center', 'Need help? Check out our FAQs or contact support.');
            }),
            
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                auth.signOut();
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text('Sign Out', style: TextStyle(color: Colors.grey, fontSize: 16)),
            ),
            const SizedBox(height: 10),
            const Text('Version: 1.0.0 (Offline Mode)', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showPlaceholderDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Constants.primaryColor)),
          )
        ],
      ),
    );
  }

  Widget _buildToggleTile(IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      secondary: Icon(icon, color: Colors.grey),
      title: Text(title, style: const TextStyle(color: Colors.white70, fontSize: 18)),
      value: value,
      activeColor: Constants.primaryColor,
      onChanged: onChanged,
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(title, style: const TextStyle(color: Colors.white70, fontSize: 18)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
      onTap: onTap,
    );
  }
}

