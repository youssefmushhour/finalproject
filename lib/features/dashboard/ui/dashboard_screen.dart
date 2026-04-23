import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/expense_model.dart';
import '../data/repos/expense_repository.dart';
import '../logic/expense_bloc.dart';
import '../logic/expense_event.dart';
import '../logic/expense_state.dart';
 
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
 
  @override
  Widget build(BuildContext context) {
    // توفير الـ Bloc وتفعيل جلب البيانات فور فتح الشاشة
    return BlocProvider(
      create: (context) => ExpenseBloc(ExpenseRepository())..add(LoadExpenses()),
      child: const DashboardView(),
    );
  }
}
 
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F6),
      body: SafeArea(
        child: BlocBuilder<ExpenseBloc, ExpenseState>(
          builder: (context, state) {
            if (state is ExpenseLoading) {
              return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF085652)));
            } else if (state is ExpenseLoaded) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    _buildHeader(),
                    const SizedBox(height: 30),
 
                    // Total Balance Card
                    _buildBalanceCard(state.totalAmount),
                    const SizedBox(height: 20),
 
                    // Weekly Spending Chart Card
                    _buildSpendingChartCard(state.expenses, state.totalAmount),
                    const SizedBox(height: 30),
 
                    // Recent Transactions Header
                    _buildSectionHeader("Recent Transactions"),
                    const SizedBox(height: 15),
 
                    // Transactions List
                    _buildTransactionList(context, state.expenses),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            } else if (state is ExpenseError) {
              return Center(child: Text("Error: ${state.message}"));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
 
  // --- UI Components ---
 
  Widget _buildHeader() {
    final user = FirebaseAuth.instance.currentUser;
    final String name = user?.displayName ?? user?.email?.split('@').first ?? 'U';
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
 
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFF085652),
          child: Text(
            initial,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          "Masroufy",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF085652),
          ),
        ),
        const Spacer(),
      ],
    );
  }
 
  Widget _buildBalanceCard(double totalAmount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF085652),
        borderRadius: BorderRadius.circular(35),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "TOTAL BALANCE",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            "EGP ${totalAmount.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
 
  Widget _buildSpendingChartCard(List<ExpenseModel> expenses, double totalAmount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "WEEKLY SPENDING",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "EGP ${totalAmount.toStringAsFixed(0)}",
                style: const TextStyle(
                    color: Color(0xFF085652),
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text("↑ 12%",
                    style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 25),
          _buildDynamicBarChart(expenses),
        ],
      ),
    );
  }
 
  Widget _buildDynamicBarChart(List<ExpenseModel> expenses) {
    Map<int, double> dayTotals = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
 
    for (var expense in expenses) {
      if (expense.date.isAfter(startOfWeek.subtract(const Duration(seconds: 1)))) {
        int day = expense.date.weekday;
        dayTotals[day] = (dayTotals[day] ?? 0) + expense.amount;
      }
    }
 
    double maxAmount = dayTotals.values.fold(0, (max, e) => e > max ? e : max);
    if (maxAmount == 0) maxAmount = 1;
 
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildBarItem("MON", dayTotals[1]!, maxAmount, now.weekday == 1),
        _buildBarItem("TUE", dayTotals[2]!, maxAmount, now.weekday == 2),
        _buildBarItem("WED", dayTotals[3]!, maxAmount, now.weekday == 3),
        _buildBarItem("THU", dayTotals[4]!, maxAmount, now.weekday == 4),
        _buildBarItem("FRI", dayTotals[5]!, maxAmount, now.weekday == 5),
        _buildBarItem("SAT", dayTotals[6]!, maxAmount, now.weekday == 6),
        _buildBarItem("SUN", dayTotals[7]!, maxAmount, now.weekday == 7),
      ],
    );
  }
 
  Widget _buildBarItem(String label, double amount, double maxAmount, bool isToday) {
    double height = (amount / maxAmount) * 90;
    if (height < 5 && amount > 0) height = 5;
 
    return Column(
      children: [
        Container(
          width: 32,
          height: 90,
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 32,
            height: height,
            decoration: BoxDecoration(
              color: isToday ? const Color(0xFF085652) : const Color(0xFFA1DFD8),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
            color: isToday ? const Color(0xFF085652) : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
 
  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF085652)),
        ),
        Text(
          "View All",
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600),
        ),
      ],
    );
  }
 
  Widget _buildTransactionList(BuildContext context, List<ExpenseModel> expenses) {
    if (expenses.isEmpty) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text("No transactions yet", style: TextStyle(color: Colors.grey)),
      ));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: expenses.length > 5 ? 5 : expenses.length, // عرض آخر 5 فقط
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              _buildCategoryIcon(expense.category),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(expense.title,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text(
                        "${expense.category} • ${DateFormat('h:mm a').format(expense.date)}",
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("-EGP ${expense.amount.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 4),
                  const Text("SUCCESS",
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF085652),
                          letterSpacing: 1)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
 
  Widget _buildCategoryIcon(String category) {
    IconData iconData;
    switch (category) {
      case 'Food': iconData = Icons.restaurant; break;
      case 'Travel': iconData = Icons.directions_car; break;
      case 'Bills': iconData = Icons.receipt; break;
      case 'Retail': iconData = Icons.shopping_bag; break;
      default: iconData = Icons.shopping_cart_rounded;
    }
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFA1DFD8).withOpacity(0.4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(iconData, color: const Color(0xFF085652)),
    );
  }
}