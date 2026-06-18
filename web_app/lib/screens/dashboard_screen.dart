import 'package:flutter/material.dart';
import 'package:nustar_asset_scanner_app/providers/auth_provider.dart';
import 'package:nustar_asset_scanner_app/providers/theme_provider.dart';
import 'package:nustar_asset_scanner_app/widgets/theme_toggle.dart';
import 'package:provider/provider.dart';
import 'collection_viewer_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset Movement Log'),
        actions: [
          const ThemeToggle(),
          _buildUserMenu(context),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 640;
          return SingleChildScrollView(
            padding: EdgeInsets.all(isCompact ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, isCompact),
                const SizedBox(height: 16),
                const CollectionViewer(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isCompact) {
    final isDark = context.watch<ThemeProvider>().isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(isCompact ? 16 : 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF390b16), const Color(0xFF5a1a24)]
                  : [const Color(0xFFe7bd9c), const Color(0xFFd4a87a)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: isCompact ? _buildCompactHeader(context) : _buildDesktopHeader(context),
        ),
      ],
    );
  }

  Widget _buildCompactHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.devices,
          size: 36,
          color: Colors.white,
        ),
        const SizedBox(height: 12),
        Text(
          'NUSTAR Assets logs',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Real-time data monitoring',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
        ),
      ],
    );
  }

  Widget _buildDesktopHeader(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.devices,
          size: 48,
          color: Colors.white,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NUSTAR Assets logs',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Real-time data monitoring',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _buildUserMenu(BuildContext context) {
  final authProvider = context.watch<AuthProvider>();
  final user = authProvider.user;

  return PopupMenuButton<String>(
    icon: CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
      foregroundColor: Theme.of(context).colorScheme.primary,
      child: Text(
        user?.email?.substring(0, 1).toUpperCase() ?? '?',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    offset: const Offset(0, 56),
    onSelected: (value) async {
      if (value == 'logout') {
        await context.read<AuthProvider>().signOut();
      }
    },
    itemBuilder: (context) => [
      PopupMenuItem(
        enabled: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Signed in as',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              user?.email ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      const PopupMenuDivider(),
      const PopupMenuItem(
        value: 'logout',
        child: ListTile(
          leading: Icon(Icons.logout),
          title: Text('Sign Out'),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    ],
  );
}