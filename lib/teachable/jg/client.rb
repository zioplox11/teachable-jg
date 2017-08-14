require "httparty"

module Teachable
  module Jg
    class Client
      include HTTParty

      format :json

      SUCCESSFUL_LOGIN = {"success"=>true, "login"=>"verified"}

      # Define the same set of accessors as the Teachable module
      attr_accessor *Configuration::VALID_CONFIG_KEYS

      # curl -X POST -d '{ "user": { "email": "dev-8@example.com", "password": "password" }}' localhost:3000/users/sign_in.json -i -H "Accept: application/json" -H "Content-Type: application/json"
      def initialize(options={})
        # # Merge the config values from the module and those passed
        # # to the client.
        merged_options = Teachable::Jg.options.merge(options)

        # Copy the merged values to this client and ignore those
        # not part of our configuration
        Configuration::VALID_CONFIG_KEYS.each do |key|
          send("#{key}=", merged_options[key])
        end

        @authorization_message = authorize(options)
      end

      def authorize(options={})

        query = {user: {
          "email"     => options[:email],
          "password"      => options[:password],
        }}

        headers = {
          "Accept"  => "application/json",
          "Content-Type" => "application/json"
        }

        resp = HTTParty.post(
          self.endpoint,
          query: query,
          headers: headers
        )

        body = process_body(resp.body)

        self.authorized = true if body == SUCCESSFUL_LOGIN

        return body
      end

      def process_body(body)
        if body.is_a?(String)
          JSON.parse(body)
        else
          {"success"=>false, "login"=>"no json response"}
        end
      end

    end # Client
  end
end

