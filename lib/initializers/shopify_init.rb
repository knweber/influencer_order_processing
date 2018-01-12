ShopifyAPI::Base.site = "https://#{ENV['SHOPIFY_API_KEY']}:#{ENV['SHOPIFY_PASSWORD']}@#{ENV['SHOPIFY_SHOP_NAME']}.myshopify.com/admin"

module ShopifyAPI
  class Base
    include Async

    def self.perform(command, *args)
      ShopifyAPI.throttle { send(command, *args) }
    end
  end
end
