import 'dart:io';

import 'package:ftpclient/src/debug/debuglog.dart';
import 'package:path/path.dart';

import '../ftpexceptions.dart';
import '../ftpsocket.dart';
import '../transfermode.dart';

class FileUpload {
  static const int _BUFFER_SIZE = 1024 * 1024;
  final FTPSocket _socket;
  final TransferMode _mode;
  final DebugLog _log;

  /// File Upload Command
  FileUpload(this._socket, this._mode, this._log);

  /// Upload File [fFile] to the current directory with [sRemoteName] (using filename if not set)
  void uploadFile(File fFile, [String sRemoteName = '']) {
    _log.log('Upload File: ${fFile.path}');

    // Transfer Mode
    switch(_mode) {
      case TransferMode.ascii:
        // Set to ASCII mode
        _socket.sendCommand('TYPE A');
        _socket.readResponse();
        break;
      case TransferMode.binary:
        // Set to BINARY mode
        _socket.sendCommand('TYPE I');
        _socket.readResponse();
        break;
      default:
        break;
    }

    // Enter passive mode
    _socket.sendCommand('PASV');

    String sResponse = _socket.readResponse();
    if (!sResponse.startsWith('227 ')) {
      throw FTPException('Could not start Passive Mode', sResponse);
    }

    int iPort = _parsePort(sResponse);

    // Store File
    String sFilename = sRemoteName;
    if (sFilename == null || sFilename.isEmpty) {
      sFilename = basename(fFile.path);
    }
    _socket.sendCommand('STOR $sFilename');

    // Data Transfer Socket
    _log.log('Opening DataSocket to Port $iPort');
    RawSynchronousSocket dataSocket = RawSynchronousSocket.connectSync(_socket.host, iPort);

    // Transfer file
    RandomAccessFile fRAFile = fFile.openSync(mode: FileMode.read);
    int iRead = 0;
    final int iSize = fRAFile.lengthSync();
    _log.log('File Size: $iSize');

    while (iRead < iSize) {
      int iEnd = _BUFFER_SIZE;
      if (iRead + iEnd > iSize) {
        iEnd = iSize - iRead;
      }

      List<int> buffer = List<int>(iEnd);
      fRAFile.readIntoSync(buffer);
      dataSocket.writeFromSync(buffer);

      iRead += iEnd;
    }

    _log.log('Uploaded: $iRead');

    dataSocket.closeSync();
    fRAFile.closeSync();

    _socket.readResponse();

    _log.log('File Uploaded!');
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