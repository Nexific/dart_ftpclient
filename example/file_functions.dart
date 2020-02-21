import 'package:ftpclient/ftpclient.dart';

void main() {
  // Create Connection
  FTPClient ftpClient = FTPClient('example.com', user: 'myname', pass: 'mypass');

  // Connect to FTP Server
  ftpClient.connect();

  try {
    // Rename a file
    ftpClient.rename('test1', 'test2');

    // Delete a file
    ftpClient.deleteFile('test2');
  } finally {
    // Disconnect
    ftpClient.disconnect();
  }
}
