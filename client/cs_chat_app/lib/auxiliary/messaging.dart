import 'package:cs_chat_app/auxiliary/client.dart';
import 'package:cs_chat_app/auxiliary/messagebox.dart';

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
  }

  bool auth(String uname, String pword) {
    _client!.auth(uname, pword);

    return _messages!.auth_status();
  }
}