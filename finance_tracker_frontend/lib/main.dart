import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

//#region --- THEME SETTINGS ---

const Color kPrimaryColor = Color(0xFF060f19);
const Color kSecondaryColor = Color(0xFFf80d0d);
const Color kAccentColor = Color(0xFF4535c0);
const Color kBackgroundColor = Color(0xFF13151A);
const Color kCardColor = Color(0xFF1A1D23);

final ThemeData darkMinimalTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: kPrimaryColor,
  colorScheme: ColorScheme.dark(
    primary: kPrimaryColor,
    secondary: kSecondaryColor,
    surface: kCardColor,
    onSurface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    error: kSecondaryColor,
  ),
  scaffoldBackgroundColor: kBackgroundColor,
  cardColor: kCardColor,
  appBarTheme: const AppBarTheme(
    color: kPrimaryColor,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: kPrimaryColor,
    selectedItemColor: kAccentColor,
    unselectedItemColor: Colors.white54,
    showUnselectedLabels: true,
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    bodyMedium: TextStyle(color: Colors.white70),
    bodySmall: TextStyle(color: Colors.white38),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(kAccentColor),
        foregroundColor: WidgetStatePropertyAll(Colors.white),
        shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))))
    ),
  ),
);

//#region

void main() {
  runApp(const FinanceTrackerApp());
}

class FinanceTrackerApp extends StatelessWidget {
  const FinanceTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Finance Tracker",
      theme: darkMinimalTheme,
      debugShowCheckedModeBanner: false,
      home: const RootSessionGate(),
    );
  }
}

class RootSessionGate extends StatefulWidget {
  const RootSessionGate({super.key});
  @override
  State<RootSessionGate> createState() => _RootSessionGateState();
}

