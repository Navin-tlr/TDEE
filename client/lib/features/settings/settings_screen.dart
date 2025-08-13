import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Profile Section
          _buildSectionHeader(context, 'Profile'),
          _buildListTile(
            context,
            icon: Icons.person_outline,
            title: 'Edit Profile',
            subtitle: 'Height, age, sex, activity level',
            onTap: () {
              // TODO: Navigate to profile edit
            },
          ),
          const Divider(),

          // Units Section
          _buildSectionHeader(context, 'Units'),
          _buildListTile(
            context,
            icon: Icons.straighten_outlined,
            title: 'Weight Units',
            subtitle: 'kg / lb',
            trailing: const Text('kg'),
            onTap: () {
              // TODO: Show unit picker
            },
          ),
          _buildListTile(
            context,
            icon: Icons.local_fire_department_outlined,
            title: 'Energy Units',
            subtitle: 'kcal / kJ',
            trailing: const Text('kcal'),
            onTap: () {
              // TODO: Show unit picker
            },
          ),
          const Divider(),

          // Data Section
          _buildSectionHeader(context, 'Data'),
          _buildListTile(
            context,
            icon: Icons.download_outlined,
            title: 'Export Data',
            subtitle: 'CSV / JSON format',
            onTap: () {
              // TODO: Implement data export
            },
          ),
          _buildListTile(
            context,
            icon: Icons.backup_outlined,
            title: 'Backup & Restore',
            subtitle: 'Cloud backup settings',
            onTap: () {
              // TODO: Implement backup
            },
          ),
          const Divider(),

          // Algorithm Section
          _buildSectionHeader(context, 'Algorithm'),
          _buildListTile(
            context,
            icon: Icons.tune_outlined,
            title: 'Algorithm Constants',
            subtitle: 'γ, k, K (advanced)',
            onTap: () {
              // TODO: Show algorithm constants
            },
          ),
          const Divider(),

          // Account Section
          _buildSectionHeader(context, 'Account'),
          _buildListTile(
            context,
            icon: Icons.logout_outlined,
            title: 'Sign Out',
            subtitle: 'Sign out of your account',
            onTap: () {
              ref.read(authServiceProvider).signOut();
            },
          ),
          _buildListTile(
            context,
            icon: Icons.delete_forever_outlined,
            title: 'Delete Account',
            subtitle: 'Permanently delete all data (GDPR)',
            onTap: () {
              _showDeleteAccountDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to permanently delete your account? '
          'This action cannot be undone and all your data will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement account deletion
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
