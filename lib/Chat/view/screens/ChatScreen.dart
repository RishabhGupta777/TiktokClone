import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tiktok_clone/Chat/controller/ChatProvider.dart';
import 'package:tiktok_clone/Chat/view/screens/select_person_screen.dart';
import 'package:tiktok_clone/Chat/view/widgets/MessageStream.dart';
import 'package:tiktok_clone/Chat/view/widgets/attach_icons.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.receiver});
  final String receiver;

  static const String id = 'chat_screen';

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final textEditingController = TextEditingController();
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ChatProvider>(context, listen: false)
          .fetchUserInfo(widget.receiver);
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (chatProvider.isSelectionActive) ...[
            //// Allow edit only if 1 message selected AND it’s mine
            if (chatProvider.selectedMessageIds.length == 1 &&
                chatProvider.selectedOwnership.values.first == true)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  final msg = chatProvider.selectedMessages.values.first ?? "";
                  textEditingController.text = msg;
                },
              ),

            /// Copy all selected
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                final allTexts =
                    chatProvider.selectedMessages.values.join("\n");
                Clipboard.setData(ClipboardData(text: allTexts));
                chatProvider.clearSelection();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Messages copied!")),
                );
              },
            ),

            /// Delete  message
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text(
                    'Delete message?',
                    style: TextStyle(fontSize: 16),
                  ),
                  actions: <Widget>[
                    if (chatProvider.selectedOwnership.values
                        .every((isMine) => isMine))
                      TextButton(
                          onPressed: () {
                            chatProvider.deleteMessages(widget.receiver);
                            Navigator.pop(context);
                          },
                          child: Text('Delete for everyone')),
                    TextButton(
                        onPressed: () async {
                          await chatProvider.deleteForMe(widget.receiver);
                          Navigator.pop(context);
                        },
                        child: const Text('Delete for me')),
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ),

            ///Share message to any other
            IconButton(
              icon: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(3.1416),  // Flip horizontally (180°) the forward icon to look like WhatsApp’s arrow
                child: Icon(
                  Icons.reply,
                ),
              ),
              onPressed: ()async {
                final selectedChatIds = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) =>  SelectPersonScreen()),
                );

              },
            ),
          ]
        ],
        leading: chatProvider.isSelectionActive
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => chatProvider.clearSelection(),
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context); // Go back to previous screen
                },
              ),
        titleSpacing:
            -16, // removes extra left padding so avatar comes right after back arrow
        title: chatProvider.isSelectionActive
            ? Text("${chatProvider.selectedMessageIds.length} selected")
            : Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: chatProvider.userProfileUrl != null
                        ? CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                              chatProvider.userProfileUrl!,
                            ),
                          )
                        : const Icon(Icons.person),
                  ),
                  Text(chatProvider.userName ?? widget.receiver),
                ],
              ),
      ),
      body: Column(
        children: [
          MessageStream(receiver: widget.receiver),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textEditingController,
                    onChanged: chatProvider.updateMessageText,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.attach_file),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              actions: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 35),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          AttachIcons(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              // final List<XFile> files = await picker.pickMultiImage(); // For images only

                                              // For both images & videos use:
                                              final files = await picker
                                                  .pickMultipleMedia();

                                              if (files.isNotEmpty) {
                                                await chatProvider.sendMessage(
                                                    widget.receiver,
                                                    mediaFiles: files);
                                              }
                                            },
                                            icon: const Icon(Icons.photo,
                                                color: Colors.blue),
                                            iconName: const Text('Galery'),
                                          ),
                                          AttachIcons(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              final file =
                                                  await picker.pickImage(
                                                      source:
                                                          ImageSource.camera);
                                              if (file != null) {
                                                await chatProvider.sendMessage(
                                                    widget.receiver,
                                                    mediaFiles: [file]);
                                              }
                                            },
                                            icon: const Icon(Icons.camera_alt,
                                                color: Colors.red),
                                            iconName: const Text('Take Photo'),
                                          ),
                                          AttachIcons(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              final file =
                                                  await picker.pickVideo(
                                                      source:
                                                          ImageSource.camera);
                                              if (file != null) {
                                                await chatProvider.sendMessage(
                                                    widget.receiver,
                                                    mediaFiles: [file]);
                                              }
                                            },
                                            icon: const Icon(
                                                Icons.videocam_outlined,
                                                color: Colors.red),
                                            iconName: const Text('Take Video'),
                                          ),
                                        ],
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, 'Cancel'),
                                        child: const Text('Cancel'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      hintText: 'Message',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(10),
                    ),
                  ),
                ),
                if (chatProvider.messageText != null &&
                    chatProvider.messageText!.trim().isNotEmpty)
                  Container(
                    color: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.blue),
                      onPressed: () async {
                        await chatProvider.sendMessage(widget.receiver);
                        textEditingController.clear();
                      },
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
