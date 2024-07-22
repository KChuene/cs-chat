import 'package:cs_chat_app/auxiliary/client.dart';
import 'package:cs_chat_app/auxiliary/messagebox.dart';
import 'package:cs_chat_app/model/message.dart';
import 'package:cs_chat_app/model/subscriber.dart';

class Messenger {
  Client? _client; // send requests to, get responses from
  MessageBox? _messages;
  MessengerSubscriber? _subscriber; // get requests from, send responses to

  static Messenger? _instance;
  
  Messenger._construct() {
    _client = Client(host: "127.0.0.1", port: 178);
    _messages = MessageBox();
  }

  static Messenger getInstance() {
    _instance ??= Messenger._construct();

    return _instance as Messenger;
  }

  void subscribe(MessengerSubscriber subscriber) {
    _subscriber = subscriber;
  }

  void unsubscribe(MessengerSubscriber subscriber) {
    if(_subscriber == subscriber) {
      _subscriber = null;
    }
  }

  void handleMessage(Map<String, dynamic> jsonObj) {
    Message message = Message.fromJson(jsonObj);

    switch(message.type) {
      case MsgType.auth: {
        AuthStatus.setFromJson(jsonObj);
        
        _subscriber?.handleMessage(message); // notify subscriber
        break;
      }
      default: {
        TextMessage newMessage = TextMessage.fromJson(jsonObj);
        _messages!.add(newMessage);

        _subscriber?.handleMessage(newMessage);
      }
    }
  }

  void handleNotice(MsgType type, String message) {
    switch(type) {
      case MsgType.error:
      case MsgType.end: {
        if(AuthStatus.isSuccess) {
          Notice notice = Notice(
            type: type,
            text: message,
          );

          _messages?.add(notice);
          _subscriber?.handleMessage(notice);
        }
        else {
          AuthStatus.text = message;
          _subscriber?.handleMessage(Message());
        }
        break;
      }
      default: 
        return; // drop
    }
  }

  void auth(String uname, String pword) async {
    reConnectEx();

    AuthStatus.uname = uname;
    _client?.auth(
      AuthRequest(
        uname: uname, 
        pword: pword
      )
    );
  }

  void send(TextMessage message) {
    reConnectEx();
    _client?.send(message);
  }

  void reConnectEx() async {
    if(_client!.disconnected()) {
      await _client?.connect(_instance as Messenger);
    }
  }
}