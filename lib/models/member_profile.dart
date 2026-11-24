class MemberProfile {
  const MemberProfile({
    required this.id,
    required this.fullName,
    required this.role,
    required this.isActive,
    required this.firstLogin,
    required this.createdAt,
    this.username,
    this.phone,
    this.email,
  });

  final String id;
  final String? username;
  final String fullName;
  final String? phone;
  final String? email;
  final String role;
  final bool isActive;
  final bool firstLogin;
  final DateTime? createdAt;

  factory MemberProfile.fromMap(Map<String, dynamic> map) {
    final createdAtValue = map['created_at'];

    return MemberProfile(
      id: map['id']?.toString() ?? '',
      username: map['username']?.toString(),
      fullName: map['full_name']?.toString() ?? 'Unnamed Member',
      phone: map['phone']?.toString(),
      email: map['email']?.toString(),
      role: map['role']?.toString() ?? 'member',
      isActive: map['is_active'] == true,
      firstLogin: map['first_login'] == true,
      createdAt: createdAtValue == null
          ? null
          : DateTime.tryParse(createdAtValue.toString()),
    );
  }

  String get roleLabel {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'treasurer':
        return 'Treasurer';
      default:
        return 'Member';
    }
  }

  String get accountStatus {
    if (!isActive) {
      return 'Inactive';
    }

    if (firstLogin) {
      return 'Pending Activation';
    }

    return 'Active';
  }
}