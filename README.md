# Influencer Order Processing
Provides utilities to generate and track orders for influencers.

## Usage

### With Docker

Build the image:
```shell
git clone https://github.com/knweber/influencer_order_processing.git
cd influencer_order_processing
docker-compose build
```

Create a `.env` file in the project root. See the [Environment
section](#Environment) below.

Setup the database:
```shell
docker-compose run --rm worker rake db:create db:migrate
```

Refresh the cache:
```shell
# pull everything
docker-compose run --rm worker rake pull:all

# pull individually
docker-compose run --rm worker rake pull:orders
docker-compose run --rm worker rake pull:custom_collections
docker-compose run --rm worker rake pull:collects
docker-compose run --rm worker rake pull:products
```

Launch the application:
```
docker-compose up -d
```

Stop the application:
```
docker-compose down
```

View logs:
```
docker-compose logs -f
```

## Environment Variables
The following environment variables are required:

```
REDIS_URL=redis://...
RACK_ENV=production
SHOPIFY_API_KEY=
SHOPIFY_SHARED_SECRET=
SHOPIFY_PASSWORD=
SHOPIFY_SHOP_NAME=ellieactive
DATABASE_URL=postgres://...
SENDGRID_API_KEY=
FTP_HOST=
FTP_USER=
FTP_PASSWORD=
OUR_EMAIL=no-reply@ellie.com
AUTH_USERNAME=
AUTH_PASSWORD=
AUTH_SESSION_ID=
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake test` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/[USERNAME]/shopify_cache.

## License

The gem is available as open source under the terms of the [MIT
License](https://opensource.org/licenses/MIT).
