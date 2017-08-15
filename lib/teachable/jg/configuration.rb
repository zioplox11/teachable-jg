module Teachable
  module Jg
    module Configuration
      VALID_CONNECTION_KEYS  = [:method, :status_message, :delivered].freeze
      VALID_OPTIONS_KEYS     = [:format, :headers, :authorized].freeze

      VALID_CONFIG_KEYS      = VALID_CONNECTION_KEYS + VALID_OPTIONS_KEYS

      DEFAULT_ENDPOINT       = 'http://secure.localhost.com:3000/users'
      CURRENT_USER_ENDPOINT  = "http://secure.localhost.com:3000/api/users/current_user/edit"
      ORDERS_ENDPOINT        = "http://secure.localhost.com:3000/api/orders"

      DEFAULT_METHOD         = :post
      DEFAULT_USER_AGENT     = "Teachable API Ruby Gem #{Teachable::Jg::VERSION}".freeze
      DEFAULT_FORMAT         = :json
      DEFAULT_DELIVERED      = false
      DEFAULT_AUTHORIZED     = false
      DEFAULT_HEADERS        = { "Content-Type"  => "application/json",
                                  "Accept"       => "application/json" }
      DEFAULT_STATUS_MESSAGE = ""


      # Build accessor methods for every config options so we can do this, for example:
      #   Teachable::Jg.format = :xml
      attr_accessor *VALID_CONFIG_KEYS

      # Make sure we have the default values set when we get 'extended'
      def self.extended(base)
        base.reset
      end

      def options
        Hash[ * VALID_CONFIG_KEYS.map do |key|
          self.reset
          [key, send(key)]
        end.flatten ]
      end

      def reset
        self.method                = DEFAULT_METHOD
        self.format                = DEFAULT_FORMAT
        self.delivered             = DEFAULT_DELIVERED
        self.status_message        = DEFAULT_STATUS_MESSAGE
        self.headers               = DEFAULT_HEADERS
        self.authorized            = DEFAULT_AUTHORIZED
      end

      def configure
        yield self
      end
    end # Configuration
  end
end