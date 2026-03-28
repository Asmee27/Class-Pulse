import 'dart:math';

class SessionCodeGenerator {
  static Future<String> generateUniqueCode() async {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; 
    final rnd = Random();
    
    int retries = 0;
    while (retries < 10) {
      String code = String.fromCharCodes(Iterable.generate(
        4, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
        
      bool collision = false; 
      if (!collision) return code;
      
      retries++;
    }
    
    throw Exception('Could not generate unique 4-digit code after 10 retries.');
  }
}
