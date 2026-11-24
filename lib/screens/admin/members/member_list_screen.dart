import 'package:flutter/material.dart';

import '../../../models/member_profile.dart';
import '../../../services/member_service.dart';
import 'add_member_screen.dart';
import 'member_details_screen.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  final _searchController = TextEditingController();

  List<MemberProfile> _members = [];
  bool _loading = true;
  String? _errorMessage;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final members = await MemberService.getMembers();

      if (!mounted) return;

      setState(() {
        _members = members;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error
            .toString()
            .replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _openAddMember() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const AddMemberScreen(),
      ),
    );

    if (created == true) {
      await _loadMembers();
    }
  }

  List<MemberProfile> get _filteredMembers {
    final search = _searchText.trim().toLowerCase();

    if (search.isEmpty) {
      return _members;
    }

    return _members.where((member) {
      return member.fullName.toLowerCase().contains(search) ||
          (member.username?.toLowerCase().contains(search) ?? false) ||
          (member.phone?.toLowerCase().contains(search) ?? false) ||
          member.roleLabel.toLowerCase().contains(search) ||
          member.accountStatus.toLowerCase().contains(search);
    }).toList();
  }

  Color _statusColor(MemberProfile member) {
    if (!member.isActive) {
      return Colors.red;
    }

    if (member.firstLogin) {
      return Colors.orange;
    }

    return Colors.green;
  }

  IconData _statusIcon(MemberProfile member) {
    if (!member.isActive) {
      return Icons.block;
    }

    if (member.firstLogin) {
      return Icons.schedule;
    }

    return Icons.check_circle;
  }

  @override
  Widget build(BuildContext context) {
    final filteredMembers = _filteredMembers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _loadMembers,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddMember,
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Add Member'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Search Members',
                hintText: 'Name, username, mobile, role or status',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchText.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchController.clear();

                          setState(() {
                            _searchText = '';
                          });
                        },
                        icon: const Icon(Icons.clear),
                      ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Row(
              children: [
                Text(
                  '${filteredMembers.length} member'
                  '${filteredMembers.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _buildContent(filteredMembers),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<MemberProfile> filteredMembers) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
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
                _errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _loadMembers,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (filteredMembers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.people_outline,
                size: 72,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                _members.isEmpty
                    ? 'No members have been added yet.'
                    : 'No members match your search.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMembers,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: filteredMembers.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final member = filteredMembers[index];
          final statusColor = _statusColor(member);

          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              onTap: () async {
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => MemberDetailsScreen(
        memberId: member.id,
      ),
    ),
  );

  await _loadMembers();
},
              leading: CircleAvatar(
                child: Text(
                  member.fullName.isEmpty
                      ? '?'
                      : member.fullName.substring(0, 1).toUpperCase(),
                ),
              ),
              title: Text(
                member.fullName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('@${member.username ?? 'not-assigned'}'),
                    const SizedBox(height: 4),
                    Text(member.phone ?? 'Mobile not registered'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Chip(
                          visualDensity: VisualDensity.compact,
                          avatar: const Icon(
                            Icons.shield_outlined,
                            size: 18,
                          ),
                          label: Text(member.roleLabel),
                        ),
                        Chip(
                          visualDensity: VisualDensity.compact,
                          avatar: Icon(
                            _statusIcon(member),
                            size: 18,
                            color: statusColor,
                          ),
                          label: Text(member.accountStatus),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}