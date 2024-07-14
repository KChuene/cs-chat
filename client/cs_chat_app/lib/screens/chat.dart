import 'package:cs_chat_app/auxiliary/messenger.dart';
import 'package:cs_chat_app/constants/colors.dart';
import 'package:cs_chat_app/model/subscriber.dart';
import 'package:cs_chat_app/screens/login.dart';
import 'package:cs_chat_app/widgets/chart_bubble.dart';
import 'package:flutter/material.dart';
import 'package:cs_chat_app/model/message.dart';

class ChatScreen extends StatefulWidget {
  static const String route = "/chat-screen";

  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> implements MessengerSubscriber {
  List<TextMessage> messages = TextMessage.list();
  TextEditingController messageEditController = TextEditingController();
  Messenger messenger = Messenger.getInstance();

  ScrollController scrollControl = ScrollController();

  @override
  void initState() {
    messenger.subscribe(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (_) => _logout(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          title: Row(
            children: [
              ElevatedButton(
                onPressed: () => _logout(),
                child: Icon(
                  Icons.logout_rounded,
                  size: 18,
                  color: MainColor.green,
                ),
                style: ElevatedButton.styleFrom(shape: const CircleBorder())
              ),
              const Text(
                "Logout", 
                style: TextStyle(
                  fontSize: 12, 
                  fontWeight: FontWeight.w200
                ),
              )
            ],
          ),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
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
                      const SizedBox(width: 15),
                      ElevatedButton(
                        onPressed: () => addMessage(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(60, 60),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))
                        ),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
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

      messenger.send(message);
      setState(() {
        messages.add(message);
      });
      
      messageEditController.clear();
    }
  }
  
  @override
  void handleMessage(Message message) {
    switch(message.type) {
      case MsgType.auth: {
        _showDialog("Auth", AuthStatus.text);
        break;
      }
      case MsgType.normal: {
        setState(() {
          messages.add(message as TextMessage);
        });
        break;
      }
      default: { // error, end
        _showDialog("Notice", (message as Notice).text);
      }
    }
  }

  Future<void> _showDialog(String title, String message) {
    return showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(message, style: const TextStyle(fontWeight: FontWeight.w100),),
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

  void _logout() {
    AuthStatus.isSuccess = false;
    Navigator.of(context).pushNamed(LoginScreen.route);
  }

  Future<void> _promptLogout() {
    TextStyle btnTextStyle = const TextStyle(
      color: MainColor.green,
      fontWeight: FontWeight.bold
    );

    return showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Log Out"),
          content: const Text(
            "Are you sure you want to logout?",
            style: TextStyle(fontWeight: FontWeight.w100)
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              }, 
              child: Text("Cancel", style: btnTextStyle,)
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Future.delayed(Duration(seconds: 2), () {
                  Navigator.popUntil(context, ModalRoute.withName(LoginScreen.route));
                });
              }, 
              child: Text("Yes", style: btnTextStyle,)
            )
          ],
        );
      }
    );
  }
}