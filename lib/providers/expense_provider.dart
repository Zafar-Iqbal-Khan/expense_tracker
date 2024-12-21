import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense_model.dart';

class ExpenseProvider with ChangeNotifier {
  final List<Expense> _expenses = [];

  List<Expense> get expenses => List.unmodifiable(_expenses);

  // Load Expenses from Local Storage
  Future<void> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final savedExpenses = prefs.getString('expenses');
    if (savedExpenses != null) {
      final List<dynamic> decodedExpenses = json.decode(savedExpenses);
      _expenses.clear();
      _expenses.addAll(decodedExpenses.map((data) => Expense.fromMap(data)));
      notifyListeners();
    }
  }

  // Save Expenses to Local Storage
  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedExpenses =
        json.encode(_expenses.map((e) => e.toMap()).toList());
    await prefs.setString('expenses', encodedExpenses);
  }

  void addExpense(String title, double amount) {
    // Check if an expense with the same category exists
    final existingExpenseIndex =
        _expenses.indexWhere((expense) => expense.title == title);

    if (existingExpenseIndex >= 0) {
      // If it exists, add the new amount to the existing expense
      _expenses[existingExpenseIndex] = Expense(
        id: _expenses[existingExpenseIndex].id, // Keep the existing ID
        title: title,
        amount: _expenses[existingExpenseIndex].amount +
            amount, // Add to the existing amount
        date: DateTime.now(),
      );
    } else {
      // If no existing expense, create a new one
      final newExpense = Expense(
        id: DateTime.now().toString(),
        title: title,
        amount: amount,
        date: DateTime.now(),
      );
      _expenses.add(newExpense);
    }
    _saveExpenses();
    notifyListeners();
  }

  void deleteExpense(String id) {
    _expenses.removeWhere((expense) => expense.id == id);
    _saveExpenses();
    notifyListeners();
  }

  void updateExpense(String id, String title, double amount) {
    final expenseIndex = _expenses.indexWhere((expense) => expense.id == id);
    if (expenseIndex >= 0) {
      _expenses[expenseIndex] = Expense(
        id: id,
        title: title,
        amount: amount,
        date: DateTime.now(),
      );
      _saveExpenses();
      notifyListeners();
    }
  }
}
