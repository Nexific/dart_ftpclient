import 'dart:io';

import '../ftpexceptions.dart';
import '../ftpsocket.dart';
import '../transfermode.dart';
import '../debug/debuglog.dart';
import '../util/transferutil.dart';

class FileDownload {
  final FTPSocket _socket;
  final TransferMode _mode;
  final DebugLog _log;

  /// File Download Command
  FileDownload(this._socket, this._mode, this._log);

  void downloadFile(String sRemoteName, File fLocalFile) {
    _log.log('Download $sRemoteName to ${fLocalFile.path}');

    // Transfer Mode
    TransferUtil.setTransferMode(_socket, _mode);

    // Enter passive mode
    _socket.sendCommand('PASV');

    String sResponse = _socket.readResponse();
    if (!sResponse.startsWith('227')) {
      throw FTPException('Could not start Passive Mode', sResponse);
    }

    int iPort = TransferUtil.parsePort(sResponse);

    _socket.sendCommand('RETR $sRemoteName');
    sResponse = _socket.readResponse(true);
    if (sResponse.startsWith('550')) {
      throw FTPException('Remote File $sRemoteName does not exist!', sResponse);
    }

    // Transfer file
    RandomAccessFile fRAFile = fLocalFile.openSync(mode: FileMode.writeOnly);

    // Data Transfer Socket
    _log.log('Opening DataSocket to Port $iPort');
    RawSynchronousSocket dataSocket =
        RawSynchronousSocket.connectSync(_socket.host, iPort);

    int iToRead = 0;
    int iRead = 0;

    do {
      if (iToRead > 0) {
        List<int> buffer = List<int>(iToRead);
        dataSocket.readIntoSync(buffer);
        fRAFile.writeFromSync(buffer);
        iRead += iToRead;
      }

      iToRead = dataSocket.available();

      if (iToRead == 0 || iRead == 0) {
        sleep(Duration(milliseconds: 500));
        iToRead = dataSocket.available();
      }
    } while (iToRead > 0 || iRead == 0);

    _log.log('Downloaded: $iRead B');

    dataSocket.closeSync();
    fRAFile.flushSync();
    fRAFile.closeSync();

    _socket.readResponse();

    _log.log('File Downloaded!');
    _socket.readResponse(true);
  }
}
