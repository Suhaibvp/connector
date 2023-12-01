import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mymessager2/pages/facebook.dart';
import 'package:url_launcher/url_launcher.dart';

import 'instagram.dart';
import 'telegram.dart';
import 'whatsapp.dart';

class ChatFormPage extends StatefulWidget {
  final String selectedUser;
  final String? currentUsername;
  final String? currentUserEmail;

  const ChatFormPage(
      {super.key,
      required this.selectedUser,
      this.currentUsername,
      this.currentUserEmail});

  @override
  _ChatFormPageState createState() => _ChatFormPageState();
}

class _ChatFormPageState extends State<ChatFormPage> {
  String message = '';
  String email = FirebaseAuth.instance.currentUser?.email ?? '';
  final TextEditingController _textEditingController = TextEditingController();
  String? receiverEmail;
  @override
  void initState() {
    super.initState();
    fetchReceiverEmail();
  }

  @override
  void dispose() {
    _longPressGestureRecognizer.dispose();
    super.dispose();
  }

  LongPressGestureRecognizer _longPressGestureRecognizer =
      LongPressGestureRecognizer();

  Future<void> fetchReceiverEmail() async {
    receiverEmail = await getEmailFromUsername(widget.selectedUser);
    setState(() {}); // Trigger a rebuild to show the email if needed
  }

