import 'package:cs_chat_app/auxiliary/messenger.dart';
import 'package:cs_chat_app/constants/colors.dart';
import 'package:cs_chat_app/model/subscriber.dart';
import 'package:cs_chat_app/widgets/chart_bubble.dart';
import 'package:flutter/material.dart';
import 'package:cs_chat_app/model/message.dart';

class ChatScreen extends StatefulWidget {
  static const String route = "/chat-screen";

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> implements MessengerSubscriber {
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

  void addMessage() async {
    if(messageEditController.text.trim().isNotEmpty) {
      TextMessage message = TextMessage(
        type: MsgType.normal,
        text: messageEditController.text, 
        dtSent: DateTime.now(), 
        isFromMe: true
      );

      Messenger messenger = await Messenger.getInstance();
      messenger.subscribe(this);
      messenger.send(message);
      setState(() {
        messages.add(message);
      });
    }
  }
  
  @override
  void handleMessage(Message message) {
    print("I am a handler for Chat");
    setState(() { 
      switch(message.type) {
        case MsgType.auth: {
          if(!AuthStatus.isSuccess) {
            _showDialog("Logged Out", AuthStatus.text);
          } 
          Navigator.of(context).pop();
          break;
        }
        case MsgType.normal: {
          messages.add(message as TextMessage);
          break;
        }
        default: {
          _showDialog("Notice", (message as Notice).text);
          Navigator.of(context).pop();
        }
      }
    });
  }

  Future<void> _showDialog(String title, String message) async {
    print("I am trying to output a dialog");
    return showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(message, style: TextStyle(fontWeight: FontWeight.w100),),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              }, 
              child: const Text(
                "OK", 
                style: TextStyle(
                  color: MainColor.green,
                  fontWeight: FontWeight.bold
                ),
              ),
            )
          ],
        );
      },
    );
  }
}