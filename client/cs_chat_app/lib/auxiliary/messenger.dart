import 'package:cs_chat_app/auxiliary/client.dart';
import 'package:cs_chat_app/auxiliary/messagebox.dart';
import 'package:cs_chat_app/model/message.dart';

class Messenger {
  Client? _client;
  MessageBox? _messages;
  static Messenger? _instance;
  
  Messenger._construct() {
    _client = Client(host: "127.0.0.1", port: 178);
    _messages = MessageBox();

    _client?.connect();
  }

  static Future<Messenger> create() async {
    _instance ??= Messenger._construct();

    return _instance as Messenger;
  }

  Future<bool> auth(String uname, String pword) async {
    await _client?.auth(AuthRequest(uname: uname, pword: pword));

    if(!AuthStatus.isReceived) {
      AuthStatus.text = "Authentication timed out.";
      return false;
    }

    return AuthStatus.isSuccess;
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