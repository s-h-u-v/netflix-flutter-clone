import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_gradients.dart';
import 'downloads_screen.dart';
import 'account_settings_screen.dart';
import '../auth/login_screen.dart';
import '../../services/settings_service.dart';
import '../../services/download_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;
    final settings = context.watch<SettingsService>();
    final downloads = context.watch<DownloadService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profiles & More'),
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
                      gradient: AppGradients.primary,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purpleDark.withValues(alpha: 0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user?.displayName ?? 'User Name',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            const Divider(color: Colors.grey),
            _buildListTile(Icons.download, 'My Downloads', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DownloadsScreen()),
              );
            }),
            _buildListTile(Icons.person_outline, 'Account Settings', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AccountSettingsScreen()),
              );
            }),
            _buildListTile(Icons.help_outline, 'Help Center', () {
              _showPlaceholderDialog(
                context,
                'Help Center',
                'Need help? Check out our FAQs or contact support.',
              );
            }),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _statusRow(
                        'Wi‑Fi Only Downloads',
                        settings.wifiOnlyDownloads ? 'ON' : 'OFF',
                      ),
                      _statusRow(
                        'Network',
                        downloads.network.name.toUpperCase(),
                      ),
                      _statusRow(
                        'Autoplay Next',
                        settings.autoplayNextEpisode ? 'ON' : 'OFF',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                context.read<DownloadService>().clearAll();
                context.read<SettingsService>().clearAll();
                auth.signOut();
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text(
                'Sign Out',
              style: TextStyle(color: AppColors.textMuted, fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Version: 1.0.0 (Offline Mode)',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showPlaceholderDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: AppColors.purpleLight),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textMuted),
      title: Text(
        title,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 18),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: AppColors.textMuted,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _statusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Text(value, style: const TextStyle(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
