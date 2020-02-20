class FTPEntry {
  String _name;
  DateTime _modifyTime;
  String _persmission;
  String _type;
  int _size = 0;
  String _unique;
  String _group;
  String _mode;
  String _owner;

  // Hide constructor
  FTPEntry._();

  factory FTPEntry(final String sMlsdResponseLine) {
    if (sMlsdResponseLine == null || sMlsdResponseLine.trim().isEmpty) {
      throw 'Can\'t create instance from empty information';
    }

    FTPEntry entry = FTPEntry._();

    // Split and trim line
    sMlsdResponseLine.trim().split(';').forEach((property) {
      final prop = property
          .split('=')
          .map((part) => part.trim())
          .toList(growable: false);

      if (prop.length == 1) {
        // Name
        entry._name = prop[0];
      } else {
        // Other attributes
        switch (prop[0].toLowerCase()) {
          case 'modify':
            final String date =
                prop[1].substring(0, 8) + 'T' + prop[1].substring(8);
            entry._modifyTime = DateTime.parse(date);
            break;
          case 'perm':
            entry._persmission = prop[1];
            break;
          case 'size':
            entry._size = int.parse(prop[1]);
            break;
          case 'type':
            entry._type = prop[1];
            break;
          case 'unique':
            entry._unique = prop[1];
            break;
          case 'unix.group':
            entry._group = prop[1];
            break;
          case 'unix.mode':
            entry._mode = prop[1];
            break;
          case 'unix.owner':
            entry._owner = prop[1];
            break;
          default:
            throw 'Unknown FTPEntry property \'$property\'';
        }
      }
    });

    return entry;
  }

  @override
  String toString() =>
      'name=$_name;modifyTime=$_modifyTime;permission=$_persmission;type=$_type;unique=$_unique;group=$_group;mode=$_mode;owner=$_owner';
}
