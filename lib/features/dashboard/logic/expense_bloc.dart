import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repos/expense_repository.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository _repository;
  StreamSubscription? _expenseSubscription;

  ExpenseBloc(this._repository) : super(ExpenseLoading()) {
    on<LoadExpenses>((event, emit) {
      emit(ExpenseLoading());
      _expenseSubscription?.cancel();
      _expenseSubscription = _repository.getExpenses().listen(
        (expenses) {
          add(UpdateExpenses(expenses));
        },
        onError: (error) {
          emit(ExpenseError(error.toString()));
        },
      );
    });

    on<UpdateExpenses>((event, emit) {
      emit(ExpenseLoaded(event.expenses));
    });

    on<AddExpense>((event, emit) async {
      try {
        await _repository.addExpense(event.expense);
      } catch (e) {
        emit(ExpenseError(e.toString()));
      }
    });

    on<DeleteExpense>((event, emit) async {
      try {
        await _repository.deleteExpense(event.id);
      } catch (e) {
        emit(ExpenseError(e.toString()));
      }
    });
  }

  @override
  Future<void> close() {
    _expenseSubscription?.cancel();
    return super.close();
  }
}