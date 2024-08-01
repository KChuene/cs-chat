import 'package:cs_chat_app/auxiliary/client.dart';
import 'package:cs_chat_app/auxiliary/messagebox.dart';
import 'package:cs_chat_app/model/message.dart';
import 'package:cs_chat_app/model/subscriber.dart';

class Messenger {
  Client? _client; // send requests to, get responses from
  MessageBox? _messages;
  MessengerSubscriber? _subscriber; // get requests from, send responses to
  final String? _destAddress;
  final int? _destPort;

  static Messenger? _instance;
  
  Messenger._construct(this._destAddress, this._destPort) {
    _client = Client();
    _messages = MessageBox();
  }

  static Messenger getInstance({String? host, int? port}) {
    bool newAddress = (host != null) && (port != null);
    if(_instance == null || newAddress) {
      _instance = Messenger._construct(host, port);
    }    

    return _instance as Messenger;
  }

  String? getDestIPv4() => _destAddress;
  int? getDestPort() => _destPort;

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

  bool connected() {
    return _client?.connected() as bool;
  }

  void auth(String uname, String pword) async {
    await reConnectEx();

    AuthStatus.uname = uname;
    _client?.auth(
      AuthRequest(
        uname: uname, 
        pword: pword
      )
    );
  }

  void send(TextMessage message) async {
    await reConnectEx();
    _client?.send(message);
  }

  Future<void> reConnectEx() async {
    if(_destAddress != null || _destPort != null) {
      if(!_client!.connected()) {
        await _client?.connect(this);
      }
    }
  }
}