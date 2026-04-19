import 'package:flutter/material.dart';
import '../../dashboard/ui/dashboard_screen.dart';
import '../../add_expenses/ui/history_screen.dart'; 
import '../../add_expenses/ui/add_expense_screen.dart';
import '../../split_bill/ui/split_bill_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const HistoryScreen();
      case 2:
        return AddExpenseScreen(
          onSaveSuccess: () => setState(() => _currentIndex = 0),
        );
      case 3:
        return SplitBillScreen(
          onSaveSuccess: () => setState(() => _currentIndex = 0),
        );
      case 4:
        return const Scaffold(body: Center(child: Text("Profile")));
      default:
        return const DashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F6),
      body: _buildBody(),
      bottomNavigationBar: Container(
        height: 90,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: const BoxDecoration(color: Color(0xFFF5F6F6)),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEBEFEF),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.grid_view_rounded, "DASHBOARD"),
              _buildNavItem(1, Icons.receipt_long_rounded, "HISTORY"),
              _buildAddButton(),
              _buildNavItem(3, Icons.people_alt_rounded, "GROUPS"),
              _buildNavItem(4, Icons.person_rounded, "PROFILE"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              color: isSelected ? const Color(0xFF085652) : Colors.grey.shade600, 
              size: 22
            ),
            Text(
              label, 
              style: TextStyle(
                fontSize: 8, 
                color: isSelected ? const Color(0xFF085652) : Colors.grey.shade600, 
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    bool isSelected = _currentIndex == 2;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFF085652), 
                shape: BoxShape.circle
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 18),
            ),
            const SizedBox(height: 2),
            Text(
              "ADD", 
              style: TextStyle(
                fontSize: 8, 
                fontWeight: FontWeight.bold, 
                color: isSelected ? const Color(0xFF085652) : Colors.grey.shade600
              )
            ),
          ],
        ),
      ),
    );
  }
}