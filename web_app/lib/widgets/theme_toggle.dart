import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThemeProvider>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.light_mode_rounded,
                color: provider.themeMode == ThemeMode.light
                    ? Theme.of(context).colorScheme.primary
                    : null),
            onPressed: () => provider.toggleTheme(false),
            tooltip: 'Light mode',
          ),
          IconButton(
            icon: Icon(Icons.dark_mode_rounded,
                color: provider.themeMode == ThemeMode.dark
                    ? Theme.of(context).colorScheme.primary
                    : null),
            onPressed: () => provider.toggleTheme(true),
            tooltip: 'Dark mode',
          ),
        ],
      ),
    );
  }
}
