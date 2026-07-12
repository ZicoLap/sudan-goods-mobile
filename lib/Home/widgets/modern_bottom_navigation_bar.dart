import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/cart/cart_controller.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';

/// Modern Bottom Navigation Bar with pill-style active indicator,
/// per-item bounce animation, cart badge, and haptic feedback.
class ModernBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const ModernBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<ModernBottomNavigationBar> createState() =>
      _ModernBottomNavigationBarState();
}

class _ModernBottomNavigationBarState extends State<ModernBottomNavigationBar>
    with TickerProviderStateMixin {
  // One AnimationController per tab for independent bounce
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _scales;

  static const int _tabCount = 5;

  static const List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.search_outlined,
      activeIcon: Icons.search_rounded,
      label: _label_search,
    ),
    _NavItem(
      icon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag_rounded,
      label: _label_orders,
      showCartBadge: true,
    ),
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: _label_home,
    ),
    _NavItem(
      icon: Icons.info_outline_rounded,
      activeIcon: Icons.info_rounded,
      label: _label_info,
    ),
    _NavItem(
      icon: Icons.account_circle_outlined,
      activeIcon: Icons.account_circle_rounded,
      label: _label_profile,
    ),
  ];

  // Static label helpers (required for const List)
  static String _label_home(AppLocalizations l) => l.navHome;
  static String _label_orders(AppLocalizations l) => l.navOrders;
  static String _label_search(AppLocalizations l) => l.navSearch;
  static String _label_info(AppLocalizations l) => l.navInfo;
  static String _label_profile(AppLocalizations l) => l.navProfile;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _tabCount,
      (_) => AnimationController(
        duration: const Duration(milliseconds: 180),
        vsync: this,
      ),
    );
    _scales =
        _controllers.map((c) {
          return Tween<double>(
            begin: 1.0,
            end: 0.88,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut));
        }).toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onItemTapped(int index) {
    HapticFeedback.selectionClick();
    widget.onTap(index);
    _controllers[index].forward().then((_) => _controllers[index].reverse());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black.withOpacity(0.07), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_tabCount, (index) => _buildNavItem(index)),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navItems[index];
    final isSelected = widget.currentIndex == index;
    final l10n = AppLocalizations.of(context)!;

    Widget iconWidget = Icon(
      isSelected ? item.activeIcon : item.icon,
      size: 22,
      color: isSelected ? AppColors.primary : Colors.grey.shade500,
    );

    // Cart badge overlay on the Orders tab
    if (item.showCartBadge) {
      iconWidget = Selector<CartController, int>(
        selector: (_, c) => c.totalQuantity,
        builder: (context, qty, child) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              child!,
              if (qty > 0)
                Positioned(
                  top: -4,
                  right: -6,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: qty > 9 ? BoxShape.rectangle : BoxShape.circle,
                      borderRadius: qty > 9 ? BorderRadius.circular(8) : null,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      qty > 99 ? '99+' : '$qty',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        },
        child: iconWidget,
      );
    }

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onItemTapped(index),
        child: AnimatedBuilder(
          animation: _scales[index],
          builder:
              (context, child) =>
                  Transform.scale(scale: _scales[index].value, child: child),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with circular active bubble
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: 40,
                  height: 28,
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(child: iconWidget),
                ),

                const SizedBox(height: 1),

                // Label — FittedBox auto-shrinks for long RTL (Arabic) labels
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: AppTypography.caption.copyWith(
                    fontSize: 11,
                    height: 1.2,
                    color:
                        isSelected ? AppColors.primary : Colors.grey.shade500,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      item.label(l10n),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                ),

                // Pill underline indicator
                const SizedBox(height: 1),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  height: 2,
                  width: isSelected ? 24 : 0,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(
                      DesignTokens.radiusRound,
                    ),
                  ),
                ),
              ],
            ),
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
  final bool showCartBadge;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.showCartBadge = false,
  });
}
