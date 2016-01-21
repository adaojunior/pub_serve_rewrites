library rewrites.src.parser;

import 'rules.dart';
import 'package:yaml/yaml.dart';
import 'dart:io';

RewriteRules parseRewriteFile(String file) {
  RewriteFileParser parse = new RewriteFileParser(file);
  return parse.rules;
}

class RewriteFileParser {
  RewriteRules rules = new RewriteRules();

  final String filename;

  RewriteFileParser(this.filename){
    _parse();
  }

  _parse() async {
    File file = new File(filename);
    String content = file.readAsStringSync();
    YamlMap document = loadYaml(content);
    _parseIgnore(document);
    _parseRules(document);
  }

  _parseIgnore(YamlMap document) {
    if (!document.containsKey('ignore')) return;
    else if (document['ignore']
    is! List) throw "[ignore] field must be an list";

    document['ignore'].forEach((v) => rules.ignore(v.toString()));
  }

  _parseRules(YamlMap document) {
    if (!document.nodes.containsKey('rewrites')) return;
    else if (document['rewrites']
    is! List) throw "[rewrites] field must be an list";

    document['rewrites'].forEach(_addRules);
  }

  _addRules(Map node) {
    if (!node.containsKey('rewrite') || !node.containsKey('to')) {
      throw "[${filename}]: invalid schema";
    }

    rules.rewrite(node['rewrite'].toString(), node['to'].toString());
  }
}
