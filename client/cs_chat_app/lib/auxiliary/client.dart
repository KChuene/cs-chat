import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cs_chat_app/auxiliary/messenger.dart';
import 'package:cs_chat_app/model/message.dart';

class Client {

  Socket? socket;
  Client();

  Future<void> connect(Messenger messenger) async {

    try {
      socket = await Socket.connect(messenger.getDestIPv4(), messenger.getDestPort() as int);
    }
    catch (sockErr) {
      messenger.handleNotice(MsgType.error, "Failed to reach server." );
      return;
    }

    socket?.listen(
      (Uint8List data) async { 
        Map<String, dynamic> jsonObj = json.decode(String.fromCharCodes(data));
        
        messenger.handleMessage(jsonObj);
      },
      onError: (error) {
        messenger.handleNotice(MsgType.error, "Internal error. Try again." );
      },
      onDone: () {
        messenger.handleNotice(MsgType.end, "Server disconnected");

        socket?.destroy();
        socket = null;
      }
    );
  }

  bool connected() {
    return socket != null;
  }

  void auth(AuthRequest request) {
    AuthStatus.isReceived = false;
    socket?.write(json.encode(request.toJson()));
  }

  void send(TextMessage msg) async {
    socket?.write(json.encode(msg.toJson()));
  }

  void disconnect() {
    socket?.destroy();
  }
}