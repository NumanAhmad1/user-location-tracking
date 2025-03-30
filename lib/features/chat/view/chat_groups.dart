import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_tracker_app/features/chat/controller/chat_cubit.dart';
import 'package:location_tracker_app/features/chat/controller/chat_state.dart';
import 'package:location_tracker_app/features/chat/view/all_groups.dart';
import 'package:location_tracker_app/features/chat/view/chat_messages.dart';
import 'package:location_tracker_app/features/chat/view/create_group.dart';

class ChatGroupsScreen extends StatefulWidget {
  const ChatGroupsScreen({super.key});

  @override
  State<ChatGroupsScreen> createState() => _ChatGroupsScreenState();
}

class _ChatGroupsScreenState extends State<ChatGroupsScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatCubit>().getChatGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Groups'),
        actions: [
          IconButton(
            icon: TextButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (builder) {
                    return const AllGroups();
                  },
                );
              },
              child: const Text("join groups"),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const AllGroups();
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            if (state.isGettingChatGroups) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.chatGroupsList.isEmpty) {
              return const Center(child: Text('No chat groups available'));
            }
            return ListView.builder(
              itemCount: state.chatGroupsList.length,
              itemBuilder: (context, index) {
                final group = state.chatGroupsList[index];
                return Card(
                  child: ListTile(
                    title: Text(group.groupName),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ChatMessages(
                              groupName: group.groupName,
                              groupId: group.groupId,
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "create group",
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return CreateGroup();
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
