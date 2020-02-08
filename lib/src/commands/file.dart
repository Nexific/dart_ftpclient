import '../ftpsocket.dart';

class FTPFile {
  FTPSocket _socket;

  FTPFile(this._socket);

  bool rename(String sOldName, String sNewName) {
    _socket.sendCommand('RNFR $sOldName');

    String sResponse = _socket.readResponse();
    if (!sResponse.startsWith('350 ')) {
      return false;
    }

    _socket.sendCommand('RNTP $sNewName');

    sResponse = _socket.readResponse();
    if (!sResponse.startsWith('250 ')) {
      return false;
    }

    return true;
  }
}
