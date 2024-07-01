import 'package:cs_chat_app/model/message.dart';

class MessageBox {
  List<Message> messages = [];
  static final MessageBox _instance = MessageBox._construct();

  factory MessageBox() {
    return _instance;
  }

  MessageBox._construct();

  void add(Message message) => messages.add(message);

  Message get(int index) => messages[(index >= 0 && index < messages.length)? index : 0];

  Message last() => messages.removeLast();
}