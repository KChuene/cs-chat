
enum MsgType { 
  auth, 
  normal, 
  error, 
  end,
  none
}

class Message {
  MsgType type;

  Message({
    this.type = MsgType.auth,
  });

  Message.fromJson(Map<String, dynamic> json) 
    : type = MsgType.values.firstWhere((t) => t.name == json["type"]);

}

class TextMessage extends Message {  
  String text = "";
  String sender = "";
  bool? isFromMe;
  DateTime? dtSent;

  TextMessage({
    required this.text,
    required this.sender,
    required this.dtSent,
    required this.isFromMe,
    super.type
  });

  static List<TextMessage> list() {
    return [
      TextMessage(text: "Hello You.", sender: AuthStatus.uname, dtSent: DateTime.now(), isFromMe: false),
      TextMessage(text: "Hello Friend.", sender: AuthStatus.uname, dtSent: DateTime.now(), isFromMe: true),
    ];
  }
  
  TextMessage.fromJson(Map<String, dynamic> json) {
    type = MsgType.values.firstWhere((t) => t.name == json["type"]);
    text = json["text"] as String;
    isFromMe = false;
    dtSent = DateTime.parse(json["date"]);
  }
    
  Map<String, dynamic> toJson() => {
    "type": type.name,
    "text": text,
    "isFromMe": isFromMe,
    "date": dtSent.toString()
  };
}

class AuthStatus extends Message {
  static String uname = "";
  static bool isReceived = false;
  static bool isSuccess = false;
  static String text = "";

  static setFromJson(Map<String, dynamic> json)  {
    isSuccess = json["isSuccess"] as bool;
    text = json["text"] as String;
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type.name,
      "isSuccess": isSuccess,
      "message": text
    };
  }
}

class AuthRequest extends Message {
  String uname;
  String pword;

  AuthRequest({
    required this.uname,
    required this.pword
  });

  Map<String, dynamic> toJson() => {
    "type": type.name,
    "uname": uname,
    "pword": pword
  };
}

class Notice extends Message {
  String text;

  Notice({required this.text, super.type});
}