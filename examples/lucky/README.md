# lucky_world

Built with lucky v0.4.0

This is an example fcgi project written using [Lucky](https://luckyframework.org). Enjoy!
This project was created using the instructions [Installing Lucky](https://luckyframework.org/guides/installing/)

### Setting up the project

1. Follow the instructions [Installing Lucky](https://luckyframework.org/guides/installing/)
1. Generate a new lucky app.
1. Copy `.htaccess`, `dispatch.cr` from this example to root of new lucky project.
1. Update `shard.yml` to add the fcgi gem, this example has the fcgi gem in `shard.yml`.
1. Update `src/app.cr`, `src/your_app.cr` (`src/lucky_world.cr` in this example), and `src/server.cr`
1. Update `dispatch.cr` to require and use `src/your_app.cr` (`src/lucky_world.cr` in this example).
1. Run `shards install`
1. Use `make_compile_image.sh` to make a Docker image that compiles crystal using same Linux Dreamhost uses. You'll need docker for this part.
1. Create Dreamhost hosted domain using instructions in [README.md](https://github.com/blazerw/fcgi/blob/master/README.md)
1. Update and then use updated `remote_test.sh` to deploy. You should only need to change USERNAME and HOSTNAME.

### Learning Lucky

Lucky uses the [Crystal](https://crystal-lang.org) programming language. You can learn about Lucky from the [Lucky Guides](http://luckyframework.org/guides).
