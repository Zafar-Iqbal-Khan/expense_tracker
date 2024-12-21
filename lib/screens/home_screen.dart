import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart'; // Import fl_chart
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../models/expense_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showExpenseDialog(BuildContext context, [Expense? expense]) {
    final titleController =
        TextEditingController(text: expense != null ? expense.title : '');
    final amountController = TextEditingController(
        text: expense != null ? expense.amount.toString() : '');

    final List<String> categories = [
      'Grocery',
      'Transport',
      'Entertainment',
      'Bills',
      'Others'
    ];
    String? selectedCategory = expense?.title ?? categories[0];

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            expense != null ? 'Edit Expense' : 'Add Expense',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedCategory = value;
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = selectedCategory;
                final amount = double.tryParse(amountController.text) ?? 0;

                if (title!.isEmpty || amount <= 0) return;

                if (expense != null) {
                  Provider.of<ExpenseProvider>(context, listen: false)
                      .updateExpense(expense.id, title, amount);
                } else {
                  Provider.of<ExpenseProvider>(context, listen: false)
                      .addExpense(title, amount);
                }

                Navigator.of(ctx).pop();
              },
              child: Text(expense != null ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final expenses = expenseProvider.expenses;

    // Calculate total expenses
    final totalExpenses =
        expenses.fold(0.0, (sum, expense) => sum + expense.amount);

    // Group expenses by category for the pie chart
    Map<String, double> categoryTotals = {};
    for (var expense in expenses) {
      categoryTotals[expense.title] =
          (categoryTotals[expense.title] ?? 0) + expense.amount;
    }

    // Prepare pie chart data
    List<PieChartSectionData> pieChartSections =
        categoryTotals.entries.map((entry) {
      return PieChartSectionData(
        color: Colors.primaries[
            categoryTotals.keys.toList().indexOf(entry.key) %
                Colors.primaries.length],
        value: entry.value,
        title: '${entry.key} \n\$${entry.value.toStringAsFixed(2)}',
        radius: 40,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 10, // Adjust this size if needed
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Are you sure?'),
                  content:
                      const Text('Do you want to log out of your account?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Provider.of<AuthProvider>(context, listen: false)
                            .logout();
                        Navigator.of(ctx).pop();
                        Navigator.of(context).pushReplacementNamed('/auth');
                      },
                      child: const Text('Log Out'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: expenses.isEmpty
          ? const Center(
              child: Text(
                'No expenses added yet.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : Column(
              children: [
                // Pie chart
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: pieChartSections,
                      sectionsSpace:
                          0, // Remove space between sections if needed
                      centerSpaceRadius:
                          40, // Adjust the center space for better layout
                      // You can also handle text styling within each section
                    ),
                    swapAnimationDuration: const Duration(milliseconds: 800),
                    swapAnimationCurve: Curves.easeInOutCubic,
                  ),
                ),

                // Total expenses
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Total Expenses: \$${totalExpenses.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // List of expenses
                Expanded(
                  child: ExpenseList(
                    expenses: expenses,
                    deleteExpense: expenseProvider.deleteExpense,
                    editExpense: (expense) =>
                        _showExpenseDialog(context, expense),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showExpenseDialog(context),
        tooltip: 'Add Expense',
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ExpenseList extends StatelessWidget {
  final List<Expense> expenses;
  final Function(String) deleteExpense;
  final Function(Expense) editExpense;

  const ExpenseList({
    super.key,
    required this.expenses,
    required this.deleteExpense,
    required this.editExpense,
  });

  void _confirmDelete(BuildContext context, String expenseId) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Expense',
            style: TextStyle(color: Colors.red),
          ),
          content: const Text(
            'Are you sure you want to delete this expense? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                deleteExpense(expenseId);
                Navigator.of(ctx).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: expenses.length,
      itemBuilder: (ctx, index) {
        final expense = expenses[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.teal,
              child: Text(
                '\$',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              expense.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '\$${expense.amount.toStringAsFixed(2)}\n${expense.date.toLocal()}'
                  .split(' ')[0],
              style: const TextStyle(color: Colors.grey),
            ),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => editExpense(expense),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(context, expense.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
