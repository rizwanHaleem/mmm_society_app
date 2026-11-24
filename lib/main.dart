import 'screens/first_login_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://maexoojshjxknruwbelw.supabase.co',
    publishableKey: 'sb_publishable_8RhVs5WwcJMJfHaq36AV9w_PqVF6ZPF',
  );

  runApp(const MmmSocietyApp());
}

class MmmSocietyApp extends StatelessWidget {
  const MmmSocietyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MMM Society',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;

        if (session == null) {
          return const LoginScreen();
        }

        return const ProfileGate();
      },
    );
  }
}

class ProfileGate extends StatefulWidget {
  const ProfileGate({super.key});

  @override
  State<ProfileGate> createState() => _ProfileGateState();
}

class _ProfileGateState extends State<ProfileGate> {
  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<Map<String, dynamic>> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    final response = await Supabase.instance.client
        .from('profiles')
        .select(
          'id, username, full_name, email, phone_auth, role, first_login, is_active',
        )
        .eq('id', user.id)
        .single();

    return response;
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return _AccessMessageScreen(
            icon: Icons.error_outline,
            title: 'Unable to Load Profile',
            message:
                'Your MMM Society profile could not be loaded. Please contact the administrator.',
            onSignOut: _signOut,
          );
        }

        final profile = snapshot.data!;

final isActive = profile['is_active'] == true;
final isFirstLogin = profile['first_login'] == true;
final role = profile['role']?.toString();

if (!isActive) {
          return _AccessMessageScreen(
            icon: Icons.block,
            title: 'Account Inactive',
            message:
                'Your MMM Society account is currently inactive. Please contact the administrator.',
            onSignOut: _signOut,
          );
        }
if (isFirstLogin) {
  return const FirstLoginScreen();
}
        switch (role) {
          case 'admin':
            return const AdminDashboardScreen();

          case 'treasurer':
            return _AccessMessageScreen(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Treasurer',
              message: 'Treasurer dashboard will be added next.',
              onSignOut: _signOut,
            );

          case 'member':
            return _AccessMessageScreen(
              icon: Icons.person_outline,
              title: 'Member',
              message: 'Member dashboard will be added next.',
              onSignOut: _signOut,
            );

          default:
            return _AccessMessageScreen(
              icon: Icons.warning_amber_outlined,
              title: 'Access Not Configured',
              message:
                  'Your account does not have a valid MMM Society role.',
              onSignOut: _signOut,
            );
        }
      },
    );
  }
}

class _AccessMessageScreen extends StatelessWidget {
  const _AccessMessageScreen({
    required this.icon,
    required this.title,
    required this.message,
    required this.onSignOut,
  });

  final IconData icon;
  final String title;
  final String message;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MMM Society'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            onPressed: onSignOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 72,
                color: Colors.indigo,
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 28),
              OutlinedButton.icon(
                onPressed: onSignOut,
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}