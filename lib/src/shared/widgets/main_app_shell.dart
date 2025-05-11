import 'package:flutter/material.dart';
import 'package:autoservice/src/features/home/ui/screens/home_screen.dart';
// Импортируем другие экраны, когда они будут созданы
// import 'package:autoservice/src/features/catalog/ui/screens/catalog_screen.dart';
// import 'package:autoservice/src/features/profile/ui/screens/profile_screen.dart';

class MainAppShell extends StatefulWidget {
  const MainAppShell({super.key});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _selectedIndex = 0;

  // Список виджетов для отображения в теле Scaffold в зависимости от выбранной вкладки
  // TODO: Заменить Placeholder виджетами на реальные экраны по мере их создания
  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(), // Главная
    const Center(child: Text('Каталог (Скоро)')), // Заглушка для Каталога
    const Center(child: Text('Заявки (Скоро)')), // Заглушка для Заявок
    const Center(child: Text('Профиль (Скоро)')), // Заглушка для Профиля
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar будет добавлен позже или будет специфичен для каждого экрана
      // appBar: AppBar(
      //   title: Text(_getTitleForIndex(_selectedIndex)), // Заголовок может меняться
      // ),
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

  // Опционально: метод для получения заголовка для AppBar
  // String _getTitleForIndex(int index) {
  //   switch (index) {
  //     case 0:
  //       return 'Главная';
  //     case 1:
  //       return 'Каталог';
  //     case 2:
  //       return 'Заявки';
  //     case 3:
  //       return 'Профиль';
  //     default:
  //       return 'Autoservice';
  //   }
  // }
}