  void _handleWhatsAppIconPress() async {
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('whatsapp');

    QuerySnapshot snapshot = await usersCollection
        .where('senter', isEqualTo: email)
        .where('receiver', isEqualTo: widget.selectedUser)
        .get();

    if (snapshot.docs.isNotEmpty) {
      String mobileNumber = snapshot.docs.first
          .get('number'); // Make sure to use the correct field name
      String whatsappLink = 'https://wa.me/$mobileNumber';

      await launch(whatsappLink);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WhatsAppPage(
            email: email,
            selectedUser: widget.selectedUser,
          ),
        ),
      );
    }
  }

  void _handleWhatsAppIconlongPress() async {
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('whatsapp');

    QuerySnapshot snapshot = await usersCollection
        .where('senter', isEqualTo: email)
        .where('receiver', isEqualTo: widget.selectedUser)
        .get();
    String mobileNumber = snapshot.docs.first.get('number');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WhatsAppPage(
          email: email,
          selectedUser: widget.selectedUser,
        ),
      ),
    );
  }

  void _handleinstaIconPress() async {
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('instagram');

    QuerySnapshot snapshot = await usersCollection
        .where('senter', isEqualTo: email)
        .where('receiver', isEqualTo: widget.selectedUser)
        .get();

    if (snapshot.docs.isNotEmpty) {
      String Instalink = snapshot.docs.first.get('link');

      await launch(Instalink);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InstaPage(
            email: email,
            selectedUser: widget.selectedUser,
          ),
        ),
      );
    }
  }

  void _handleinstaIconlongPress() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InstaPage(
          email: email,
          selectedUser: widget.selectedUser,
        ),
      ),
    );
  }

  void _handlefacebookIconPress() async {
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('facebook');

    QuerySnapshot snapshot = await usersCollection
        .where('senter', isEqualTo: email)
        .where('receiver', isEqualTo: widget.selectedUser)
        .get();

    if (snapshot.docs.isNotEmpty) {
      String Insta = snapshot.docs.first.get('link');
      String Instalink = 'https://www.messenger.com/t/$Insta';

      await launch(Instalink);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FacebookPage(
            email: email,
            selectedUser: widget.selectedUser,
          ),
        ),
      );
    }
  }

  void _handlefacebookIconlongPress() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FacebookPage(
          email: email,
          selectedUser: widget.selectedUser,
        ),
      ),
    );
  }

  void _handletelegramIconPress() async {
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('telegram');

    QuerySnapshot snapshot = await usersCollection
        .where('senter', isEqualTo: email)
        .where('receiver', isEqualTo: widget.selectedUser)
        .get();

    if (snapshot.docs.isNotEmpty) {
      String telegram = snapshot.docs.first.get('link');
      String telegramlink = 'https://t.me/$telegram';

      await launch(telegramlink);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TelegramPage(
            email: email,
            selectedUser: widget.selectedUser,
          ),
        ),
      );
    }
  }

  void _handletelegramIconlongPress() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelegramPage(
          email: email,
          selectedUser: widget.selectedUser,
        ),
      ),
    );
  }
  // void _handleEmojiSelected(Category? category, Emoji? emoji) {
  //   if (emoji != null) {
  //     final newText = _textEditingController.text + emoji.emoji;
  //     _textEditingController.text = newText; // Set the new text
  //     _textEditingController.selection = TextSelection.fromPosition(
  //         TextPosition(offset: newText.length)); // Move cursor to the end
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    CollectionReference chatCollection =
        FirebaseFirestore.instance.collection('chat');
    CollectionReference notification =
        FirebaseFirestore.instance.collection('notification');

    Future<void> sendMessage() async {
      String currentUserEmail = FirebaseAuth.instance.currentUser!.email!;
      DateTime currentTime = DateTime.now();

      if (message.trim().isNotEmpty) {
        await chatCollection.add({
          'user': currentUserEmail,
          'receiver': widget.selectedUser,
          'message': message,
          'time': currentTime,
        });

        await notification.add({
          'senter': widget.currentUsername,
          'receiver': receiverEmail,
          'message': message,
        });
        message = '';
        _textEditingController
            .clear(); // Clear the message field after sending the message
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedUser),
        actions: [
          SizedBox(width: 10),
          GestureDetector(
            onTap: _handletelegramIconPress,
            onLongPress: () {
              _handletelegramIconlongPress();
              print("long pressed");
            },
            child: Icon(FontAwesomeIcons.telegram),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: _handlefacebookIconPress,
            onLongPress: () {
              _handlefacebookIconlongPress();
              print("long pressed");
            },
            child: Icon(FontAwesomeIcons.facebook),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: _handleWhatsAppIconPress,
            onLongPress: () {
              _handleWhatsAppIconlongPress();
            },
            child: Icon(FontAwesomeIcons.whatsapp),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: _handleinstaIconPress,
            onLongPress: () {
              _handleinstaIconlongPress();
              print("long pressed");
            },
            child: Icon(FontAwesomeIcons.instagram),
          ),
          SizedBox(width: 10),
          // ... other icons ...
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<String?>(
              future: getEmailFromUsername(widget.selectedUser),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  String? selectedUserEmail = snapshot.data;

                  return StreamBuilder<QuerySnapshot>(
                    stream: chatCollection
                        .where('user', isEqualTo: widget.currentUserEmail)
                        .where('receiver', isEqualTo: widget.selectedUser)
                        .snapshots(),
                    builder: (context, sentSnapshot) {
                      if (sentSnapshot.hasError) {
                        return Text('Error: ${sentSnapshot.error}');
                      }

                      if (sentSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const SizedBox(
                          width: 30, // Set your desired width
                          height: 30, // Set your desired height
                          child: CircularProgressIndicator(),
                        );
                      }

                      List<QueryDocumentSnapshot> sentMessages =
                          sentSnapshot.data!.docs.toList();

                      return StreamBuilder<QuerySnapshot>(
                        stream: chatCollection
                            .where('user', isEqualTo: selectedUserEmail)
                            .where('receiver',
                                isEqualTo: widget.currentUsername)
                            .snapshots(),
                        builder: (context, receivedSnapshot) {
                          if (receivedSnapshot.hasError) {
                            return Text('Error: ${receivedSnapshot.error}');
                          }

                          if (receivedSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              width: 30, // Set your desired width
                              height: 30, // Set your desired height
                              child: CircularProgressIndicator(),
                            );
                          }

                          List<QueryDocumentSnapshot> receivedMessages =
                              receivedSnapshot.data!.docs.toList();

                          // Merge the sent and received messages into a single list
                          List<QueryDocumentSnapshot> allMessages = [
                            ...sentMessages,
                            ...receivedMessages
                          ];

                          // Sort the messages by time in ascending order
                          allMessages
                              .sort((a, b) => a['time'].compareTo(b['time']));

                          return ListView.builder(
                            // reverse: true,
                            itemCount: allMessages.length,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> data = allMessages[index]
                                  .data() as Map<String, dynamic>;
                              String user = data['user'];
                              String message = data['message'];
                              // DateTime time = data['time'].toDate();

                              // Determine if the message is sent or received
                              bool isSent = user == widget.currentUserEmail;

                              // Determine the alignment for the chat bubble based on whether the message is sent or received
                              Alignment alignment = isSent
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft;

                              return Align(
                                alignment: alignment,
                                child: Padding(
                                  padding: isSent
                                      ? const EdgeInsets.only(
                                          right: 16,
                                          bottom: 4,
                                          left:
                                              80) // Adjust the values as needed
                                      : const EdgeInsets.only(
                                          left: 16,
                                          bottom: 4,
                                          right:
                                              80), // Adjust the values as needed
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color:
                                          isSent ? Colors.blue : Colors.green,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      message,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300], // Background color of the container
                borderRadius: BorderRadius.circular(20.0), // Rounded edges
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      final emoji = await showModalBottomSheet<Emoji>(
                        context: context,
                        builder: (context) {
                          return EmojiPicker(
                            onEmojiSelected: (category, emoji) {
                              Navigator.pop(
                                  context, emoji); // Return selected emoji
                            },
                            textEditingController: _textEditingController,
                            config: const Config(
                              columns: 7,
                              emojiSizeMax: 32.0,
                              verticalSpacing: 0,
                            ),
                          );
                        },
                      );

                      if (emoji != null) {
                        final newText =
                            _textEditingController.text + emoji.emoji;
                        _textEditingController.text = newText;
                        _textEditingController.selection =
                            TextSelection.fromPosition(
                                TextPosition(offset: newText.length));
                      }
                    },
                    icon: const Icon(
                      Icons.emoji_emotions,
                      color: Color.fromARGB(
                          255, 129, 128, 125), // Change icon color to yellow
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: TextFormField(
                      controller: _textEditingController,
                      onChanged: (value) {
                        message = value;
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none, // No border
                        hintText: 'Message',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      sendMessage();
                    },
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<String?> getEmailFromUsername(String username) async {
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  QuerySnapshot snapshot =
      await usersCollection.where('username', isEqualTo: username).get();

  if (snapshot.docs.isNotEmpty) {
    return snapshot.docs.first.get('email');
  } else {
    return null;
  }
}
