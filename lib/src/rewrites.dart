// Copyright (c) 2016, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library rewrites.base;

import 'package:shelf/shelf_io.dart' as shelf;
import 'package:shelf/shelf.dart';
import 'package:shelf_proxy/shelf_proxy.dart' show proxyHandler;
import 'package:shelf/src/message.dart' show getBody;

const String DEFAULT_HOST = 'localhost';
const int DEFAULT_PORT = 8081;

class _Target {
  final RegExp regex;
  final String to;

  _Target(this.regex, this.to);
}

class Server {
  List<RegExp> _ignores = [];
  List<_Target> _proxies = [];
  final String host;
  final int port;

  Server({this.host: DEFAULT_HOST, this.port: DEFAULT_PORT});

  ignore(String target) => _ignores.add(new RegExp(target));

  proxy(String target, {String to}) =>
      _proxies.add(new _Target(new RegExp(target), to));

  ignoreAll(List<String> targets) => targets.forEach(ignore);

  proxyAll(List<String> targets, {String to}) =>
      targets.forEach((target) => proxy(target, to: to));

  start(String target) {
    shelf.serve(_handler(target), host, port).then((server) {
      print('Proxying at http://${server.address.host}:${server.port}');
    });
  }

  Handler _handler(String target) {
    Handler handler = proxyHandler(target);
    return (Request request) {
      print('[${request.method}] ${request.url.path}');

      String path = "/${request.url.path}";
      if (_isIgnored(path)) return handler(request);

      _Target target = _hasProxyMatch(path);

      if (target != null) {
        request =
            _applyUri(request, _applyPath(request.requestedUri, target.to));
      }

      return handler(request);
    };
  }

  _hasProxyMatch(String path) {
    _Target target = _proxies.firstWhere((_Target target) {
      return target.regex.hasMatch(path);
    }, orElse: () => null);

    return target;
  }

  bool _isIgnored(String path) {
    var match = _ignores.firstWhere((RegExp regex) {
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
