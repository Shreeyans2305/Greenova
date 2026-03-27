import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/api_config.dart';
import '../../../data/datasources/local/hive_boxes.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = HiveBoxes.currentUser;
    final themeMode = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.primaryCharcoal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            _buildCard(isDark, child: Row(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.accentEmerald.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.eco_rounded, color: AppTheme.accentEmerald, size: 28),
                ),
                const SizedBox(width: 16),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(user.name ?? 'GreenNova User', style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppTheme.primaryCharcoal)),
                  Text('Impact: ${user.footprintLevel}', style: TextStyle(
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade500)),
                ]),
              ],
            )),
            const SizedBox(height: 20),

            _sectionTitle('Appearance', isDark),
            const SizedBox(height: 10),
            _buildCard(isDark, child: Column(children: [
              _settingsItem(
                icon: Icons.brightness_6_rounded,
                title: 'Theme',
                subtitle: themeMode == ThemeMode.dark ? 'Dark' :
                    themeMode == ThemeMode.light ? 'Light' : 'System',
                isDark: isDark,
                trailing: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode_rounded, size: 16)),
                    ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.auto_mode_rounded, size: 16)),
                    ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode_rounded, size: 16)),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (v) {
                    ref.read(themeProvider.notifier).setThemeMode(v.first);
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppTheme.accentEmerald.withValues(alpha: 0.15);
                      }
                      return Colors.transparent;
                    }),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ])),
            const SizedBox(height: 20),

            _sectionTitle('Backend Connection', isDark),
            const SizedBox(height: 10),
            _buildCard(isDark, child: Column(children: [
              _settingsItem(
                icon: Icons.cloud_rounded,
                title: 'Backend Server',
                subtitle: ApiConfig.backendBaseUrl,
                isDark: isDark,
              ),
              Divider(color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200),
              _settingsItem(
                icon: Icons.smart_toy_rounded,
                title: 'Text Model',
                subtitle: ApiConfig.ollamaTextModel,
                isDark: isDark,
              ),
              Divider(color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200),
              _settingsItem(
                icon: Icons.image_rounded,
                title: 'Vision Model',
                subtitle: ApiConfig.ollamaVisionModel,
                isDark: isDark,
              ),
            ])),
            const SizedBox(height: 20),

            _sectionTitle('Data', isDark),
            const SizedBox(height: 10),
            _buildCard(isDark, child: Column(children: [
              _settingsItem(
                icon: Icons.inventory_2_rounded,
                title: 'Total Products',
                subtitle: '${user.totalPurchases} tracked',
                isDark: isDark,
              ),
              Divider(color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200),
              _settingsItem(
                icon: Icons.document_scanner_rounded,
                title: 'Total Scans',
                subtitle: '${user.totalScans} scans',
                isDark: isDark,
              ),
              Divider(color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200),
              _settingsItem(
                icon: Icons.delete_outline_rounded,
                title: 'Clear All Data',
                subtitle: 'Remove all local data',
                isDark: isDark,
                titleColor: AppTheme.scoreBad,
                onTap: () => _confirmClearData(context),
              ),
            ])),
            const SizedBox(height: 24),

            // About
            Center(child: Column(children: [
              Icon(Icons.eco_rounded, color: AppTheme.accentEmerald, size: 28),
              const SizedBox(height: 8),
              const Text('GreenNova', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              Text('v2.0.0', style: TextStyle(
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400, fontSize: 13)),
              const SizedBox(height: 4),
              Text('Powered by Gemma AI', style: TextStyle(
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400, fontSize: 12)),
            ])),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Text(title, style: TextStyle(
      fontSize: 18, fontWeight: FontWeight.w800,
      color: isDark ? Colors.white : AppTheme.primaryCharcoal,
    ));
  }

  Widget _buildCard(bool isDark, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isDark ? AppTheme.cardDark : Colors.white,
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200,
        ),
      ),
      child: child,
    );
  }

  Widget _settingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    Widget? trailing,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (titleColor ?? AppTheme.accentEmerald).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: titleColor ?? AppTheme.accentEmerald),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w600,
                    color: titleColor ?? (isDark ? Colors.white : AppTheme.primaryCharcoal))),
                Text(subtitle, style: TextStyle(fontSize: 12,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade500)),
              ],
            )),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _confirmClearData(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text('This will remove all purchases, search history, and cached reports. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await HiveBoxes.clearAllPurchases();
              await HiveBoxes.clearSearchHistory();
              await HiveBoxes.clearReportCache();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data cleared'), backgroundColor: AppTheme.accentEmerald),
                );
              }
            },
            child: const Text('Clear', style: TextStyle(color: AppTheme.scoreBad)),
          ),
        ],
      ),
    );
  }
}
