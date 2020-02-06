import 'dart:convert';
import 'dart:io';

import 'ftpexceptions.dart';

class FTPClient {
  final Encoding _codec = new Utf8Codec();

  final String _host;
  final int _port;
  final String _user;
  final String _pass;

  RawSynchronousSocket _socket;

  FTPClient(this._host, [this._port = 21, this._user = 'anonymous', this._pass = '']);

  String _readResponse() {
    int iToRead = 0;
    StringBuffer buffer = new StringBuffer();

    do {
      if (iToRead > 0) {
        buffer.write(_codec.decode(_socket.readSync(iToRead)));
      }

      iToRead = _socket.available();

      sleep(new Duration(milliseconds: 100));
    } while (iToRead > 0 || buffer.length == 0);

    return buffer.toString().trimRight();
  }

  void _sendCommand(String sCommand) {
    _socket.writeFromSync(_codec.encode('$sCommand\r\n'));
  }

  void connect() {
    _socket = RawSynchronousSocket.connectSync(_host, _port);

    // Wait for Connect
    String sResponse = _readResponse();
    if (!sResponse.startsWith('220 ')) {
      throw new FTPException('Unknown response from FTP server', sResponse);
    }

    // Send Username
    _sendCommand('USER $_user');

    sResponse = _readResponse();
    if (!sResponse.startsWith('331 ')) {
      throw new FTPException('Wrong username $_user', sResponse);
    }

    // Send Password
    _sendCommand('PASS $_pass');

    sResponse = _readResponse();
    if (!sResponse.startsWith('230 ')) {
      throw new FTPException('Wrong password', sResponse);
    }
  }

  void disconnect() {
    try {
      _sendCommand('QUIT');
    } catch (ignored) {
      // Ignore
    } finally {
      _socket.closeSync();
    }
  }

  void uploadFile(File fFile) {
    _sendCommand('PASV');

    String sResponse = _readResponse();
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
