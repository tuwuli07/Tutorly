import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> chatData;

  const ChatScreen({super.key, required this.chatData});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection('messages')
        .where('chatId', isEqualTo: widget.chatData['chatId'])
        .orderBy('timestamp', descending: false)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        if (kDebugMode) {
          print("Fetched Message: ${doc.data()}");
        }
      }
    }).catchError((error) {
      if (kDebugMode) {
        print("Error fetching messages: $error");
      }
    });
  }

  Stream<QuerySnapshot> getMessages() {
    return FirebaseFirestore.instance
        .collection('messages')
        .where('chatId', isEqualTo: widget.chatData['chatId'])
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  void sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    String? chatId = widget.chatData['chatId'] as String?;
    String? studentId = widget.chatData['studentId'] as String?;
    String? tutorId = widget.chatData['tutorId'] as String?;

    if (chatId == null || chatId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Chat ID is missing!")),
      );
      return;
    }
    String senderId = user?.uid ?? '';
    if (senderId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not authenticated!")),
      );
      return;
    }
    String receiverId = (senderId == studentId) ? (tutorId ?? '') : (studentId ?? '');
    if (receiverId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Receiver ID is missing!")),
      );
      return;
    }
    String messageText = _messageController.text.trim();
    DocumentReference messageRef = FirebaseFirestore.instance.collection('messages').doc();
    DocumentReference chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);
    DocumentReference notificationRef = FirebaseFirestore.instance.collection('notifications').doc();
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var chatSnapshot = await transaction.get(chatRef);

        transaction.set(messageRef, {
          'chatId': chatId,
          'senderId': user?.uid,
          'text': messageText,
          'timestamp': FieldValue.serverTimestamp(),
        });

        if (chatSnapshot.exists) {
          transaction.update(chatRef, {
            'lastMessage': messageText,
            'lastMessageSenderId': senderId,
            'timestamp': FieldValue.serverTimestamp(),
          });
        } else {
          if (kDebugMode) {
            print("Chat document does not exist!");
          }
        }

        transaction.set(notificationRef, {
          'receiverId': receiverId,
          'message': "You have a new message.",
          'chatId': chatId,
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

      if (kDebugMode) {
        print("Message sent successfully!");
      }
      _messageController.clear();
      //setState(() {});

    } catch (e) {
      if (kDebugMode) {
        print("Error sending message: $e");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send message: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String studentName = widget.chatData['studentName'] ?? "Unknown Student";
    String tutorName = widget.chatData['tutorName'] ?? "Unknown Tutor";

    String chatPartnerName = (user?.uid == widget.chatData['studentId'])
        ? tutorName
        : studentName;

    String chatId = widget.chatData['chatId'] ?? '';

    if (chatId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Chat"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: Text("Invalid Chat ID!")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(chatPartnerName),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getMessages(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No messages yet"));
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    var message = doc.data() as Map<String, dynamic>;
                    String messageSenderId = message['senderId'] ?? '';
                    String currentUserId = user?.uid ?? '';
                    bool isMe = messageSenderId == currentUserId;
                    DateTime timestamp = message['timestamp']?.toDate() ?? DateTime.now();
                    String formattedTime = "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}";
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: Row(
                        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (!isMe)
                            CircleAvatar(
                              radius: 17,
                              backgroundImage: AssetImage('lib/icons/profile.png'),
                            ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMe ? Colors.blue : Colors.blue[50],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    message['text'],
                                    softWrap: true,
                                    style: TextStyle(color: isMe ? Colors.white : Colors.black),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Align(
                                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                    child: Text(
                                      formattedTime,
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isMe) const SizedBox(width: 8),
                          if (isMe)
                            CircleAvatar(
                              radius: 17,
                              backgroundImage: AssetImage('lib/icons/profile.png'),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
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
                    decoration: const InputDecoration(hintText: "Type a message"),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}