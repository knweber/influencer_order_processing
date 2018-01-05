# ShopifyCache

Provides rake tasks to cache Shopify API entities locally.

## Usage

### With Docker

Build the image:
```shell
git clone https://github.com/r-bar/fambrands_shopify_cache.git
cd fambrands_shopify_cache
docker build -t shopify_cache .
```

Run the migration:
```shell
docker run --rm --env-file .env shopify_cache rake db:migrate
```

Refresh the cache:
```shell
docker run --rm --env-file .env shopify_cache rake pull_orders
docker run --rm --env-file .env shopify_cache rake pull_custom_collections
docker run --rm --env-file .env shopify_cache rake pull_collects
docker run --rm --env-file .env shopify_cache rake pull_products
```

## Environment Variables


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/shopify_cache.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
