import 'package:location_tracker_app/features/chat/model/chat_group_model.dart';
import 'package:location_tracker_app/features/chat/model/message_model.dart';

class ChatState {
  final bool isCreatingGroup;
  final bool isGettingChatGroups;
  final List<ChatGroupModel> chatGroupsList;
  final List<ChatGroupModel> allChatGroupsList;
  final bool isgettingallchatgroups;
  final bool isgettingAllMessages;
  final List<MessageModel> allMessages;
  const ChatState({
    this.isCreatingGroup = false,
    this.isGettingChatGroups = false,
    this.chatGroupsList = const [],
    this.allChatGroupsList = const [],
    this.isgettingallchatgroups = false,
    this.isgettingAllMessages = false,
    this.allMessages = const [],
  });

  ChatState copyWith({
    bool? isCreatingGroup,
    bool? isGettingChatGroups,
    List<ChatGroupModel>? chatGroupsList,
    List<ChatGroupModel>? allChatGroupsList,
    bool? isgettingallchatgroups,
    bool? isgettingAllMessages,
    List<MessageModel>? allMessages,
  }) {
    return ChatState(
      isCreatingGroup: isCreatingGroup ?? this.isCreatingGroup,
      isGettingChatGroups: isGettingChatGroups ?? this.isGettingChatGroups,
      chatGroupsList: chatGroupsList ?? this.chatGroupsList,
      allChatGroupsList: allChatGroupsList ?? this.allChatGroupsList,
      isgettingallchatgroups:
          isgettingallchatgroups ?? this.isgettingallchatgroups,
      isgettingAllMessages: isgettingAllMessages ?? this.isgettingAllMessages,

      allMessages: allMessages ?? this.allMessages,
    );
  }
}
