class ROT {
  static String _rot47(String text) {
    StringBuffer result = StringBuffer();
    text.runes.forEach((int elem) { 
      if(elem < 33 || elem > 126) {
        result.writeCharCode(elem);
      } 
      else if(elem + 47 <= 126) {
        result.writeCharCode(elem + 47);
      }
      else {
        result.writeCharCode(32 + ((elem + 47) - 126));
      }
    });

    return result.toString();
  }

  static String _reverse(String text) {
    return text.split('').reversed.join('');
  }

  static String obfuscate(String text) {
    String rot47 = _rot47(text);
    return _reverse(rot47);
  }

  static String deobfuscate(String text) {
    String reversed = _reverse(text);
    return _rot47(reversed);
  }
}