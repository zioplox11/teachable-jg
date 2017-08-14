module Teachable
  module Jg
    module Configuration
      VALID_CONNECTION_KEYS         = [:method, :authorization_message, :authorized].freeze
      VALID_OPTIONS_KEYS            = [:format].freeze

      VALID_CONFIG_KEYS             = VALID_CONNECTION_KEYS + VALID_OPTIONS_KEYS

      DEFAULT_ENDPOINT              = 'http://secure.localhost.com:3000/users'
      DEFAULT_METHOD                = :post
      DEFAULT_USER_AGENT            = "Teachable API Ruby Gem #{Teachable::Jg::VERSION}".freeze
      DEFAULT_FORMAT                = :json
      DEFAULT_AUTHORIZED            = false
      DEFAULT_AUTHORIZATION_MESSAGE = ""

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
        self.authorized            = DEFAULT_AUTHORIZED
        self.authorization_message = DEFAULT_AUTHORIZATION_MESSAGE
      end

      def configure
        yield self
      end
    end # Configuration
  end
end