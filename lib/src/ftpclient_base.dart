import 'dart:io';

import 'package:ftpclient/src/commands/fileupload.dart';
import 'package:ftpclient/src/debug/debuglog.dart';
import 'package:ftpclient/src/debug/nooplog.dart';
import 'package:ftpclient/src/debug/printlog.dart';

import 'commands/directory.dart';
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

  /// Create a new Directory with the Name of [sDirectory] in the current directory
  /// Returns `true` if the directory was created successfully
  /// Returns `false` if the directory could not be created or already exists
  bool makeDirectory(String sDirectory) {
    return new FTPDirectory(_socket).makeDirectory(sDirectory);
  }

  /// Deletes the Directory with the Name of [sDirectory] in the current directory
  /// Returns `true` if the directory was deleted successfully
  /// Returns `false` if the directory could not be deleted or does not nexist
  bool deleteDirectory(String sDirectory) {
    return new FTPDirectory(_socket).deleteDirectory(sDirectory);
  }

  /// Change into the Directory with the Name of [sDirectory] within the current directory
  /// Use `..` to navigate back
  /// Returns `true` if the directory was changed successfully
  /// Returns `false` if the directory could not be changed (does not exist, no permissions or another error)
  bool changeDirectory(String sDirectory) {
    return new FTPDirectory(_socket).changeDirectory(sDirectory);
  }

  /// Returns the current directory
  String currentDirectory() {
    return new FTPDirectory(_socket).currentDirectory();
  }
}
