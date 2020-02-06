import 'dart:io';

import 'package:ftpclient/src/commands/fileupload.dart';

import 'ftpsocket.dart';

class FTPClient {
  final String _user;
  final String _pass;
  FTPSocket _socket;

  /// Create a FTP Client instance
  /// 
  /// [host]: Hostname or IP Address
  /// [port]: Port number (Defaults to 21)
  /// [_user]: Username (Defaults to anonymous)
  /// [_pass]: Password if not anonymous login
  FTPClient(String host, [int port = 21, this._user = 'anonymous', this._pass = '']) {
    _socket = new FTPSocket(host, port);
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
    new FileUpload(_socket).uploadFile(fFile);
  }
}
