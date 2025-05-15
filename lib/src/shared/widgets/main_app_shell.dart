import 'package:autoservice/src/features/auth/providers/auth_provider.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:flutter/material.dart';
import 'package:autoservice/src/features/home/ui/screens/home_screen.dart';
import 'package:autoservice/src/features/requests/ui/screens/user_requests_screen.dart';



class MainAppShell extends ConsumerStatefulWidget {
  const MainAppShell({super.key});

  @override
  ConsumerState<MainAppShell> createState() => _MainAppShellState();
}


class _MainAppShellState extends ConsumerState<MainAppShell> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const Center(child: Text('Каталог (Скоро)')),
    const UserRequestsScreen(),
    const Center(child: Text('Профиль (Скоро)')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  String _getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Главная';
      case 1:
        return 'Каталог';
      case 2:
        return 'Заявки';
      case 3:
        return 'Профиль';
      default:
        return 'Autoservice'; // Заголовок по умолчанию
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitleForIndex(_selectedIndex)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Выход',
            onPressed: () async {
              // Вызываем метод logout из AuthNotifier
              await ref.read(authStateProvider.notifier).logout();
              // После выхода, AuthWrapper автоматически перенаправит на LoginScreen
            },
          ),
        ],
      ),
      body: IndexedStack( // Используем IndexedStack для сохранения состояния экранов
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Каталог',
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
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Чтобы все метки были видны
        showUnselectedLabels: true, // Показываем метки для невыбранных элементов
      ),
    );
  }
}