import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_tracker_app/features/chat/controller/chat_cubit.dart';
import 'package:location_tracker_app/features/chat/controller/chat_state.dart';

class CreateGroup extends StatefulWidget {
  const CreateGroup({super.key});

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final TextEditingController _groupNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Create a new group',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          TextField(
            onTapOutside: (event) {
              FocusScope.of(context).unfocus();
            },
            controller: _groupNameController,
            decoration: const InputDecoration(labelText: 'Group Name'),
          ),
          const SizedBox(height: 20),
          BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              return ElevatedButton(
                onPressed: () async {
                  if (_groupNameController.text.isNotEmpty) {
                    await context.read<ChatCubit>().createChatGroup(
                      _groupNameController.text,
                    );
                    Navigator.pop(context);
                    _groupNameController.clear();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill in the group name.'),
                      ),
                    );
                  }
                },
                child:
                    state.isCreatingGroup
                        ? const CircularProgressIndicator()
                        : const Text('Create'),
              );
            },
          ),
        ],
      ),
    );
  }
}
