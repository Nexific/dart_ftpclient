import 'dart:io';

import 'package:ftpclient/ftpclient.dart';

void main() {
  // Create Connection
  FTPClient ftpClient = new FTPClient('example.com', user: 'myname', pass: 'mypass');

  // Connect to FTP Server
  ftpClient.connect();

  try {
    // Create Directory
    ftpClient.makeDirectory('test');

    // Change Directory
    ftpClient.changeDirectory('test');

    // Get current Directory
    print(ftpClient.currentDirectory());

    // Upload File
    ftpClient.uploadFile(new File('test.zip'));
    
    // Navigate back
    ftpClient.changeDirectory('..');

    // Delete Directory
    ftpClient.deleteDirectory('test');
  } finally {
    // Disconnect
    ftpClient.disconnect();
  }
}
