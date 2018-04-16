# fcgi

`fcgi` is an implmentation of the FastCGI specification ( https://github.com/fast-cgi/spec/blob/master/spec.md )  

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  fcgi:
    github: blazerw/fcgi
```

## Usage

```crystal
require "fcgi"
```

Basically, you create an app using your favorite Crystal framework (Kemal, Amber, and coming soon, Lucky). Figure out what's needed to boot your app and framework.
See `examples` to get started.  These examples work on Dreamhost slices ( https://www.dreamhost.com ) and require a certain configuration. Current configuration:
```
Domain to host:                    mysubdomain.mydomain.com
Do you want the www in your URL?:  Remove WWW
Run this domain under the user:    username
Web Directory:                     /home/username/mysubdomain.mydomain.com
PHP Mode:                          PHP 7.0 FastCGI # Yes, PHP Mode.
Automatically upgrade PHP:         true
HTTPS:                             true
Extra Web Security?:               false
Passenger:                         false
Enable CloudFlare on this domain?: false
Google Apps:                       false
```

## Development

TODO List:
1. Write some tests (steal fcgi data from verbose logs)
2. Kill verbose logs
3. Switch logging to a `Logger` from lazy `puts`ing around.

## Contributing

1. Fork it ( https://github.com/blazerw/fcgi/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [[blazerw]](https://github.com/[your-github-name]) Randy Wilson - creator, maintainer
