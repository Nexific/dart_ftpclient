import 'package:ftpclient/ftpclient.dart';

void main() {
  // Create Connection
  FTPClient ftpClient = FTPClient('example.com', user: 'myname', pass: 'mypass');

  // Connect to FTP Server
  ftpClient.connect();

  try {
    // Create directory
    ftpClient.makeDirectory('test');

    // Change directory
    ftpClient.changeDirectory('test');

    // Get current directory
    print(ftpClient.currentDirectory()); // => test

    // Change directory up
    ftpClient.changeDirectory('..');

    // Delete directory
    ftpClient.deleteDirectory('test');
  } finally {
    // Disconnect
    ftpClient.disconnect();
  }
}
