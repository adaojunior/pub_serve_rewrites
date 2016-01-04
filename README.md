# Rewrites

> This library is highly experimental and its purpose is to be used during development.

> Feedback and PR's are welcome


## Why
To help `pub serve` to support apps using HTML5 pushState for navigation during development.

Rewrite uses pattern matching to check if a given URL will be ignored or if changed to a new destination URL.

## How to use
In the example bellow all `json|html|js|dart|css|png` will be ignored and the server proxied decide what will be served.

When the browser makes a request to eg: `/admin/dashboard` it will receive the content of `admin.html`.

All others requests that are not ignored or that matches with `/admin/(.*)` will be proxied to `index.html`.

`bin/dev_server.dart`

```

import 'package:rewrites/rewrites.dart';

main(){
  server()
  ..ignoreAll([
    r'^(\S+\.(json|html|js|dart|css|png))$',
  ])
  ..proxy('/admin/(.*)',to:'admin.html')
  ..proxy(r'(.*)',to:'/index.html')
  ..start('http://localhost:8080');
}
```

`pub run bin/dev_server.dart`

You also must start `pub serve` as it is still not integrated into this library yet,
it may change in the future.

The URL on `start(...)` is the proxied URL (pub serve) and by default the server you should use to access your app should be `localhost:8081`
