import 'package:flutter/material.dart';

import '../../../models/member_profile.dart';
import '../../../services/member_service.dart';
import 'edit_member_screen.dart';
import 'reset_password_dialog.dart';

class MemberDetailsScreen extends StatefulWidget {
  const MemberDetailsScreen({
    required this.memberId,
    super.key,
  });

  final String memberId;

  @override
  State<MemberDetailsScreen> createState() =>
      _MemberDetailsScreenState();
}

class _MemberDetailsScreenState extends State<MemberDetailsScreen> {
  MemberProfile? _member;
  bool _loading = true;
  bool _actionLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMember();
  }

  Future<void> _loadMember() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final member = await MemberService.getMember(widget.memberId);

      if (!mounted) return;

      setState(() {
        _member = member;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
            error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _editMember() async {
    final member = _member;

    if (member == null) return;

    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EditMemberScreen(
          member: member,
        ),
      ),
    );

    if (updated == true) {
      await _loadMember();
    }
  }

  Future<void> _changeActiveStatus() async {
    final member = _member;

    if (member == null) return;

    final newStatus = !member.isActive;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            newStatus ? 'Activate Member' : 'Deactivate Member',
          ),
          content: Text(
            newStatus
                ? 'Activate ${member.fullName} and restore access?'
                : 'Deactivate ${member.fullName}? The member will no '
                    'longer be allowed to access the application.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                newStatus ? 'Activate' : 'Deactivate',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _actionLoading = true;
    });

    try {
      await MemberService.setMemberActive(
        memberId: member.id,
        isActive: newStatus,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus
                ? 'Member account activated.'
                : 'Member account deactivated.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      await _loadMember();
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
          _actionLoading = false;
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    final member = _member;

    if (member == null) return;

    final reset = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ResetPasswordDialog(
        memberId: member.id,
        memberName: member.fullName,
      ),
    );

    if (reset == true) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Temporary password created successfully.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      await _loadMember();
    }
  }

  Color _statusColor(MemberProfile member) {
    if (!member.isActive) return Colors.red;
    if (member.firstLogin) return Colors.orange;

    return Colors.green;
  }

  IconData _statusIcon(MemberProfile member) {
    if (!member.isActive) return Icons.block;
    if (member.firstLogin) return Icons.schedule;

    return Icons.check_circle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Details'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _loadMember,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null || _member == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'Member profile was not found.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _loadMember,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final member = _member!;
    final statusColor = _statusColor(member);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 750),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CircleAvatar(
                radius: 42,
                child: Text(
                  member.fullName.isEmpty
                      ? '?'
                      : member.fullName
                          .substring(0, 1)
                          .toUpperCase(),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                member.fullName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '@${member.username ?? 'not-assigned'}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Column(
                  children: [
                    _DetailTile(
                      icon: Icons.shield_outlined,
                      label: 'Role',
                      value: member.roleLabel,
                    ),
                    const Divider(height: 1),
                    _DetailTile(
                      icon: _statusIcon(member),
                      iconColor: statusColor,
                      label: 'Account Status',
                      value: member.accountStatus,
                    ),
                    const Divider(height: 1),
                    _DetailTile(
                      icon: Icons.phone_outlined,
                      label: 'Mobile Number',
                      value:
                          member.phone ?? 'Not registered',
                    ),
                    const Divider(height: 1),
                    _DetailTile(
                      icon: Icons.login_outlined,
                      label: 'First Login',
                      value: member.firstLogin
                          ? 'Required'
                          : 'Completed',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _actionLoading ? null : _editMember,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Member'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed:
                    _actionLoading ? null : _resetPassword,
                icon: const Icon(Icons.lock_reset_outlined),
                label: const Text('Reset Password'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed:
                    _actionLoading ? null : _changeActiveStatus,
                icon: Icon(
                  member.isActive
                      ? Icons.block
                      : Icons.check_circle_outline,
                ),
                label: Text(
                  member.isActive
                      ? 'Deactivate Member'
                      : 'Activate Member',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: member.isActive
                      ? Colors.red
                      : Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor,
      ),
      title: Text(label),
      subtitle: Text(value),
    );
  }
}