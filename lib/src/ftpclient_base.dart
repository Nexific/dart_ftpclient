import 'dart:io';

import 'ftpsocket.dart';
import 'ftpexceptions.dart';

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
    _socket.sendCommand('PASV');

    String sResponse = _socket.readResponse();
    if (!sResponse.startsWith('227 ')) {
      throw new FTPException('Could not start Passive Mode', sResponse);
    }

    int iPort = _parsePort(sResponse);
  }

  int _parsePort(String sResponse) {
    int iParOpen = sResponse.indexOf('(');
    int iParClose = sResponse.indexOf(')');

    String sParameters = sResponse.substring(iParOpen + 1, iParClose);
    List<String> lstParameters = sParameters.split(',');

    int iPort1 = int.parse(lstParameters[lstParameters.length - 2]);
    int iPort2 = int.parse(lstParameters[lstParameters.length - 1]);

    return (iPort1 * 256) + iPort2;
  }
}
