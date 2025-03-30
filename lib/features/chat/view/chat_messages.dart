import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location_tracker_app/features/auth/controller/auth_cubit.dart';
import 'package:location_tracker_app/features/chat/controller/chat_cubit.dart';
import 'package:location_tracker_app/features/chat/controller/chat_state.dart';
import 'package:location_tracker_app/features/chat/model/message_model.dart';

class ChatMessages extends StatefulWidget {
  final String groupName;
  final String groupId;

  const ChatMessages({
    super.key,
    required this.groupName,
    required this.groupId,
  });

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatCubit>().getMessages(widget.groupId);
      context.read<AuthCubit>().getUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.groupName)),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                if (state.isgettingAllMessages) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.allMessages.isEmpty) {
                  return const Center(child: Text("No messages available"));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  reverse: true, // Show latest message at the bottom
                  itemCount: state.allMessages.length,
                  itemBuilder: (context, index) {
                    final message = state.allMessages[index];
                    final bool isMe =
                        context.read<ChatCubit>().currentUserId ==
                        message.senderId;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 10,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child:
                            message.isLocation
                                ? SizedBox(
                                  height: 200,
                                  width: 250,
                                  child: FlutterMap(
                                    options: MapOptions(
                                      initialCenter: LatLng(
                                        double.parse(message.lat),
                                        double.parse(message.lng),
                                      ),
                                      initialZoom: 15.0,
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate:
                                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                        subdomains: ['a', 'b', 'c'],
                                      ),
                                      MarkerLayer(
                                        markers: [
                                          Marker(
                                            width: 40.0,
                                            height: 40.0,
                                            point: LatLng(
                                              double.parse(message.lat),
                                              double.parse(message.lng),
                                            ),
                                            child: const Icon(
                                              Icons.location_pin,
                                              color: Colors.red,
                                              size: 40,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                                : Text(
                                  message.message,
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black,
                                  ),
                                ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: () async {
                          final chatCubit = context.read<ChatCubit>();
                          final authCubit = context.read<AuthCubit>();

                          // Get user's location from AuthState
                          final location = authCubit.state.user?.location;

                          if (location != null) {
                            final message = MessageModel(
                              senderId: chatCubit.currentUserId,
                              senderName:
                                  authCubit.state.fullName, // Get user name
                              message: "Shared a location",
                              isLocation: true,
                              lat: location.latitude.toString(),
                              lng: location.longitude.toString(),
                            );

                            await chatCubit.sendMessage(
                              widget.groupId,
                              message,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Location is sent")),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Location not available")),
                            );
                          }
                        },
                        icon: Icon(Icons.location_on),
                      ),
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: () async {
                    await context.read<ChatCubit>().sendMessage(
                      widget.groupId,
                      MessageModel(
                        senderId: context.read<ChatCubit>().currentUserId,
                        senderName:
                            context.read<AuthCubit>().state.fullName ?? '',
                        message: _messageController.text,
                        isLocation: false,
                      ),
                    );
                    _messageController.clear();
                  },
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
