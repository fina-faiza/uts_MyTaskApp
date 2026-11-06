import 'package:flutter/material.dart';
import 'screens/main_shell.dart';
import 'state/task_store.dart';

void main() => runApp(const MyTaskApp());

class MyTaskApp extends StatefulWidget {
  const MyTaskApp({super.key});

  @override
  State<MyTaskApp> createState() => _MyTaskAppState();
}

class _MyTaskAppState extends State<MyTaskApp> {
  final TaskStore _store = TaskStore();

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF3B6EF5);
    return MaterialApp(
      title: 'My Task App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        scaffoldBackgroundColor: const Color(0xFFF4F6FB),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: seed.withOpacity(0.14),
          labelTextStyle: WidgetStateProperty.all(
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
      home: FutureBuilder<void>(
        future: _store.ready,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError) {
            return const Scaffold(
              body: Center(
                child: Text('Gagal memuat data tugas.'),
              ),
            );
          }

          return MainShell(store: _store);
        },
      ),
    );
  }
}