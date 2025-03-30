class ChatGroupModel {
  final String groupId;
  final String groupName;
  final Map<String, bool> members;

  ChatGroupModel({
    required this.groupId,
    required this.groupName,
    required this.members,
  });

  factory ChatGroupModel.fromJson(Map<String, dynamic> json) {
    return ChatGroupModel(
      groupId: json['id'] ?? '',
      groupName: json['name'] ?? '',
      members: Map<String, bool>.from(json['members'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': groupId, 'name': groupName, 'members': members};
  }
}
