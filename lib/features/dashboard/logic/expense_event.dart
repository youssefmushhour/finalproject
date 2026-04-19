import '../data/models/expense_model.dart';

abstract class ExpenseEvent {}

class LoadExpenses extends ExpenseEvent {}

class UpdateExpenses extends ExpenseEvent {
  final List<ExpenseModel> expenses;
  UpdateExpenses(this.expenses);
}

class AddExpense extends ExpenseEvent {
  final ExpenseModel expense;
  AddExpense(this.expense);
}

class DeleteExpense extends ExpenseEvent {
  final String id;
  DeleteExpense(this.id);
}