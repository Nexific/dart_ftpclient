import 'package:ftpclient/ftpclient.dart';

void main() {
  // Create Connection
  FTPClient ftpClient = FTPClient('example.com', user: 'myname', pass: 'mypass');

  // Connect to FTP Server
  ftpClient.connect();

  try {
    // List directory content
    print(ftpClient.listDirectoryContent());
  } finally {
    // Disconnect
    ftpClient.disconnect();
  }
}
