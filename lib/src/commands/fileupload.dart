import 'dart:io';

import '../ftpexceptions.dart';
import '../ftpsocket.dart';

class FileUpload {
  final FTPSocket _socket;

  /// File Upload Command
  FileUpload(this._socket);

  /// Upload File [fFile] to the current directory
  void upload(File fFile) {
    _socket.sendCommand('PASV');

    String sResponse = _socket.readResponse();
    if (!sResponse.startsWith('227 ')) {
      throw new FTPException('Could not start Passive Mode', sResponse);
    }

    int iPort = _parsePort(sResponse);
  }

  /// Parse the Passive Mode Port from the Servers [sResponse]
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