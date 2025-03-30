import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_tracker_app/features/chat/controller/chat_state.dart';
import 'package:location_tracker_app/features/chat/model/chat_group_model.dart';
import 'package:location_tracker_app/features/chat/model/message_model.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatState());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser!.uid;

  Future<void> createChatGroup(String groupName) async {
    try {
      emit(state.copyWith(isCreatingGroup: true));

      final String groupId = _firestore.collection('chat_groups').doc().id;

      await _firestore.collection('chat_groups').doc(groupId).set({
        'id': groupId,
        'name': groupName,
        'members': {_auth.currentUser!.uid: true},
      });

      emit(state.copyWith(isCreatingGroup: false));
      await getChatGroups();
    } catch (e) {
      print("Error creating chat group: $e");
      emit(state.copyWith(isCreatingGroup: false));
    }
  }

  Future<void> getChatGroups() async {
    try {
      emit(state.copyWith(isGettingChatGroups: true));

      final String currentUserId = _auth.currentUser!.uid;

      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await _firestore
              .collection('chat_groups')
              .where('members.$currentUserId', isEqualTo: true)
              .get();

      final List<ChatGroupModel> chatGroupsList =
          querySnapshot.docs
              .map((e) => ChatGroupModel.fromJson(e.data()))
              .toList();

      emit(
        state.copyWith(
          isGettingChatGroups: false,
          chatGroupsList: chatGroupsList,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isGettingChatGroups: false));
    }
  }

  Future<void> getAllChatGroups() async {
    final String currentUserId = _auth.currentUser!.uid;
    try {
      emit(state.copyWith(isgettingallchatgroups: true));

      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await _firestore.collection('chat_groups').get();

      final List<ChatGroupModel> allChatGroupsList =
          querySnapshot.docs
              .where((doc) {
                final data = doc.data();
                final Map<String, dynamic>? members = data['members'];
                return members == null || members[currentUserId] != true;
              })
              .map((e) => ChatGroupModel.fromJson(e.data()))
              .toList();

      emit(
        state.copyWith(
          isgettingallchatgroups: false,
          allChatGroupsList: allChatGroupsList,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isgettingallchatgroups: false));
    }
  }

  Future<void> joinChatGroup(String groupId) async {
    try {
      emit(state.copyWith(isCreatingGroup: true));

      await _firestore.collection('chat_groups').doc(groupId).update({
        'members.${_auth.currentUser!.uid}': true,
      });

      emit(state.copyWith(isCreatingGroup: false));
      await getChatGroups();
    } catch (e) {
      emit(state.copyWith(isCreatingGroup: false));
    }
  }

  Future getMessages(String groupId) async {
    emit(state.copyWith(isgettingAllMessages: true));
    try {
      _firestore
          .collection('chat_groups')
          .doc(groupId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(includeMetadataChanges: true)
          .listen((snapshot) {
            final List<MessageModel> messages =
                snapshot.docs
                    .map((e) => MessageModel.fromJson(e.data()))
                    .toList();
            emit(
              state.copyWith(
                allMessages: messages,
                isgettingAllMessages: false,
              ),
            );
          });
    } catch (e) {
      emit(state.copyWith(isgettingAllMessages: false));
    }
  }

  Future<void> sendMessage(String groupId, MessageModel message) async {
    try {
      await _firestore
          .collection('chat_groups')
          .doc(groupId)
          .collection('messages')
          .add(message.toJson());

      print("Message sent successfully!");
    } catch (e) {
      print("Error sending message: $e");
    }
  }
}
