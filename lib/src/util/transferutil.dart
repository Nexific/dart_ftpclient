import '../ftpsocket.dart';
import '../transfermode.dart';

class TransferUtil {
  /// Set the Transfer mode on [socket] to [mode]
  static void setTransferMode(FTPSocket socket, TransferMode mode) {
    switch (mode) {
      case TransferMode.ascii:
        // Set to ASCII mode
        socket.sendCommand('TYPE A');
        socket.readResponse();
        break;
      case TransferMode.binary:
        // Set to BINARY mode
        socket.sendCommand('TYPE I');
        socket.readResponse();
        break;
      default:
        break;
    }
  }

  /// Parse the Passive Mode Port from the Servers [sResponse]
  static int parsePort(String sResponse) {
    int iParOpen = sResponse.indexOf('(');
    int iParClose = sResponse.indexOf(')');

    String sParameters = sResponse.substring(iParOpen + 1, iParClose);
    List<String> lstParameters = sParameters.split(',');

    int iPort1 = int.parse(lstParameters[lstParameters.length - 2]);
    int iPort2 = int.parse(lstParameters[lstParameters.length - 1]);

    return (iPort1 * 256) + iPort2;
  }
}
