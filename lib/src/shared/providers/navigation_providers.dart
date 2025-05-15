import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Провайдер для хранения индекса выбранной вкладки в BottomNavigationBar
final selectedTabProvider = StateProvider<int>((ref) => 0); 