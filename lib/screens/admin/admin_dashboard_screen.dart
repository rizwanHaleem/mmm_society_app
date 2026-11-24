import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'members/member_list_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  void _openMembers(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MemberListScreen(),
      ),
    );
  }

  void _showComingSoon(
    BuildContext context,
    String moduleName,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$moduleName will be added in the next phase.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MMM Society'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Society administration and management',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),

                _DashboardCard(
                  icon: Icons.people_outline,
                  title: 'Members',
                  subtitle: 'Add, search and manage society members',
                  onTap: () => _openMembers(context),
                ),

                const SizedBox(height: 12),

                _DashboardCard(
                  icon: Icons.payments_outlined,
                  title: 'Payments',
                  subtitle: 'Manage payments and receipts',
                  onTap: () => _showComingSoon(
                    context,
                    'Payments',
                  ),
                ),

                const SizedBox(height: 12),

                _DashboardCard(
                  icon: Icons.bar_chart_outlined,
                  title: 'Reports',
                  subtitle: 'View society reports',
                  onTap: () => _showComingSoon(
                    context,
                    'Reports',
                  ),
                ),

                const SizedBox(height: 12),

                _DashboardCard(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  subtitle: 'Configure society settings',
                  onTap: () => _showComingSoon(
                    context,
                    'Settings',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: Icon(
          icon,
          size: 32,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}