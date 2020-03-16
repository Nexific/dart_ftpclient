import 'dart:io';

import 'package:ftpclient/ftpclient.dart';
import 'package:ftpclient/src/dto/FTPEnty.dart';
import 'package:ftpclient/src/util/transferutil.dart';

import '../ftpexceptions.dart';
import '../ftpsocket.dart';

class FTPDirectory {
  final FTPSocket _socket;

  FTPDirectory(this._socket);

  bool makeDirectory(String sName) {
    _socket.sendCommand('MKD $sName');

    String sResponse = _socket.readResponse();

    return sResponse.startsWith('257');
  }

  bool deleteDirectory(String sName) {
    _socket.sendCommand('RMD $sName');

    String sResponse = _socket.readResponse();

    return sResponse.startsWith('250');
  }

  bool changeDirectory(String sName) {
    _socket.sendCommand('CWD $sName');

    String sResponse = _socket.readResponse();

    return sResponse.startsWith('250');
  }

  String currentDirectory() {
    _socket.sendCommand('PWD');

    String sResponse = _socket.readResponse();
    if (!sResponse.startsWith('257')) {
      throw FTPException('Failed to get current working directory', sResponse);
    }

    int iStart = sResponse.indexOf('"') + 1;
    int iEnde = sResponse.lastIndexOf('"');

    return sResponse.substring(iStart, iEnde);
  }

  List<FTPEntry> listDirectoryContent() {
    // Transfer mode
    TransferUtil.setTransferMode(_socket, TransferMode.ascii);

    // Enter passive mode
    _socket.sendCommand('PASV');

    String sResponse = _socket.readResponse();
    if (!sResponse.startsWith('227')) {
      throw FTPException('Could not start Passive Mode', sResponse);
    }

    int iPort = TransferUtil.parsePort(sResponse);

    // Directoy content listing
    _socket.sendCommand('MLSD');

    // Data transfer socket
    RawSynchronousSocket dataSocket =
        RawSynchronousSocket.connectSync(_socket.host, iPort);

    sResponse = _socket.readResponse();
    if (!sResponse.startsWith('150')) {
      throw FTPException('Can\'t get content of directory.', sResponse);
    }

    int iToRead = 0;
    List<int> lstDirectoryListing = List<int>();

    do {
      if (iToRead > 0) {
        List<int> buffer = List<int>(iToRead);
        dataSocket.readIntoSync(buffer);
        buffer.forEach(lstDirectoryListing.add);
      }

      iToRead = dataSocket.available();

      if (iToRead == 0 || lstDirectoryListing.isEmpty) {
        sleep(Duration(milliseconds: 500));
        iToRead = dataSocket.available();
      }
    } while (iToRead > 0 || lstDirectoryListing.isEmpty);

    dataSocket.closeSync();

    if (!sResponse.contains('226')) {
      sResponse = _socket.readResponse(true);
      if (!sResponse.startsWith('226')) {
        throw FTPException('Can\'t get content of directory.', sResponse);
      }
    }

    // Convert MLSD response into FTPEntry
    List<FTPEntry> lstFTPEntries = List<FTPEntry>();
    String.fromCharCodes(lstDirectoryListing).split('\n').forEach((line) {
      if (line.trim().isNotEmpty) {
        lstFTPEntries.add(FTPEntry(line));
      }
    });

    return lstFTPEntries;
  }
}
