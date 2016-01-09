library rewrites.bin;

import 'dart:io';
import 'package:args/args.dart';
import 'package:rewrites/rewrites.dart';

main(List<String> args) async {

  ArgParser parser = _createArgsParser();
  ArgResults results = parser.parse(args);

  if (results['help']) {
    print(parser.usage);
    exit(1);
  }

  ProxyServer.start(
      host: results['hostname'],
      port: int.parse(results['port']),
      rules: parseRewriteFile('rewrites.yaml'),
      pubserve: new PubServe(
          hostname:'localhost',
          port: int.parse(results['proxied-server-port']),
          directories: results.rest.isEmpty ? ['web'] : results.rest,
          mode: results['mode'],
          all: results['all']
      )
  );
}

ArgParser _createArgsParser() {

  ArgParser parser = new ArgParser()
    ..addOption('port',
        defaultsTo: DEFAULT_PORT.toString(),
        valueHelp: 'port',
        help: 'The port to listen on.')
    ..addOption('hostname',
        defaultsTo: DEFAULT_HOST.toString(),
        valueHelp: 'hostname',
        help: 'The hostname to listen on (defaults to "localhost").')
    ..addOption('mode', allowed: ['debug', 'release'],
        valueHelp: 'mode',
        help: 'Mode to run transformers in.',
        defaultsTo: 'debug'
    )
    ..addFlag('all',
        help: 'Use all default source directories.',
        defaultsTo: false)
    ..addOption('proxied-server-port',
        defaultsTo: '7345',
        valueHelp: 'proxied-server-port',
        help: 'The port used to run the proxied pub serve.')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Displays the help.');

  return parser;
}
