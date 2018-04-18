# amber_world

This is an example project powered by [Amber Framework](https://amberframework.org/) and Crystal [FCGI](https://github.com/blazerw/fcgi).

## Installation

1. Install Amber and prerequisites.
1. Generate an app: `amber new amber_world -d mysql -t ecr -m granite`
1. Copy `.htaccess`, `dispatch.cr` from this example to root of new lucky project.
1. Update `shard.yml` to add the fcgi gem, this example has the fcgi gem in `shard.yml`.
1. Update `src/your_app.cr` (`src/amber_world.cr` in this example)
1. Update `dispatch.cr` to require and use `src/your_app.cr` (`AmberWorld.new` and `src/amber_world.cr` in this example).
1. Run `shards install`
1. Use `make_compile_image.sh` to make a Docker image that compiles crystal using same Linux Dreamhost uses. You'll need docker for this part.
1. Create Dreamhost hosted domain using instructions in [README.md](https://github.com/blazerw/fcgi/blob/master/README.md)
1. Update and then use updated `remote_test.sh` to deploy. You should only need to change USERNAME and HOSTNAME.


# Below here is the normal Amber generated README.md most of it still applies.
However, I've only tested running in development mode with `amber watch`.

## Usage

To setup your database edit `database_url` inside `config/environments/development.yml` file.

To edit your production settings use `amber encrypt`. [See encrypt command guide](https://github.com/amberframework/online-docs/blob/master/getting-started/cli/encrypt.md#encrypt-command)

To run amber server in a **development** enviroment:

```
amber db create migrate
amber watch
```

To build and run a **production** release:

1. Add an environment variable `AMBER_ENV` with a value of `production`
2. Run these commands:

```
npm run release
amber db create migrate
shards build --production
./bin/amber_world
```

## Docker Compose

To set up the database and launch the server:

```
docker-compose up -d
```

To view the logs:

```
docker-compose logs -f
```

> **Note:** The Docker images are compatible with Heroku.

## Contributing

1. Fork it ( https://github.com/your-github-user/amber_world/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [your-github-user](https://github.com/your-github-user) Randy Wilson - creator, maintainer
