import 'dart:io';

import 'package:path/path.dart';

import '../ftpexceptions.dart';
import '../ftpsocket.dart';
import '../transfermode.dart';
import '../debug/debuglog.dart';
import '../util/transferutil.dart';

class FileUpload {
  final int _bufferSize;
  final FTPSocket _socket;
  final TransferMode _mode;
  final DebugLog _log;

  /// File Upload Command
  FileUpload(this._socket, this._bufferSize, this._mode, this._log);

  /// Upload File [fFile] to the current directory with [sRemoteName] (using filename if not set)
  void uploadFile(File fFile, [String sRemoteName = '']) {
    _log.log('Upload File: ${fFile.path}');
    RandomAccessFile fRAFile = fFile.openSync(mode: FileMode.read);

    // Transfer Mode
    TransferUtil.setTransferMode(_socket, _mode);

    // Enter passive mode
    _socket.sendCommand('PASV');

    String sResponse = _socket.readResponse();
    if (!sResponse.startsWith('227')) {
      throw FTPException('Could not start Passive Mode', sResponse);
    }

    int iPort = TransferUtil.parsePort(sResponse);

    // Store File
    String sFilename = sRemoteName;
    if (sFilename == null || sFilename.isEmpty) {
      sFilename = basename(fFile.path);
    }
    _socket.sendCommand('STOR $sFilename');

    // Data Transfer Socket
    _log.log('Opening DataSocket to Port $iPort');
    RawSynchronousSocket dataSocket =
        RawSynchronousSocket.connectSync(_socket.host, iPort);

    // Transfer file
    int iRead = 0;
    final int iSize = fRAFile.lengthSync();
    _log.log('File Size: $iSize B');

    while (iRead < iSize) {
      int iEnd = _bufferSize;
      if (iRead + iEnd > iSize) {
        iEnd = iSize - iRead;
      }

      List<int> buffer = List<int>(iEnd);
      fRAFile.readIntoSync(buffer);
      dataSocket.writeFromSync(buffer);

      iRead += iEnd;
    }

    _log.log('Uploaded: $iRead B');

    dataSocket.closeSync();
    fRAFile.closeSync();

    _socket.readResponse();

    _log.log('File Uploaded!');

    _socket.readResponse(true);
  }
}
