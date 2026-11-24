import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FirstLoginScreen extends StatefulWidget {
  const FirstLoginScreen({super.key});

  @override
  State<FirstLoginScreen> createState() => _FirstLoginScreenState();
}

class _FirstLoginScreenState extends State<FirstLoginScreen> {
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _message;

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _formatMobileNumber(String input) {
    var mobile = input.trim().replaceAll(' ', '').replaceAll('-', '');

    if (mobile.startsWith('+94')) {
      return mobile;
    }

    if (mobile.startsWith('94')) {
      return '+$mobile';
    }

    if (mobile.startsWith('0')) {
      return '+94${mobile.substring(1)}';
    }

    return '+94$mobile';
  }

  bool _isValidSriLankanMobile(String mobile) {
    final pattern = RegExp(r'^\+947[0-9]{8}$');
    return pattern.hasMatch(mobile);
  }

 Future<void> _activateAccount() async {
  final mobile = _formatMobileNumber(_mobileController.text);
  final password = _passwordController.text;
  final confirmPassword = _confirmPasswordController.text;

  if (!_isValidSriLankanMobile(mobile)) {
    setState(() {
      _message = 'Please enter a valid Sri Lankan mobile number.';
    });
    return;
  }

  if (password.length < 8) {
    setState(() {
      _message = 'Your new password must contain at least 8 characters.';
    });
    return;
  }

  if (password != confirmPassword) {
    setState(() {
      _message = 'The passwords do not match.';
    });
    return;
  }

  final user = Supabase.instance.client.auth.currentUser;

  if (user == null) {
    setState(() {
      _message = 'Your login session has expired. Please sign in again.';
    });
    return;
  }

  setState(() {
    _loading = true;
    _message = null;
  });

  try {
    await Supabase.instance.client.auth.updateUser(
      UserAttributes(
        password: password,
      ),
    );

    await Supabase.instance.client.rpc(
      'complete_first_login',
      params: {
        'p_mobile': mobile,
      },
    );

    if (!mounted) return;

await Supabase.instance.client.auth.refreshSession();

if (!mounted) return;

Navigator.of(context).pushNamedAndRemoveUntil(
  '/',
  (route) => false,
);
  } on AuthException catch (error) {
    if (!mounted) return;

    setState(() {
      _message = error.message;
    });
  } catch (error) {
    if (!mounted) return;

    setState(() {
      _message = 'Unable to activate your account: $error';
    });
  } finally {
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activate Account'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.verified_user_outlined,
                    size: 72,
                    color: Colors.indigo,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome to MMM Society',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Complete your account setup before continuing.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 32),

                  TextField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Mobile Number',
                      hintText: '0771234567',
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 18),

                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      if (!_loading) {
                        _activateAccount();
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      prefixIcon: const Icon(Icons.lock_reset_outlined),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword =
                                !_obscureConfirmPassword;
                          });
                        },
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed: _loading ? null : _activateAccount,
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Activate Account'),
                    ),
                  ),

                  if (_message != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      _message!,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}