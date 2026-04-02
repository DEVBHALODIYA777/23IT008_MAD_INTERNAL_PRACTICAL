import 'package:flutter/material.dart';
import '../../dashboard/presentation/home_screen.dart';
import '../../vehicle/presentation/vehicles_screen.dart';
import '../../expenses/presentation/expenses_screen.dart';
import '../../service_center/presentation/service_centers_screen.dart';
import '../../reminders/presentation/reminders_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const VehiclesScreen(),
    const RemindersScreen(),
    const ExpensesScreen(),
    const ServiceCentersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.directions_car), label: 'Garage'),
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Dues'),
          NavigationDestination(icon: Icon(Icons.pie_chart), label: 'Expenses'),
          NavigationDestination(icon: Icon(Icons.map), label: 'Centers'),
        ],
      ),
    );
  }
}
