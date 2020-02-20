import 'package:ftpclient/ftpclient.dart';

class FTPEntry {
  final String name;
  final DateTime modifyTime;
  final String persmission;
  final String type;
  final int size;
  final String unique;
  final String group;
  final String mode;
  final String owner;

  // Hide constructor
  FTPEntry._(this.name, this.modifyTime, this.persmission, this.type, this.size,
      this.unique, this.group, this.mode, this.owner);

  factory FTPEntry(final String sMlsdResponseLine) {
    if (sMlsdResponseLine == null || sMlsdResponseLine.trim().isEmpty) {
      throw FTPException('Can\'t create instance from empty information');
    }

    String _name;
    DateTime _modifyTime;
    String _persmission;
    String _type;
    int _size = 0;
    String _unique;
    String _group;
    String _mode;
    String _owner;

    // Split and trim line
    sMlsdResponseLine.trim().split(';').forEach((property) {
      final prop = property
          .split('=')
          .map((part) => part.trim())
          .toList(growable: false);

      if (prop.length == 1) {
        // Name
        _name = prop[0];
      } else {
        // Other attributes
        switch (prop[0].toLowerCase()) {
          case 'modify':
            final String date =
                prop[1].substring(0, 8) + 'T' + prop[1].substring(8);
            _modifyTime = DateTime.parse(date);
            break;
          case 'perm':
            _persmission = prop[1];
            break;
          case 'size':
            _size = int.parse(prop[1]);
            break;
          case 'type':
            _type = prop[1];
            break;
          case 'unique':
            _unique = prop[1];
            break;
          case 'unix.group':
            _group = prop[1];
            break;
          case 'unix.mode':
            _mode = prop[1];
            break;
          case 'unix.owner':
            _owner = prop[1];
            break;
          default:
            throw FTPException('Unknown FTPEntry property \'$property\'');
        }
      }
    });

    return FTPEntry._(
        _name,
        _modifyTime,
        _persmission,
        _type,
        _size,
        _unique,
        _group,
        _mode,
        _owner);
  }

  @override
  String toString() =>
      'name=$name;modifyTime=$modifyTime;permission=$persmission;type=$type;size=$size;unique=$unique;group=$group;mode=$mode;owner=$owner';
}
