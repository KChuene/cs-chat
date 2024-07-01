import 'package:cs_chat_app/auxiliary/client.dart';
import 'package:cs_chat_app/auxiliary/messagebox.dart';
import 'package:cs_chat_app/model/message.dart';

class Messaging {
  Client? _client;
  MessageBox? _messages;
  static final Messaging _instance = Messaging._construct();

  factory Messaging() {
    return _instance;
  }
  
  Messaging._construct() {
    _client = Client(host: "127.0.0.1", port: 178);
    _messages = MessageBox();

    _client?.connect();
  }

  bool auth(String uname, String pword) {
    _client?.auth(AuthRequest(uname: uname, pword: pword));

    return AuthResponse.isSuccess;
  }

  void send(String text) {
    _client?.send(
      TextMessage(
        type: MsgType.normal,
        dtSent: DateTime.now(), 
        text: text, 
        isFromMe: true
      )
    );
  }
}