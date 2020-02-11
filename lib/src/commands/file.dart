import '../ftpsocket.dart';

class FTPFile {
  FTPSocket _socket;

  FTPFile(this._socket);

  bool rename(String sOldName, String sNewName) {
    _socket.sendCommand('RNFR $sOldName');

    String sResponse = _socket.readResponse();
    if (!sResponse.startsWith('350')) {
      return false;
    }

    _socket.sendCommand('RNTO $sNewName');

    sResponse = _socket.readResponse();
    if (!sResponse.startsWith('250')) {
      return false;
    }

    return true;
  }

  bool delete(String sFilename) {
    _socket.sendCommand('DELE $sFilename');

    String sResponse = _socket.readResponse();
    return sResponse.startsWith('250');
  }
}
