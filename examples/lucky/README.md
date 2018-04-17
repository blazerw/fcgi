# lucky_world

Built with lucky v0.4.0

This is an example fcgi project written using [Lucky](https://luckyframework.org). Enjoy!
This project was created using the instructions [Installing Lucky][https://luckyframework.org/guides/installing/]

### Setting up the project

1. Follow the instructions [Installing Lucky][https://luckyframework.org/guides/installing/]
1. Copy `.htaccess`, `dispatch.cr`
1. Update `shard.yml` to add the fcgi gem.
1. Update `src/app.cr`, `src/your_app.cr` (`src/lucky_world.cr` in this example), and `src/server.cr`
1. Update `dispatch.cr` to require and user `src/your_app.cr` (`src/lucky_world.cr` in this example).

### Learning Lucky

Lucky uses the [Crystal](https://crystal-lang.org) programming language. You can learn about Lucky from the [Lucky Guides](http://luckyframework.org/guides).
