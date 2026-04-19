import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../dashboard/data/models/expense_model.dart';
import '../../dashboard/data/repos/expense_repository.dart';
import '../../dashboard/logic/expense_bloc.dart';
import '../../dashboard/logic/expense_event.dart';

class AddExpenseScreen extends StatelessWidget {
  final VoidCallback onSaveSuccess;

  const AddExpenseScreen({super.key, required this.onSaveSuccess});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExpenseBloc(ExpenseRepository()),
      child: AddExpenseView(onSaveSuccess: onSaveSuccess),
    );
  }
}

class AddExpenseView extends StatefulWidget {
  final VoidCallback onSaveSuccess;

  const AddExpenseView({super.key, required this.onSaveSuccess});

  @override
  State<AddExpenseView> createState() => _AddExpenseViewState();
}

class _AddExpenseViewState extends State<AddExpenseView> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String selectedCategory = 'Food';

  final List<Map<String, dynamic>> categories = [
    {'name': 'Food', 'icon': Icons.restaurant},
    {'name': 'Travel', 'icon': Icons.directions_car},
    {'name': 'Retail', 'icon': Icons.shopping_bag},
    {'name': 'Leisure', 'icon': Icons.movie},
    {'name': 'Health', 'icon': Icons.medical_services},
    {'name': 'Bills', 'icon': Icons.receipt},
    {'name': 'Education', 'icon': Icons.school},
    {'name': 'Others', 'icon': Icons.more_horiz},
  ];

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF085652)),
          onPressed: () => widget.onSaveSuccess(),
        ),
        title: const Text("Masroufy", style: TextStyle(color: Color(0xFF085652), fontWeight: FontWeight.bold)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: GestureDetector(
        onTap: () {
          if (titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
            final expense = ExpenseModel(
              id: '',
              title: titleController.text,
              amount: double.parse(amountController.text),
              date: selectedDate,
              category: selectedCategory,
            );
            context.read<ExpenseBloc>().add(AddExpense(expense));
            widget.onSaveSuccess();
          }
        },
        child: Container(
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: const Color(0xFF085652),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Center(
            child: Text("Confirm Expense", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text("TRANSACTION AMOUNT", style: TextStyle(color: Colors.grey, fontSize: 12)),
            TextField(
              controller: amountController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Color(0xFF085652)),
              decoration: const InputDecoration(border: InputBorder.none, hintText: "0.00"),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: "What was this for?",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 0.8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                bool isSelected = selectedCategory == cat['name'];
                return GestureDetector(
                  onTap: () => setState(() => selectedCategory = cat['name']),
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: isSelected ? const Color(0xFFA1DFD8) : Colors.grey.shade200,
                        child: Icon(cat['icon'], color: const Color(0xFF085652)),
                      ),
                      const SizedBox(height: 5),
                      Text(cat['name'], style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}