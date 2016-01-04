// Copyright (c) 2016, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library rewrites.example;

import 'package:rewrites/rewrites.dart';

main() => server()
  ..ignoreAll([r'^(\S+\.(json|html|js|dart|css|png))$',])
  ..proxy(r'/admin/(.*)',to: '/admin.html')
  ..proxy(r'(.*)', to: '/index.html')
  ..start('http://localhost:8080');
