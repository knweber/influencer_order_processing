class CreateShopifyCache < ActiveRecord::Migration[5.1]
  def change

    create_table :shopify_orders, id: false do |t|
      t.bigint :id, null: false, primary_key: true
      t.bigint :app_id
      t.json :billing_address
      t.string :browser_ip
      t.boolean :buyer_accepts_marketing
      t.timestamp :cancelled_at
      t.string :cancel_reason
      t.string :cart_token
      t.bigint :checkout_id
      t.string :checkout_token
      t.timestamp :closed_at
      t.boolean :confirmed
      t.string :contact_email
      t.timestamp :created_at
      t.float :currency
      t.json :customer
      t.string :customer_locale
      t.bigint :device_id
      t.json :discount_codes
      t.string :email
      t.string :financial_status
      t.json :fulfillments
      t.string :fulfillment_status
      t.string :gateway
      t.string :landing_site
      t.string :landing_site_ref
      t.json :line_items
      t.bigint :location_id
      t.string :name
      t.text :note
      t.json :note_attributes
      t.integer :number
      t.integer :order_number
      t.string :order_status_url
      t.json :payment_gateway_names
      t.string :phone
      t.timestamp :processed_at
      t.string :processing_method
      t.string :reference
      t.string :referring_site
      t.json :refunds
      t.json :shipping_address
      t.json :shipping_lines
      t.string :source_identifier
      t.string :source_name
      t.string :source_url
      t.float :subtotal_price
      t.string :tags
      t.boolean :taxes_included
      t.json :tax_lines
      t.boolean :test
      t.string :token
      t.float :total_discounts
      t.float :total_line_items_price
      t.float :total_price
      t.float :total_price_usd
      t.float :total_tax
      t.integer :total_weight
      t.timestamp :updated_at
      t.bigint :user_id
      t.timestamp :sent_to_acs_at
    end

    create_table :shopify_products, id: false do |t|
      t.bigint :id, null: false, primary_key: true
      t.text :body_html
      t.timestamp :created_at
      t.string :handle
      t.json :image
      t.json :images
      t.json :options
      t.string :product_type
      t.timestamp :published_at
      t.string :published_scope
      t.string :tags
      t.string :template_suffix
      t.string :title
      t.string :metafields_global_title_tag
      t.string :metafields_global_description_tag
      t.timestamp :updated_at
      t.json :variants
      t.string :vendor
    end

    create_table :shopify_product_variants, id: false do |t|
      t.bigint :id, null: false, primary_key: true
      t.string :barcode
      t.float :compare_at_price
      t.timestamp :created_at
      t.string :fulfillment_service
      t.integer :grams
      t.bigint :image_id
      t.string :inventory_management
      t.string :inventory_policy
      t.integer :inventory_quantity
      t.integer :old_inventory_quantity
      t.integer :inventory_quantity_adjustment
      t.bigint :inventory_item_id
      t.boolean :requires_shipping
      t.json :metafield
      t.string :option1
      t.string :option2
      t.string :option3
      t.integer :position
      t.float :price
      t.bigint :product_id
      t.string :sku
      t.boolean :taxable
      t.string :title
      t.timestamp :updated_at
      t.integer :weight
      t.string :weight_unit
    end

    create_table :shopify_custom_collections, id: false do |t|
      t.bigint :id, null: false, primary_key: true
      t.text :body_html
      t.string :handle
      t.string :image
      t.json :metafield
      t.boolean :published
      t.timestamp :published_at
      t.string :published_scope
      t.string :sort_order
      t.string :template_suffix
      t.string :title
      t.timestamp :updated_at
    end

    create_table :shopify_collects, id: false do |t|
      t.bigint :id, null: false, primary_key: true
      t.bigint :collection_id
      t.timestamp :created_at
      t.boolean :featured
      t.integer :position
      t.bigint :product_id
      t.string :sort_value
      t.timestamp :updated_at
    end

  end
end
