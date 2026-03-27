import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../theme/app_theme.dart';

/// Bottom navigation shell with sleek grey design
class ShellScaffold extends StatelessWidget {
  final Widget child;

  const ShellScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _BottomNavBar(),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    int currentIndex = 0;
    if (location.startsWith(AppRoutes.search)) {
      currentIndex = 1;
    } else if (location.startsWith(AppRoutes.compare)) {
      currentIndex = 2;
    } else if (location.startsWith(AppRoutes.dashboard)) {
      currentIndex = 3;
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                isSelected: currentIndex == 0,
                onTap: () => context.go(AppRoutes.home),
                isDark: isDark,
              ),
              _NavItem(
                icon: Icons.search_outlined,
                activeIcon: Icons.search_rounded,
                label: 'Search',
                isSelected: currentIndex == 1,
                onTap: () => context.go(AppRoutes.search),
                isDark: isDark,
              ),
              _NavItem(
                icon: Icons.compare_arrows_outlined,
                activeIcon: Icons.compare_arrows_rounded,
                label: 'Compare',
                isSelected: currentIndex == 2,
                onTap: () => context.go(AppRoutes.compare),
                isDark: isDark,
              ),
              _NavItem(
                icon: Icons.insights_outlined,
                activeIcon: Icons.insights_rounded,
                label: 'Impact',
                isSelected: currentIndex == 3,
                onTap: () => context.go(AppRoutes.dashboard),
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentEmerald.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected
                  ? AppTheme.accentEmerald
                  : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppTheme.accentEmerald
                    : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
