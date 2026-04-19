import '../data/models/expense_model.dart';

abstract class ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<ExpenseModel> expenses;
  final double totalAmount;

  ExpenseLoaded(this.expenses) 
    : totalAmount = expenses.fold(0, (sum, item) => sum + item.amount);
}

class ExpenseError extends ExpenseState {
  final String message;
  ExpenseError(this.message);
}