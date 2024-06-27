import 'package:flutter/material.dart';
import 'package:cs_chat_app/model/message.dart';

class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> messages = Message.list();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  for(Message message in messages) 
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: (message.isFromMe)? Colors.green : Color.fromARGB(255, 48, 47, 47)),
                      alignment: (message.isFromMe)? Alignment.centerRight : Alignment.centerLeft,
                      child: Text(
                        message.text.toString(),
                        style: TextStyle(
                          color: Colors.white
                        )
                      )
                    )
                ],
              ),
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
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: "Message",
                          border: InputBorder.none
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  ElevatedButton(
                    onPressed: () {},
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
}