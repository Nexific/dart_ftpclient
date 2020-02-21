import 'dart:io';

import 'package:ftpclient/ftpclient.dart';

void main() {
  // Create Connection
  FTPClient ftpClient = FTPClient('example.com', user: 'myname', pass: 'mypass');

  // Connect to FTP Server
  ftpClient.connect();

  try {
    // Download File
    ftpClient.downloadFile('test.zip', File('test.zip'));
  } finally {
    // Disconnect
    ftpClient.disconnect();
  }
}
