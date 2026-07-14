import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/cart/cart_controller.dart';
import 'package:sudan_goods/home/pages/home_page_new.dart';
import 'package:sudan_goods/order/pages/orders_page.dart';
import 'package:sudan_goods/profile/pages/info_tab_page.dart';
import 'package:sudan_goods/profile/pages/profile_page.dart';
import 'package:sudan_goods/search/pages/search_page.dart';
import 'package:sudan_goods/home/widgets/modern_bottom_navigation_bar.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 2; // Home is center tab

  final _navigatorKeys = <GlobalKey<NavigatorState>>[
    GlobalKey<NavigatorState>(), // Search
    GlobalKey<NavigatorState>(), // Orders
    GlobalKey<NavigatorState>(), // Home
    GlobalKey<NavigatorState>(), // Info
    GlobalKey<NavigatorState>(), // Profile
  ];

  @override
  void initState() {
    super.initState();
    // Defer Firestore cart load until the first frame after MainShell mounts.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cart = Provider.of<CartController>(context, listen: false);
      cart.loadCartsFromFirestore();
    });
  }

  Widget _buildOffstageNavigator(int index, Widget child) {
    return Offstage(
      offstage: _currentIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (settings) => MaterialPageRoute(builder: (_) => child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final nav = _navigatorKeys[_currentIndex].currentState!;
        if (!await nav.maybePop()) {
          // Nothing left to pop — allow the system to handle (e.g. exit app)
          if (context.mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            _buildOffstageNavigator(0, const SearchPage()),
            _buildOffstageNavigator(1, const OrdersPage()),
            _buildOffstageNavigator(2, const HomePage()),
            _buildOffstageNavigator(3, const InfoTabPage()),
            _buildOffstageNavigator(4, const ProfilePage()),
          ],
        ),
        bottomNavigationBar: ModernBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == _currentIndex) {
              // Reselect: pop to first route of current tab
              _navigatorKeys[index].currentState?.popUntil(
                (route) => route.isFirst,
              );
            } else {
              setState(() => _currentIndex = index);
            }
          },
        ),
      ),
    );
  }
}
