class Message {
  String? text;
  DateTime? dtSent;
  bool isFromMe;

  Message({
    required text,
    required dtSent,
    this.isFromMe = true
  });

  static List<Message> list() {
    return [
      Message(text: "Wazzup bro.", dtSent: DateTime.now(), isFromMe: false),
      Message(text: "Homie, what's going on; I was wondering where you been at?", dtSent: DateTime.now(), isFromMe: true)
    ];
  }
}