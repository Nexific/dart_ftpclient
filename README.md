A small and simple FTP Client library for Dart Native.

[![Build Status](https://travis-ci.org/Nexific/dart_ftpclient.svg?branch=master)](https://travis-ci.org/Nexific/dart_ftpclient)

## Usage

Add the following dependency to the pubspec.yaml

```yaml
dependencies:
  ftpclient: ^0.3.0
```

How to use the FTP Client:

```dart
import 'dart:io';
import 'package:ftpclient/ftpclient.dart';

main() {
  FTPClient ftpClient = new FTPClient('example.com', user: 'myname', pass: 'mypass');
  ftpClient.connect();
  ftpClient.uploadFile(new File('test.zip'));
  ftpClient.disconnect();
}
```

For a complete example, see the examples in the example folder!
