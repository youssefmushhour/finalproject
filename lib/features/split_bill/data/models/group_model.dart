class GroupModel {
  final String id;
  final String name;
  final String category;
  final double totalBalance;
  final List<Map<String, String>> members;

  GroupModel({
    required this.id,
    required this.name,
    required this.category,
    this.totalBalance = 0.0,
    this.members = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'totalBalance': totalBalance,
      'members': members,
    };
  }

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    // تأمين تحويل اللستة للويب
    var membersFromFire = map['members'];
    List<Map<String, String>> securedMembers = [];
    
    if (membersFromFire != null && membersFromFire is List) {
      for (var item in membersFromFire) {
        if (item is Map) {
          securedMembers.add({
            'name': item['name']?.toString() ?? 'User',
            'img': item['img']?.toString() ?? '',
          });
        }
      }
    }

    return GroupModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      category: map['category']?.toString() ?? 'General',
      totalBalance: (map['totalBalance'] ?? 0.0).toDouble(),
      members: securedMembers,
    );
  }
}