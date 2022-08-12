import 'dart:io';

import 'print_result.dart';

class NetworkPrinter {
  String host;
  int port;
  Duration timeout;
  bool _isConnected = false;
  Socket _socket;

  NetworkPrinter(
    this.host, {
    this.port = 9100,
    this.timeout = const Duration(seconds: 5),
  });

  Future<PrintResult> connect(
      {Duration timeout = const Duration(seconds: 5)}) async {
    try {
      _socket = await Socket.connect(host, port, timeout: timeout);
      _isConnected = true;
      return PrintResult.success;
    } catch (e) {
      _isConnected = false;
      return PrintResult.timeout;
    }
  }

  Future<PrintResult> print(List<int> data, {bool isDisconnect = true}) async {
    try {
      if (!_isConnected) {
        await connect();
      }
      _socket.add(data);
      if (isDisconnect) {
        await disconnect();
      }
      return PrintResult.success;
    } catch (e) {
      return PrintResult.timeout;
    }
  }

  Future<PrintResult> disconnect({Duration timeout}) async {
    await _socket.flush();
    await _socket.close();
    _isConnected = false;
    if (timeout != null) {
      await Future.delayed(timeout, () => null);
    }
    return PrintResult.success;
  }
}
