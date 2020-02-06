import 'debuglog.dart';

class PrintLog implements DebugLog {
  @override
  void log(String sMessage) {
    print('[${_getTimestamp()}] $sMessage');
  }

  String _getTimestamp() {
    DateTime now = DateTime.now();

    return '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year.toString()} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}.'
        '${now.millisecond.toString().padLeft(3, '0')}';
  }
}
