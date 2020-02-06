import 'dart:io';

import 'package:ftpclient/src/commands/fileupload.dart';
import 'package:ftpclient/src/debug/debuglog.dart';
import 'package:ftpclient/src/debug/nooplog.dart';
import 'package:ftpclient/src/debug/printlog.dart';

import 'ftpsocket.dart';

class FTPClient {
  String _user;
  String _pass;
  FTPSocket _socket;
  DebugLog _log;

  /// Create a FTP Client instance
  /// 
  /// [host]: Hostname or IP Address
  /// [port]: Port number (Defaults to 21)
  /// [user]: Username (Defaults to anonymous)
  /// [pass]: Password if not anonymous login
  /// [debug]: Enable Debug Logging
  FTPClient(String host, {int port = 21, String user = 'anonymous', String pass = '', bool debug = false}) {
    _user = user;
    _pass = pass;

    if (debug) {
      _log = new PrintLog();
    } else {
      _log = new NoOpLogger();
    }

    _socket = new FTPSocket(host, port, _log);
  }

  /// Connect to the FTP Server
  void connect() {
    _socket.connect(_user, _pass);
  }

  // Disconnect from the FTP Server
  void disconnect() {
    _socket.disconnect();
  }

  /// Upload the File [fFile] to the current directory
  void uploadFile(File fFile) {
    new FileUpload(_socket, _log).uploadFile(fFile);
  }
}
