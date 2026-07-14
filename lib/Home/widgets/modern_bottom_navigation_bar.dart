import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';

/// Modern Bottom Navigation Bar with pill-style active indicator,
/// per-item bounce animation, and haptic feedback.
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
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _scales;

  static const int _tabCount = 5;

  static Color get _inactiveColor =>
      AppColors.text.withValues(alpha: 0.45);

  static const List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.search_outlined,
      activeIcon: Icons.search_rounded,
      label: _label_search,
    ),
    _NavItem(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      label: _label_orders,
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
    _scales = _controllers
        .map(
          (c) => Tween<double>(begin: 1.0, end: 0.88).animate(
            CurvedAnimation(parent: c, curve: Curves.easeInOut),
          ),
        )
        .toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  double _navBarHeight(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    if (textScale > 1.15) return 72;
    return 64;
  }

  void _onItemTapped(int index) {
    HapticFeedback.selectionClick();
    widget.onTap(index);

    if (MediaQuery.disableAnimationsOf(context)) return;

    _controllers[index].forward().then((_) {
      if (mounted) _controllers[index].reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.black.withValues(alpha: 0.07),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: _navBarHeight(context),
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
    final label = item.label(l10n);
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    final iconWidget = Icon(
      isSelected ? item.activeIcon : item.icon,
      size: 22,
      color: isSelected ? AppColors.primary : _inactiveColor,
    );

    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: disableAnimations
                ? Duration.zero
                : const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: 40,
            height: 28,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.10)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(child: iconWidget),
          ),
          const SizedBox(height: 1),
          AnimatedDefaultTextStyle(
            duration: disableAnimations
                ? Duration.zero
                : const Duration(milliseconds: 200),
            style: AppTypography.caption.copyWith(
              fontSize: 11,
              height: 1.2,
              color: isSelected ? AppColors.primary : _inactiveColor,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
          ),
          const SizedBox(height: 1),
          AnimatedContainer(
            duration: disableAnimations
                ? Duration.zero
                : const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            height: 2,
            width: isSelected ? 24 : 0,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
            ),
          ),
        ],
      ),
    );

    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _onItemTapped(index),
          child: disableAnimations
              ? content
              : AnimatedBuilder(
                  animation: _scales[index],
                  builder: (context, child) => Transform.scale(
                    scale: _scales[index].value,
                    child: child,
                  ),
                  child: content,
                ),
        ),
      ),
    );
  }
}

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
