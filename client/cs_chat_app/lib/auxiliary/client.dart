import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cs_chat_app/auxiliary/messenger.dart';
import 'package:cs_chat_app/auxiliary/rotcipher.dart';
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
        String jsonStr = ROT.deobfuscate(String.fromCharCodes(data));
        Map<String, dynamic> jsonObj = json.decode(jsonStr);
        
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
    String obfRequest = ROT.obfuscate( json.encode(request.toJson()) ); 
    socket?.write(obfRequest);
  }

  void send(TextMessage msg) async {
    String obfMsg = ROT.obfuscate( json.encode(msg.toJson()) );
    socket?.write(obfMsg);
  }

  void disconnect() {
    socket?.destroy();
  }
}