import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_tracker_app/features/chat/controller/chat_cubit.dart';
import 'package:location_tracker_app/features/chat/controller/chat_state.dart';

class AllGroups extends StatefulWidget {
  const AllGroups({super.key});

  @override
  State<AllGroups> createState() => _AllGroupsState();
}

class _AllGroupsState extends State<AllGroups> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatCubit>().getAllChatGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        if (state.isgettingallchatgroups) {
          return Center(child: CircularProgressIndicator());
        } else if (state.allChatGroupsList.isEmpty) {
          return Center(child: Text('No chat groups available'));
        }

        return ListView.builder(
          itemCount: state.allChatGroupsList.length,
          itemBuilder: (context, index) {
            final group = state.allChatGroupsList[index];
            return Card(
              child: ListTile(
                title: Text(group.groupName),
                trailing: TextButton(
                  onPressed: () async {
                    await context.read<ChatCubit>().joinChatGroup(
                      group.groupId,
                    );
                    Navigator.pop(context);
                  },
                  child: Text('Join'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
