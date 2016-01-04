// Copyright (c) 2016, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library rewrites;

import 'src/rewrites.dart';
export 'src/rewrites.dart';

Server server({String host, int port}) {
  return new Server(host: host ?? DEFAULT_HOST, port: port ?? DEFAULT_PORT);
}
