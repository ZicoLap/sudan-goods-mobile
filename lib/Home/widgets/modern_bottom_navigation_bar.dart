import 'package:flutter/material.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';

/// Modern Bottom Navigation Bar with enhanced UX
class ModernBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const ModernBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });
  @override
  _ModernBottomNavigationBarState createState() =>
      _ModernBottomNavigationBarState();
}

class _ModernBottomNavigationBarState extends State<ModernBottomNavigationBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: (l10n) => l10n.navHome,
    ),
    _NavItem(
      icon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag,
      label: (l10n) => l10n.navOrders,
    ),
    _NavItem(
      icon: Icons.search_outlined,
      activeIcon: Icons.search,
      label: (l10n) => l10n.navSearch,
    ),
    _NavItem(
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
      label: (l10n) => l10n.navMessages,
    ),
    _NavItem(
      icon: Icons.account_circle_outlined,
      activeIcon: Icons.account_circle,
      label: (l10n) => l10n.navProfile,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    widget.onTap(index);
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          constraints: const BoxConstraints(minHeight: 88),
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.space16,
            vertical: DesignTokens.space12,
          ),
          child: Row(
            children: [
              _buildNavItem(0),
              _buildNavItem(1),
              _buildNavItem(2),
              _buildNavItem(3),
              _buildNavItem(4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navItems[index];
    final isSelected = widget.currentIndex == index;
    final l10n = AppLocalizations.of(context)!;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          onTap: () => _onItemTapped(index),
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: isSelected ? _scaleAnimation.value : 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: DesignTokens.space8,
                    horizontal: DesignTokens.space4,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon with active state
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(DesignTokens.space4),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppColors.primary.withOpacity(0.1)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusSmall,
                          ),
                        ),
                        child: Icon(
                          isSelected ? item.activeIcon : item.icon,
                          size: 20,
                          color:
                              isSelected
                                  ? AppColors.primary
                                  : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Label with animation
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: AppTypography.caption.copyWith(
                          height: 1.2,
                          color:
                              isSelected
                                  ? AppColors.primary
                                  : Colors.grey.shade600,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        child: Text(
                          item.label(l10n),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Navigation item model
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String Function(AppLocalizations) label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
