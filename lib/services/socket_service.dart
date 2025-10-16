import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

class SocketService {
  IOWebSocketChannel? channel;

  void connect(String url) {
    channel = IOWebSocketChannel.connect(Uri.parse(url));

    channel!.stream.listen((message) {
      print('Server says: $message');
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
