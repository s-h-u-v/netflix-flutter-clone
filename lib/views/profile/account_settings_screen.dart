import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_provider.dart';
import '../../services/settings_service.dart';
import '../../services/subscription_service.dart';
import '../../utils/constants.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<SettingsService>();
    final subscription = context.watch<SubscriptionService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        backgroundColor: Constants.backgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            title: 'Account Information',
            children: [
              _InfoRow(label: 'Email', value: auth.user?.email ?? '—'),
              const SizedBox(height: 10),
              _InfoRow(label: 'Username', value: auth.user?.displayName ?? '—'),
              const SizedBox(height: 10),
              _InfoRow(
                label: 'Plan',
                value: subscription.isPro ? 'Pro (₹100)' : 'Free',
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[850],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () => _showChangePasswordDialog(context),
                child: const Text('Change Password'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Subscription',
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  subscription.isPro ? Icons.workspace_premium : Icons.lock_open,
                  color: Colors.white70,
                ),
                title: Text(
                  subscription.isPro ? 'You are on Pro' : 'You are on Free',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  subscription.isPro
                      ? 'Access all videos'
                      : 'Free plan allows only 2 videos',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
              const SizedBox(height: 8),
              if (!subscription.isPro)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 46),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () async {
                    final sub = context.read<SubscriptionService>();
                    final ok = await _showDemoPaymentDialog(context);
                    if (!ok) return;
                    if (!context.mounted) return;
                    await sub.setPlan(SubscriptionPlan.pro);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pro activated (demo).')),
                    );
                  },
                  child: const Text('Upgrade to Pro (Pay ₹100)'),
                )
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[850],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 46),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () async {
                    if (!context.mounted) return;
                    final sub = context.read<SubscriptionService>();
                    await sub.setPlan(SubscriptionPlan.free);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Downgraded to Free.')),
                    );
                  },
                  child: const Text('Downgrade to Free'),
                ),
              const SizedBox(height: 6),
              Text(
                'This is a demo payment model. No real payment is processed.',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Playback',
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.play_circle_outline, color: Colors.white70),
                title: const Text(
                  'Autoplay Next Episode',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  settings.autoplayNextEpisode ? 'ON' : 'OFF',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                value: settings.autoplayNextEpisode,
                activeThumbColor: Constants.primaryColor,
                onChanged: (val) => context.read<SettingsService>().setAutoplayNextEpisode(val),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Downloads',
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.wifi, color: Colors.white70),
                title: const Text(
                  'Wi‑Fi Only Downloads',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  settings.wifiOnlyDownloads ? 'ON' : 'OFF',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                value: settings.wifiOnlyDownloads,
                activeThumbColor: Constants.primaryColor,
                onChanged: (val) => context.read<SettingsService>().setWifiOnlyDownloads(val),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'When enabled, downloads and downloads access require Wi‑Fi.',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final current = TextEditingController();
    final next = TextEditingController();
    final next2 = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Change Password', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: current,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current password',
                labelStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: next,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New password (min 6 chars)',
                labelStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: next2,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm new password',
                labelStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              if (next.text != next2.text) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match.')),
                );
                return;
              }
              final ok = await context.read<AuthProvider>().changePassword(
                    currentPassword: current.text,
                    newPassword: next.text,
                  );
              if (!context.mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ok ? 'Password updated.' : 'Password update failed.'),
                ),
              );
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDemoPaymentDialog(BuildContext context) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Demo payment', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Confirm demo payment of ₹100 to activate Pro.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Pay ₹100', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return res ?? false;
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(color: Colors.grey[400]),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

