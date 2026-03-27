import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/api_config.dart';
import '../../../data/datasources/local/hive_boxes.dart';
import '../../../data/models/user_profile_model.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final user = HiveBoxes.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // User Profile Section
          _buildSectionHeader('Profile'),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryGreen,
              child: Text(
                (user.name ?? 'U')[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(user.name ?? 'Guest User'),
            subtitle: Text('Member since ${_formatDate(user.createdAt)}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _editProfile,
          ),
          const Divider(),

          // AI Backend Section
          _buildSectionHeader('AI Backend'),
          ListTile(
            leading: const Icon(Icons.cloud),
            title: const Text('AI Service'),
            subtitle: Text(ApiConfig.useMockAi ? 'Mock (Demo Mode)' : 'Ollama'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ApiConfig.useMockAi
                    ? Colors.orange.withOpacity(0.1)
                    : AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                ApiConfig.useMockAi ? 'DEMO' : 'LIVE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: ApiConfig.useMockAi ? Colors.orange : AppTheme.primaryGreen,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('Ollama Server'),
            subtitle: Text(ApiConfig.ollamaBaseUrl),
            enabled: !ApiConfig.useMockAi,
          ),
          ListTile(
            leading: const Icon(Icons.memory),
            title: const Text('AI Model'),
            subtitle: Text(ApiConfig.ollamaModel),
            enabled: !ApiConfig.useMockAi,
          ),
          const Divider(),

          // Data Section
          _buildSectionHeader('Data'),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Clear Search History'),
            subtitle: const Text('Remove all recent searches'),
            onTap: _clearSearchHistory,
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text(
              'Clear All Data',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text('Remove all purchases and history'),
            onTap: _clearAllData,
          ),
          const Divider(),

          // Stats Section
          _buildSectionHeader('Statistics'),
          _buildStatTile(Icons.shopping_bag, 'Total Purchases', user.totalPurchases.toString()),
          _buildStatTile(Icons.qr_code_scanner, 'Total Scans', user.totalScans.toString()),
          _buildStatTile(Icons.emoji_events, 'Achievements', user.achievements.length.toString()),
          _buildStatTile(Icons.eco, 'Footprint Level', user.footprintLevel),
          const Divider(),

          // About Section
          _buildSectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Licenses'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showLicensePage(context: context),
          ),
          const SizedBox(height: 32),

          // Footer
          Center(
            child: Column(
              children: [
                Icon(Icons.eco, color: Colors.grey.shade400, size: 32),
                const SizedBox(height: 8),
                Text(
                  'GreenNova',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Making sustainability simple',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildStatTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryGreen),
      title: Text(label),
      trailing: Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryGreen,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _editProfile() {
    final controller = TextEditingController(text: HiveBoxes.currentUser.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Your Name',
            hintText: 'Enter your name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final user = HiveBoxes.currentUser.copyWith(name: name);
                await HiveBoxes.updateUser(user);
                setState(() {});
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _clearSearchHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Search History'),
        content: const Text('This will remove all your recent searches. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await HiveBoxes.clearSearchHistory();
              Navigator.pop(context);
              ScaffoldMessenger.of(this.context).showSnackBar(
                const SnackBar(content: Text('Search history cleared')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _clearAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your purchases, scan history, and reset your profile. This action cannot be undone!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await HiveBoxes.purchaseHistoryBox.clear();
              await HiveBoxes.searchHistoryBox.clear();
              await HiveBoxes.sustainabilityReportsBox.clear();
              await HiveBoxes.updateUser(UserProfile.initial());
              setState(() {});
              Navigator.pop(context);
              ScaffoldMessenger.of(this.context).showSnackBar(
                const SnackBar(content: Text('All data cleared')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear Everything'),
          ),
        ],
      ),
    );
  }
}
