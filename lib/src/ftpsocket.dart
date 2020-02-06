import 'dart:convert';
import 'dart:io';

import 'package:ftpclient/src/debug/debuglog.dart';

import '../ftpclient.dart';

class FTPSocket {
  final Encoding _codec = Utf8Codec();

  final String host;
  final int port;
  final DebugLog _log;

  RawSynchronousSocket _socket;

  FTPSocket(this.host, this.port, this._log);

  /// Read the FTP Server response from the Stream
  /// 
  /// Blocks until data is received!
  String readResponse([bool bOptional = false]) {
    int iToRead = 0;
    StringBuffer buffer = StringBuffer();

    do {
      if (iToRead > 0) {
        buffer.write(_codec.decode(_socket.readSync(iToRead)));
      }

      iToRead = _socket.available();

      if (iToRead == 0 && buffer.length == 0) {
        sleep(Duration(milliseconds: 100));
      }
    } while (iToRead > 0 || (buffer.length == 0 && !bOptional));

    String sResponse = buffer.toString().trimRight();
    _log.log('< $sResponse');
    return sResponse;
  }

  /// Send a command to the FTP Server
  void sendCommand(String sCommand) {
    _log.log('> $sCommand');
    if (_socket.available() > 0) {
      readResponse();
    }
    _socket.writeFromSync(_codec.encode('$sCommand\r\n'));
  }

  /// Connect to the FTP Server and Login with [user] and [pass]
  void connect(String user, String pass) {
    _log.log('Connecting...');
    _socket = RawSynchronousSocket.connectSync(host, port);

    // Wait for Connect
    String sResponse = readResponse();
    if (!sResponse.startsWith('220 ')) {
      throw FTPException('Unknown response from FTP server', sResponse);
    }

    // Send Username
    sendCommand('USER $user');

    sResponse = readResponse();
    if (!sResponse.startsWith('331 ')) {
      throw FTPException('Wrong username $user', sResponse);
    }

    // Send Password
    sendCommand('PASS $pass');

    sResponse = readResponse();
    if (!sResponse.startsWith('230 ')) {
      throw FTPException('Wrong password', sResponse);
    }

    _log.log('Connected!');
  }

  // Disconnect from the FTP Server
  void disconnect() {
    _log.log('Disconnecting...');

    try {
      sendCommand('QUIT');
    } catch (ignored) {
      // Ignore
    } finally {
      _socket.closeSync();
    }

    _log.log('Disconnected!');
  }
}