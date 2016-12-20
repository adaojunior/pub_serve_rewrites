# PubServe Rewrites

> This library is highly experimental and its purpose is to be used during development.

> Feedback and PR's are welcome

## Why
To help `pub serve` to support apps using HTML5 pushState for navigation during development.

Rewrite uses pattern matching to check if a given URL will be ignored or if changed to a new destination URL.

## Install

```
> pub global activate --source git https://github.com/adaojunior/pub_serve_rewrites.git
```
## How to use
Create a `rewrites.yaml` file in the root of your project (same folder as your `pubspec.yaml`) and setup your rewrite rules.

In the example bellow all `json|html|js|dart|css|png` will be ignored and the server proxied decide what will be served.

When the browser makes a request to eg: `/admin/dashboard` it will receive the content of `admin.html`.

All others requests that are not ignored or that matches with `/admin/(.*)` will be proxied to `index.html`.

```yaml
# rewrites.yaml
ignore:
- \.(json|html|js|dart|css|png)$
rewrites:
- rewrite: /admin/(.*)
  to: admin.html
- rewrite: (.*)
  to: index.html
```

Run the following code in your terminal
```
> rewrites
```
If you need help run the command bellow
```
> rewrites --help
```
