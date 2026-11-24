import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _connectionStatus = 'Checking Supabase connection...';
  bool _connectionSuccessful = false;

  @override
  void initState() {
    super.initState();
    _testSupabaseConnection();
  }

  Future<void> _testSupabaseConnection() async {
  try {
    final response = await Supabase.instance.client
        .from('app_connection_test')
        .select('message')
        .limit(1);

    if (!mounted) return;

    if (response.isEmpty) {
      setState(() {
        _connectionStatus =
            'Connected to Supabase, but no test record was found.';
        _connectionSuccessful = false;
      });
      return;
    }

    setState(() {
      _connectionStatus =
          response.first['message']?.toString() ?? 'Connection successful';
      _connectionSuccessful = true;
    });
  } catch (error) {
    if (!mounted) return;

    setState(() {
      _connectionStatus = 'Supabase error: $error';
      _connectionSuccessful = false;
    });

    debugPrint('Supabase connection error: $error');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MMM Society'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.groups_rounded,
                size: 80,
                color: Colors.indigo,
              ),
              const SizedBox(height: 24),
              const Text(
                'MMM Society',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Society Management System',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              Icon(
                _connectionSuccessful
                    ? Icons.check_circle
                    : Icons.cloud_sync,
                color: _connectionSuccessful
                    ? Colors.green
                    : Colors.orange,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                _connectionStatus,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: _connectionSuccessful
                      ? Colors.green
                      : Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}