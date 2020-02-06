import 'dart:io';

import 'package:path/path.dart';

import '../ftpexceptions.dart';
import '../ftpsocket.dart';

class FileUpload {
  static const int BUFFER_SIZE = 1024 * 1024;
  final FTPSocket _socket;

  /// File Upload Command
  FileUpload(this._socket);

  /// Upload File [fFile] to the current directory
  void uploadFile(File fFile) {
    // Enter passive mode
    _socket.sendCommand('PASV');

    String sResponse = _socket.readResponse();
    if (!sResponse.startsWith('227 ')) {
      throw new FTPException('Could not start Passive Mode', sResponse);
    }

    int iPort = _parsePort(sResponse);

    // Store File
    _socket.sendCommand('STOR ' + basename(fFile.path));

    // Data Transfer Socket
    RawSynchronousSocket dataSocket = RawSynchronousSocket.connectSync(_socket.host, iPort);

    // Transfer file
    RandomAccessFile fRAFile = fFile.openSync(mode: FileMode.read);
    int iRead = 0;
    final int iSize = fRAFile.lengthSync();

    while (iRead < iSize) {
      int iEnd = BUFFER_SIZE;
      if (iRead + iEnd > iSize) {
        iEnd = iSize - iRead;
      }

      List<int> buffer = new List<int>(iEnd);
      fRAFile.readIntoSync(buffer);
      dataSocket.writeFromSync(buffer);

      iRead += iEnd;
    }

    dataSocket.closeSync();
    fRAFile.closeSync();
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