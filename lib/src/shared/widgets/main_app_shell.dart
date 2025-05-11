import 'package:autoservice/src/features/auth/providers/auth_provider.dart'; // Добавляем импорт
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Добавляем импорт
import 'package:flutter/material.dart';
import 'package:autoservice/src/features/home/ui/screens/home_screen.dart';
// Импортируем другие экраны, когда они будут созданы
// import 'package:autoservice/src/features/catalog/ui/screens/catalog_screen.dart';
// import 'package:autoservice/src/features/profile/ui/screens/profile_screen.dart';

// Преобразуем в ConsumerStatefulWidget
class MainAppShell extends ConsumerStatefulWidget {
  const MainAppShell({super.key});

  @override
  ConsumerState<MainAppShell> createState() => _MainAppShellState();
}

// Преобразуем в ConsumerState
class _MainAppShellState extends ConsumerState<MainAppShell> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const Center(child: Text('Каталог (Скоро)')),
    const Center(child: Text('Заявки (Скоро)')),
    const Center(child: Text('Профиль (Скоро)')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Метод для получения заголовка для AppBar
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
              await ref.read(authProvider.notifier).logout();
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