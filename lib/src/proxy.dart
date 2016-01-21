// Copyright (c) 2016, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library rewrites.src.proxy;

import 'package:shelf/shelf_io.dart' as shelf;
import 'package:shelf/shelf.dart';
import 'package:shelf_proxy/shelf_proxy.dart' show proxyHandler;
import 'package:shelf/src/message.dart' show getBody;
import 'pubserve.dart';
import 'rules.dart';
import 'dart:convert';

const String DEFAULT_HOST = 'localhost';
const int DEFAULT_PORT = 8080;

class ProxyServer {

  final String host;
  final int port;
  final RewriteRules rules;
  final PubServe pubserve;

  ProxyServer._(this.host,this.port,this.rules,this.pubserve);

  static start({String host,int port,RewriteRules rules,PubServe pubserve}) async {
    ProxyServer server = new ProxyServer._(host,port,rules,pubserve);
    await pubserve.start();
    server._handlePubServeOutput();
    server._start();
  }

  _handlePubServeOutput(){
    pubserve.stdout.transform(UTF8.decoder).listen(_onData);
  }

  _onData(String data){
    data = data.trim();
    data = data.replaceAll('http://${pubserve.hostname}:${pubserve.port}','http://${host}:${port}');
    print(data);
  }

  _start(){
    Uri uri = new Uri(scheme:'http',host: pubserve.hostname,port: pubserve.port);
    shelf.serve(_handler(uri.toString()), host, port).then((server) {
      print('Proxying at http://${server.address.host}:${server.port}');
    });
  }

  Handler _handler(String target) {
    Handler handler = proxyHandler(target);
    return (Request request) {
      String path = "/${request.url.path}";

      if (_isIgnored(path))
        return handler(request);

      RewriteRule target = _rewriteMatch(path);

      if (target != null) {
        request =
            _applyUri(request, _applyPath(request.requestedUri, target.to));
      }

      return handler(request);
    };
  }

  RewriteRule _rewriteMatch(String path) {
    RewriteRule rule = rules.rules.firstWhere((RewriteRule target) {
      return target.pattern.hasMatch(path);
    }, orElse: () => null);

    return rule;
  }

  bool _isIgnored(String path) {
    var match = rules.ignored.firstWhere((RegExp regex) {
      return regex.hasMatch(path);
    }, orElse: () => null);

    return (match != null);
  }

  Uri _applyPath(Uri uri, String path) {
    return new Uri(
        scheme: uri.scheme,
        userInfo: uri.userInfo,
        host: uri.host,
        port: uri.port,
        path: path,
        query: uri.query,
        fragment: uri.fragment);
  }

  Request _applyUri(Request request, Uri uri) {
    return request = new Request(request.method, uri,
        protocolVersion: request.protocolVersion,
        headers: request.headers,
        handlerPath: request.handlerPath,
        body: getBody(request),
        encoding: request.encoding,
        context: request.context);
  }
}
