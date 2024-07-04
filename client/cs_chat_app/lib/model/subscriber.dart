import 'package:cs_chat_app/model/message.dart';

abstract class MessengerSubscriber {
  void handleMessage(Message message);
}