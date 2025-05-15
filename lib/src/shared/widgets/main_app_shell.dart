import 'package:autoservice/src/features/auth/providers/auth_provider.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:flutter/material.dart';
import 'package:autoservice/src/features/home/ui/screens/home_screen.dart';
import 'package:autoservice/src/features/requests/ui/screens/user_requests_screen.dart';
import 'package:autoservice/src/features/partner/ui/screens/partner_list_screen.dart';
import 'package:autoservice/src/shared/providers/navigation_providers.dart'; // Импортируем провайдер



class MainAppShell extends ConsumerStatefulWidget {
  const MainAppShell({super.key});

  @override
  ConsumerState<MainAppShell> createState() => _MainAppShellState();
}


class _MainAppShellState extends ConsumerState<MainAppShell> {
  // Список виджетов выносим за пределы метода build
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    PartnerListScreen(),
    UserRequestsScreen(),
    Center(child: Text('Профиль (Скоро)')),
  ];

  @override
  Widget build(BuildContext context) {
    // Используем провайдер вместо локального состояния
    final selectedIndex = ref.watch(selectedTabProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitleForIndex(selectedIndex)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Выход',
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.car_repair),
            label: 'Автосервисы',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Заявки',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          // Обновляем состояние провайдера
          ref.read(selectedTabProvider.notifier).state = index;
        },
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Главная';
      case 1:
        return 'Автосервисы';
      case 2:
        return 'Заявки';
      case 3:
        return 'Профиль';
      default:
        return 'Autoservice';
    }
  }
}