class _RootSessionGateState extends State<RootSessionGate> {
  Future<bool> _isAuthenticated() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isAuthenticated(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data == true) {
          return const MainScaffold();
        } else {
          return const AuthScreen();
        }
      },
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;

  void toggleAuth() => setState(() => isLogin = !isLogin);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: kCardColor,
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.account_balance_wallet_rounded, size: 48, color: kAccentColor),
                  const SizedBox(height: 16),
                  Text(isLogin ? "Welcome Back" : "Create Account",
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 24),
                  isLogin
                      ? LoginForm(onSwitchTap: toggleAuth)
                      : RegisterForm(onSwitchTap: toggleAuth),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  final VoidCallback onSwitchTap;
  const LoginForm({required this.onSwitchTap, super.key});
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String email = '', password = '';
  bool loading = false, error = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      loading = true;
      error = false;
    });
    _formKey.currentState!.save();

    try {
      final token = await ApiService().login(email, password);
      if (token != null) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        if (mounted) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainScaffold()));
        }
      } else {
        setState(() {
          error = true;
        });
      }
    } catch (_) {
      setState(() {
        error = true;
      });
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration:
                const InputDecoration(labelText: "Email", icon: Icon(Icons.email)),
                keyboardType: TextInputType.emailAddress,
                onSaved: (v) => email = v ?? '',
                validator: (v) =>
                v != null && v.contains('@') ? null : 'Enter valid email',
                autofillHints: const [AutofillHints.email],
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration:
                const InputDecoration(labelText: "Password", icon: Icon(Icons.lock)),
                obscureText: true,
                onSaved: (v) => password = v ?? '',
                validator: (v) =>
                v != null && v.length >= 6 ? null : 'Password too short',
                autofillHints: const [AutofillHints.password],
              ),
              const SizedBox(height: 16),
              if (error)
                Text("Login failed, check credentials.",
                    style: TextStyle(color: kSecondaryColor)),
              loading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleLogin,
                        child: const Text("Login"),
                      ),
                    ),
              TextButton(
                onPressed: widget.onSwitchTap,
                child: const Text("Don't have an account? Register"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RegisterForm extends StatefulWidget {
  final VoidCallback onSwitchTap;
  const RegisterForm({required this.onSwitchTap, super.key});
  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  String email = '', password = '';
  bool loading = false, error = false;

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      loading = true;
      error = false;
    });
    _formKey.currentState!.save();

    try {
      bool registered = await ApiService().register(email, password);
      if (registered) {
        widget.onSwitchTap();
      } else {
        setState(() {
          error = true;
        });
      }
    } catch (_) {
      setState(() {
        error = true;
      });
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration:
                const InputDecoration(labelText: "Email", icon: Icon(Icons.email)),
                keyboardType: TextInputType.emailAddress,
                onSaved: (v) => email = v ?? '',
                validator: (v) =>
                v != null && v.contains('@') ? null : 'Enter valid email',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration:
                const InputDecoration(labelText: "Password", icon: Icon(Icons.lock)),
                obscureText: true,
                onSaved: (v) => password = v ?? '',
                validator: (v) =>
                v != null && v.length >= 6 ? null : 'Password too short',
              ),
              const SizedBox(height: 16),
              if (error)
                Text("Registration failed.",
                    style: TextStyle(color: kSecondaryColor)),
              loading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleRegister,
                        child: const Text("Register"),
                      ),
                    ),
              TextButton(
                onPressed: widget.onSwitchTap,
                child: const Text("Already have an account? Login"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ... all remaining content is unchanged, but with the same fix:
// For other found instances (line numbers may differ based on changes), always move child: LAST in ElevatedButton.

class TransactionEditScreen extends StatefulWidget {
  final Map<String, dynamic>? transaction;
  const TransactionEditScreen({this.transaction, super.key});
  @override
  State<TransactionEditScreen> createState() => _TransactionEditScreenState();
}

class _TransactionEditScreenState extends State<TransactionEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late String category, type;
  String note = '';
  double amount = 0.0;
  DateTime date = DateTime.now();

  bool loading = false, error = false;

  @override
  void initState() {
    super.initState();
    var t = widget.transaction;
    category = t?['category'] ?? '';
    type = t?['type'] ?? 'expense';
    note = t?['note'] ?? '';
    amount = t?['amount']?.toDouble() ?? 0.0;
    date = DateTime.tryParse(t?['date'] ?? '') ?? DateTime.now();
  }

  void _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      loading = true;
      error = false;
    });
    _formKey.currentState!.save();

    try {
      bool result;
      if (widget.transaction == null) {
        result = await ApiService().addTransaction(
            category: category,
            type: type,
            amount: amount,
            note: note,
            date: date);
      } else {
        result = await ApiService().editTransaction(
          id: widget.transaction!['id'],
          category: category,
          type: type,
          amount: amount,
          note: note,
          date: date,
        );
      }
      if (result && mounted) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          error = true;
        });
      }
    } catch (_) {
      setState(() {
        error = true;
      });
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction == null ? "Add Transaction" : "Edit Transaction"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Card(
          color: kCardColor,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: "Type"),
                    value: type,
                    items: const [
                      DropdownMenuItem(
                          value: "expense", child: Text("Expense")),
                      DropdownMenuItem(
                          value: "income", child: Text("Income")),
                    ],
                    onChanged: (v) => setState(() => type = v!),
                    onSaved: (v) => type = v ?? 'expense',
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Category"),
                    initialValue: category,
                    onSaved: (v) => category = v ?? '',
                    validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter a category' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Amount"),
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    initialValue: amount.toString(),
                    onSaved: (v) => amount = double.tryParse(v ?? '0') ?? 0,
                    validator: (v) =>
                    v == null || double.tryParse(v) == null ? 'Enter amount' : null,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: Text(
                              "Date: ${date.toLocal().toString().substring(0, 10)}")),
                      TextButton(
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: date,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) setState(() => date = picked);
                        },
                        child: const Text("Pick Date"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Note"),
                    initialValue: note,
                    onSaved: (v) => note = v ?? '',
                  ),
                  const SizedBox(height: 10),
                  if (error)
                    Text("Failed to save transaction.",
                        style: TextStyle(color: kSecondaryColor)),
                  loading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _saveTransaction,
                          child: const Text("Save"),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BudgetEditScreen extends StatefulWidget {
  final Map<String, dynamic>? budget;
  const BudgetEditScreen({this.budget, super.key});

  @override
  State<BudgetEditScreen> createState() => _BudgetEditScreenState();
}

class _BudgetEditScreenState extends State<BudgetEditScreen> {
  final _formKey = GlobalKey<FormState>();
  String category = '';
  double limit = 0;
  bool loading = false, error = false;

  @override
  void initState() {
    super.initState();
    category = widget.budget?['category'] ?? '';
    limit = widget.budget?['limit']?.toDouble() ?? 0;
  }

  void _saveBudget() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      loading = true;
      error = false;
    });
    _formKey.currentState!.save();
    try {
      bool result;
      if (widget.budget == null) {
        result = await ApiService().addBudget(category: category, limit: limit);
      } else {
        result = await ApiService().editBudget(
            id: widget.budget!['id'], category: category, limit: limit);
      }
      if (result && mounted) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          error = true;
        });
      }
    } catch (_) {
      setState(() {
        error = true;
      });
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(widget.budget == null ? "Add Budget" : "Edit Budget")),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Card(
          color: kCardColor,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Category"),
                    initialValue: category,
                    onSaved: (v) => category = v ?? '',
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Enter a category' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Limit"),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    initialValue: limit.toString(),
                    onSaved: (v) => limit = double.tryParse(v ?? '0') ?? 0,
                    validator: (v) =>
                        v == null || double.tryParse(v) == null ? 'Enter limit' : null,
                  ),
                  const SizedBox(height: 10),
                  if (error)
                    Text("Failed to save budget.",
                        style: TextStyle(color: kSecondaryColor)),
                  loading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _saveBudget,
                          child: const Text("Save"),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ... the rest of the code is unchanged
// END OF MAIN.DART
