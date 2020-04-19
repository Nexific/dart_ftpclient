import 'dart:io';

import 'package:path/path.dart';

import '../ftpexceptions.dart';
import '../ftpsocket.dart';
import '../transfermode.dart';
import '../debug/debuglog.dart';
import '../util/transferutil.dart';

class FileUpload {
  final FTPSocket _socket;
  final TransferMode _mode;
  final DebugLog _log;

  /// File Upload Command
  FileUpload(this._socket, this._mode, this._log);

  /// Upload File [fFile] to the current directory with [sRemoteName] (using filename if not set)
  Future<void> uploadFile(File fFile, [String sRemoteName = '']) async {
    _log.log('Upload File: ${fFile.path}');

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
    final readStream = fFile.openRead();
    _log.log('Opening DataSocket to Port $iPort');
    final dataSocket = await Socket.connect(_socket.host, iPort);

    final acceptResponse = _socket.readResponse();
    _log.log('response $acceptResponse');

    await dataSocket.addStream(readStream);
    await dataSocket.flush();
    await dataSocket.close();

    _log.log('File Uploaded!');

    final fileReceivedResponse = _socket.readResponse();
    _log.log('second response $fileReceivedResponse');
  }
}
