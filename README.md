A small and simple FTP Client library for Dart Native.

![Pub Version](https://img.shields.io/pub/v/ftpclient)
![GitHub](https://img.shields.io/github/license/Nexific/dart_ftpclient)
[![Build Status](https://travis-ci.org/Nexific/dart_ftpclient.svg?branch=master)](https://travis-ci.org/Nexific/dart_ftpclient)
![GitHub issues](https://img.shields.io/github/issues/Nexific/dart_ftpclient)

## Usage

Add the following dependency to the pubspec.yaml

**Stable**

```yaml
dependencies:
  ftpclient: ^0.5.0
```

**Development**

```yaml
dependencies:
  ftpclient: ^0.6.0
```

NOTE: This version is not yet available on pub.dev

**How to use the FTP Client:**

```dart
import 'dart:io';
import 'package:ftpclient/ftpclient.dart';

main() {
  FTPClient ftpClient = FTPClient('example.com', user: 'myname', pass: 'mypass');
  ftpClient.connect();
  ftpClient.uploadFile(File('test.zip'));
  ftpClient.disconnect();
}
```

For a complete example, see the examples in the [example folder](example/)!
