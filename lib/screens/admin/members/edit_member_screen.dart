import 'package:flutter/material.dart';

import '../../../models/member_profile.dart';
import '../../../services/member_service.dart';

class EditMemberScreen extends StatefulWidget {
  const EditMemberScreen({
    required this.member,
    super.key,
  });

  final MemberProfile member;

  @override
  State<EditMemberScreen> createState() => _EditMemberScreenState();
}

class _EditMemberScreenState extends State<EditMemberScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullNameController;
  late final TextEditingController _usernameController;

  late String _selectedRole;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    _fullNameController = TextEditingController(
      text: widget.member.fullName,
    );

    _usernameController = TextEditingController(
      text: widget.member.username ?? '',
    );

    _selectedRole = widget.member.role;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _saveMember() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await MemberService.updateMember(
        memberId: widget.member.id,
        fullName: _fullNameController.text,
        username: _usernameController.text,
        role: _selectedRole,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Member details updated successfully.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  String? _validateFullName(String? value) {
    final name = value?.trim() ?? '';

    if (name.length < 2) {
      return 'Enter the member’s full name.';
    }

    if (name.length > 120) {
      return 'Full name cannot exceed 120 characters.';
    }

    return null;
  }

  String? _validateUsername(String? value) {
    final username = value?.trim().toLowerCase() ?? '';

    if (!RegExp(r'^[a-z][a-z0-9._-]{2,29}$').hasMatch(username)) {
      return 'Use 3–30 lowercase letters, numbers, dots, underscores or hyphens.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Member'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _fullNameController,
                      textCapitalization: TextCapitalization.words,
                      validator: _validateFullName,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _usernameController,
                      textCapitalization: TextCapitalization.none,
                      autocorrect: false,
                      validator: _validateUsername,
                      onChanged: (value) {
                        final normalized = value.toLowerCase();

                        if (normalized != value) {
                          _usernameController.value = TextEditingValue(
                            text: normalized,
                            selection: TextSelection.collapsed(
                              offset: normalized.length,
                            ),
                          );
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                        helperText:
                            'Changing the username also changes the member’s login name.',
                      ),
                    ),
                    const SizedBox(height: 18),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        prefixIcon:
                            Icon(Icons.admin_panel_settings_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'member',
                          child: Text('Member'),
                        ),
                        DropdownMenuItem(
                          value: 'treasurer',
                          child: Text('Treasurer'),
                        ),
                        DropdownMenuItem(
                          value: 'admin',
                          child: Text('Admin'),
                        ),
                      ],
                      onChanged: _loading
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedRole = value;
                                });
                              }
                            },
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _loading ? null : _saveMember,
                        icon: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          _loading ? 'Saving...' : 'Save Changes',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}