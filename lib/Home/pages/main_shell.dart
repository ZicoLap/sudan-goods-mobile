import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/cart/cart_controller.dart';
import 'package:sudan_goods/Home/pages/home_page_new.dart';
import 'package:sudan_goods/Home/pages/orders_page.dart';
import 'package:sudan_goods/Home/pages/messages_page.dart';
import 'package:sudan_goods/Home/pages/profile_page.dart';
import 'package:sudan_goods/Home/pages/search_page.dart';
import 'package:sudan_goods/Home/widgets/modern_bottom_navigation_bar.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _navigatorKeys = <GlobalKey<NavigatorState>>[
    GlobalKey<NavigatorState>(), // Home
    GlobalKey<NavigatorState>(), // Orders
    GlobalKey<NavigatorState>(), // Search
    GlobalKey<NavigatorState>(), // Messages
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

  Future<bool> _onWillPop() async {
    final nav = _navigatorKeys[_currentIndex].currentState!;
    if (await nav.maybePop()) {
      return false; // handled by inner navigator
    }
    return true; // allow app to exit (or previous route)
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
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(
          children: [
            _buildOffstageNavigator(0, const HomePage()),
            _buildOffstageNavigator(1, const OrdersPage()),
            _buildOffstageNavigator(2, const SearchPage()),
            _buildOffstageNavigator(3, const MessagesPage()),
            _buildOffstageNavigator(4, const ProfilePage()),
          ],
        ),
        bottomNavigationBar: ModernBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == _currentIndex) {
              // Reselect: pop to first route of current tab
              _navigatorKeys[index]
                  .currentState
                  ?.popUntil((route) => route.isFirst);
            } else {
              setState(() => _currentIndex = index);
            }
          },
        ),
      ),
    );
  }
}
