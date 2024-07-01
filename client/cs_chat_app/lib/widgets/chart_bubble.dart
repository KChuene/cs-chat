import 'package:cs_chat_app/model/message.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  TextMessage message;

  ChatBubble({
    super.key,
    required this.message 
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 5, top: 3),
          alignment: (message.isFromMe!)? Alignment.topRight : Alignment.topLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.75
            ),
        
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: (message.isFromMe!)? Colors.green : Color.fromRGBO(123, 116, 116, 1),
              borderRadius: BorderRadius.circular(8)
            ),
            
            child: Text(
              message.text!,
              style: TextStyle(
                color: Colors.white
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: (message.isFromMe!)? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Text(
              TimeOfDay.fromDateTime(message.dtSent!).format(context),
              style: TextStyle(
                fontSize: 11
              ),
            )
          ],
        )
      ],
    );
  }
}