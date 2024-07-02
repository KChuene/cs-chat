enum MsgType { 
  auth, 
  normal, 
  error, 
  end 
}

class Message {
  MsgType type;

  Message({
    this.type = MsgType.auth,
  });

  Message.fromJson(Map<String, dynamic> json) 
    : type = json["type"] as MsgType;
}

class TextMessage extends Message {
  String? text;
  bool? isFromMe;
  DateTime? dtSent;

  TextMessage({
    required this.dtSent,
    required this.isFromMe,
    super.type,
    required text
  });

  static List<TextMessage> list() {
    return [
      TextMessage(text: "Wazzup bro.", dtSent: DateTime.now(), isFromMe: false),
      TextMessage(text: "Homie, what's going on; I was wondering where you been at?", dtSent: DateTime.now(), isFromMe: true),
      TextMessage(text: "Busy days it's been. But finally have some time off now.", dtSent: DateTime.now(), isFromMe: false),
      TextMessage(text: "That's good to here.", dtSent: DateTime.now(), isFromMe: true),
      TextMessage(text: "So... game night?", dtSent: DateTime.now(), isFromMe: true),
      TextMessage(text: "You bet!!", dtSent: DateTime.now(), isFromMe: false)
    ];
  }
  
  TextMessage.fromJson(Map<String, dynamic> json) {
    type = json["type"] as MsgType;
    text = json["text"] as String;
    isFromMe = false;
    dtSent = json["date"] as DateTime;
  }
    
  Map<String, dynamic> toJson() => {
    "type": type,
    "text": text,
    "isFromMe": isFromMe,
    "date": dtSent
  };
}

class AuthStatus extends Message {
  static bool isReceived = false;
  static bool isSuccess = false;
  static String text = "";

  static setFromJson(Map<String, dynamic> json)  {
    isSuccess = json["isSuccess"] as bool;
    text = json["message"] as String;
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type,
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
    "uname": uname,
    "pword": pword
  };
}

class Notice extends Message {
  String text;

  Notice({required this.text, super.type});
}