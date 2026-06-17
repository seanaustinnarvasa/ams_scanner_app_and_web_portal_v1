import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/theme_toggle.dart';
import 'collection_viewer_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('NUSTAR Asset Scanner'),
        actions: const [ThemeToggle()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            const CollectionViewer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final checkThemeColor = isDark ? Colors.white : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          // decoration: BoxDecoration(
          //   gradient: LinearGradient(
          //     colors: isDark
          //         ? [Colors.green.shade900, Colors.green.shade700]
          //         : [Colors.green.shade700, Colors.green.shade500],
          //   ),
          //   borderRadius: BorderRadius.circular(20),
          // ),
          child: Row(
            children: [
              Icon(
                Icons.devices,
                size: 48,
                color: checkThemeColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NUSTAR Assets logs',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: checkThemeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Real-time data monitoring',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: checkThemeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
