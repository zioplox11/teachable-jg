module Teachable
  module Jg
    class Client

      # Define the same set of accessors as the Teachable module
      attr_accessor *Configuration::VALID_CONFIG_KEYS

      # self.base_uri "https://#{CREDENTIALS[:host]}/#{CREDENTIALS[:path]}/Accounts/#{CREDENTIALS[:account_id]}"


      def initialize(_options={})
        self.class.basic_auth(account_id, account_token)
      end

      def initialize(options={})
        # Merge the config values from the module and those passed
        # to the client.
        merged_options = Teachable::Jg.options.merge(options)

        # Copy the merged values to this client and ignore those
        # not part of our configuration
        Configuration::VALID_CONFIG_KEYS.each do |key|
          send("#{key}=", merged_options[key])
        end
      end

    end # Client
  end
end