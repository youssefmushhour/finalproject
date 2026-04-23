import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../dashboard/data/models/expense_model.dart';
import '../../dashboard/data/repos/expense_repository.dart';
import '../../dashboard/logic/expense_bloc.dart';
import '../../dashboard/logic/expense_event.dart';
import '../../dashboard/logic/expense_state.dart';
 
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});
 
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExpenseBloc(ExpenseRepository())..add(LoadExpenses()),
      child: const HistoryView(),
    );
  }
}
 
class HistoryView extends StatefulWidget {
  const HistoryView({super.key});
 
  @override
  State<HistoryView> createState() => _HistoryViewState();
}
 
class _HistoryViewState extends State<HistoryView> {
  String searchQuery = "";
  String selectedCategory = "All Time";
 
  final List<String> filters = [
    "All Time",
    "Food",
    "Transport",
    "Retail",
    "Entertainment",
    "Bills",
    "Health",
    "Education",
    "Others"
  ];
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Builder(builder: (context) {
            final user = FirebaseAuth.instance.currentUser;
            final String name = user?.displayName ?? user?.email?.split('@').first ?? 'U';
            final String initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
            final String? photoURL = user?.photoURL;
            return CircleAvatar(
              backgroundColor: const Color(0xFF085652),
              backgroundImage: photoURL != null ? NetworkImage(photoURL) : null,
              child: photoURL == null
                  ? Text(initial,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16))
                  : null,
            );
          }),
        ),
        title: const Text(
          "Masroufy",
          style: TextStyle(
              color: Color(0xFF085652),
              fontWeight: FontWeight.bold,
              fontSize: 22),
        ),
      ),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF085652)));
          } else if (state is ExpenseLoaded) {
            // --- ميكانيكا الفلترة والسيرش ---
            List<ExpenseModel> filteredExpenses = state.expenses.where((expense) {
              final matchesSearch =
                  expense.title.toLowerCase().contains(searchQuery.toLowerCase());
              final matchesCategory = selectedCategory == "All Time" ||
                  expense.category == selectedCategory;
              return matchesSearch && matchesCategory;
            }).toList();
 
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Total Spent Card
                  _buildTotalSpentCard(state.totalAmount),
 
                  // 2. Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: TextField(
                      onChanged: (value) => setState(() => searchQuery = value),
                      decoration: InputDecoration(
                        hintText: "Search transactions...",
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                        filled: true,
                        fillColor: const Color(0xFFEEEEEE),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
 
                  // 3. Filter Chips
                  SizedBox(
                    height: 70,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                      itemCount: filters.length,
                      itemBuilder: (context, index) {
                        bool isSelected = selectedCategory == filters[index];
                        return GestureDetector(
                          onTap: () =>
                              setState(() => selectedCategory = filters[index]),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF085652)
                                  : const Color(0xFFF2F4F4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                filters[index],
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
 
                  // 4. Grouped Transactions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: filteredExpenses.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 40),
                              child: Text("No transactions found",
                                  style: TextStyle(color: Colors.grey)),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDateHeader("TRANSACTIONS"),
                              ...filteredExpenses
                                  .map((e) => _buildTransactionItem(e))
                                  .toList(),
                              const SizedBox(height: 30),
                            ],
                          ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
 
  Widget _buildTotalSpentCard(double total) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF00504D),
        borderRadius: BorderRadius.circular(35),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "TOTAL SPENT THIS MONTH",
            style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text("EGP",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w300)),
              const SizedBox(width: 8),
              Text(
                NumberFormat("#,##0.00").format(total),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text("+12.5%",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
 
  Widget _buildDateHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1)),
          const SizedBox(width: 10),
          Expanded(child: Divider(color: Colors.grey.shade300)),
        ],
      ),
    );
  }
 
  Widget _buildTransactionItem(ExpenseModel expense) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFA1DFD8).withOpacity(0.4),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(_getCategoryIcon(expense.category),
                color: const Color(0xFF085652)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                    "${expense.category} • ${DateFormat('hh:mm a').format(expense.date)}",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("-EGP ${expense.amount.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              const Text("COMPLETED",
                  style: TextStyle(
                      color: Color(0xFF085652),
                      fontWeight: FontWeight.bold,
                      fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
 
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food': return Icons.restaurant;
      case 'Transport': return Icons.directions_car;
      case 'Retail': return Icons.shopping_bag;
      case 'Entertainment': return Icons.movie;
      case 'Bills': return Icons.receipt;
      case 'Health': return Icons.medical_services;
      case 'Education': return Icons.school;
      case 'Others': return Icons.more_horiz;
      default: return Icons.account_balance_wallet;
    }
  }
}