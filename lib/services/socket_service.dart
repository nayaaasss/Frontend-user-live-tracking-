import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

class SocketService {
  IOWebSocketChannel? channel;

  Function(String message)? onAlert;

  void connect(String url) {
    channel = IOWebSocketChannel.connect(Uri.parse(url));

    channel!.stream.listen((message) {
      print('Server says: $message');

      try {
        final data = jsonDecode(message);

        // Cek apakah server kirim field "alert"
        if (data is Map && data.containsKey('alert')) {
          final alert = data['alert'];
          if (alert != null && alert.toString().isNotEmpty) {
            onAlert?.call(alert.toString());
          }
        }
      } catch (e) {
        print('Error parsing message: $e');
      }
    }, onDone: () {
      print('Disconnected from server');
    });
  }

  void sendLocation(Map<String, dynamic> data) {
    if (channel != null) {
      channel!.sink.add(jsonEncode(data));
    }
  }

  void dispose() {
    channel?.sink.close(status.goingAway);
  }
}
