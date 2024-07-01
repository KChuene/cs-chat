import 'package:cs_chat_app/widgets/chart_bubble.dart';
import 'package:flutter/material.dart';
import 'package:cs_chat_app/model/message.dart';

class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<TextMessage> messages = TextMessage.list();
  TextEditingController messageEditController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (BuildContext context, int index) {
                  final TextMessage currMessage = messages[index];
                  return ChatBubble(
                    message: currMessage
                  );
                }
              )
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: const [BoxShadow(
                          color: Colors.grey,
                          blurRadius: 2.0
                        )],
                        borderRadius: BorderRadius.circular(25)
                      ),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: "Message",
                          border: InputBorder.none
                        ),
                        controller: messageEditController,
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  ElevatedButton(
                    onPressed: () => addMessage(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: Size(60, 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void addMessage() {
    if(messageEditController.text.trim().isNotEmpty) {
      setState(() {
        messages.add(
          TextMessage(text: messageEditController.text, dtSent: DateTime.now(), isFromMe: true)
        );
      });
    }
  }
}