library rewrites.src.pubserve;

import 'dart:io';
import 'dart:async' show Stream;

class PubServe {

  final String hostname;
  final int port;
  final String mode;
  final List<String> directories;
  final bool all;
  Process _process;

  PubServe({this.hostname, this.port, this.mode, this.directories, this.all: false});

  start() async {
    String executable = Platform.isWindows ? 'pub.bat' : 'pub';
    _process = await Process.start(executable, _args());
  }

  Stream<List<int>> get stdout => _process.stdout;

  _args() {
    List args = ["serve","--port",port.toString()];
    if(hostname != null)
      args.addAll(['--hostname',hostname]);
    if(mode != null)
      args.addAll(['--mode',mode]);
    if(all)
      args.add('--all');
    if(directories != null)
      args.add(directories.join(' '));
    return args;
  }
}
