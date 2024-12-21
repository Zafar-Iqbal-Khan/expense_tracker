import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/screens/auth_screen.dart';
import 'package:expense_tracker/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  // Ensure the Widgets are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize providers
  final expenseProvider = ExpenseProvider();
  await expenseProvider.loadExpenses();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => expenseProvider), // ExpenseProvider
        ChangeNotifierProvider(create: (_) => AuthProvider()), // AuthProvider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Check login status on app start
    Future.delayed(Duration.zero, () {
      Provider.of<AuthProvider>(context, listen: false).checkLoginStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: Consumer<AuthProvider>(
        builder: (ctx, authProvider, child) {
          // Show home screen if logged in, else show login screen
          return authProvider.isLoggedIn ? const HomeScreen() : AuthScreen();
        },
      ),
    );
  }
}
