import 'package:flutter/material.dart';
import '../state/task_store.dart';
import '../utils/navigation.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  final TaskStore store;
  const MainShell({super.key, required this.store});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _page = 0; // 0 = Beranda, 1 = Profil

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    return Scaffold(
      body: IndexedStack(
        index: _page,
        children: [
          HomeScreen(store: store),
          ProfileScreen(store: store),
        ],
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          return NavigationBar(
            selectedIndex: _page == 0 ? 0 : 2,
            onDestinationSelected: (i) {
              if (i == 1) {
                // Tombol tengah membuka form tambah tugas
                openTaskForm(context, store);
              } else {
                setState(() => _page = i == 0 ? 0 : 1);
              }
            },
            destinations: [
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: store.pending > 0,
                  label: Text('${store.pending}'),
                  child: const Icon(Icons.home_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: store.pending > 0,
                  label: Text('${store.pending}'),
                  child: const Icon(Icons.home),
                ),
                label: 'Beranda',
              ),
              const NavigationDestination(
                icon: Icon(Icons.add_circle_outline),
                selectedIcon: Icon(Icons.add_circle),
                label: 'Tambah',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          );
        },
      ),
    );
  }
}