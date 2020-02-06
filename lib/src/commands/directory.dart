import '../ftpexceptions.dart';
import '../ftpsocket.dart';

class FTPDirectory {
  final FTPSocket _socket;

  FTPDirectory(this._socket);

  bool makeDirectory(String sName) {
    _socket.sendCommand('MKD $sName');

    String sResponse = _socket.readResponse();

    return sResponse.startsWith('257 ');
  }

  bool deleteDirectory(String sName) {
    _socket.sendCommand('RMD $sName');

    String sResponse = _socket.readResponse();
    
    return sResponse.startsWith('250 ');
  }

  bool changeDirectory(String sName) {
    _socket.sendCommand('CWD $sName');

    String sResponse = _socket.readResponse();

    return sResponse.startsWith('250 ');
  }

  String currentDirectory() {
    _socket.sendCommand('PWD');

    String sResponse = _socket.readResponse();
    if (!sResponse.startsWith('257 ')) {
      throw FTPException('Failed to get current working directory', sResponse);
    }

    int iStart = sResponse.indexOf('"') + 1;
    int iEnde = sResponse.lastIndexOf('"');

    return sResponse.substring(iStart, iEnde);
  }
}