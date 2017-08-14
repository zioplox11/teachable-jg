require "httparty"

module Teachable
  module Jg
    class Client
      include HTTParty

      format :json

      SUCCESSFUL_LOGIN = {"success"=>true, "login"=>"verified"}
      SUCCESSFUL_REGISTRATION = {"success"=>true, "registration"=>"verified"}

      # Define the same set of accessors as the Teachable module
      attr_accessor *Teachable::Jg::Configuration::VALID_CONFIG_KEYS
      attr_accessor :endpoint

      # curl -X POST -d '{ "user": { "email": "dev-8@example.com", "password": "password" }}' localhost:3000/users/sign_in.json -i -H "Accept: application/json" -H "Content-Type: application/json"
      def initialize(options={})
        # # Merge the config values from the module and those passed
        # # to the client.

        merged_options = Teachable::Jg.options.merge(options)

        # Copy the merged values to this client and ignore those
        # not part of our configuration
        Teachable::Jg::Configuration::VALID_CONFIG_KEYS.each do |key|
          send("#{key}=", merged_options[key])
        end

        @endpoint = Teachable::Jg::Configuration::DEFAULT_ENDPOINT
        @status_message = confirm_status(options)
      end

      def build_path(registration)
        registration ? "/register" : "/sign-in"
      end

      def post_to_users_endpoint(options)
        path = endpoint + build_path(options[:registration])

        query = {user: {
          "email"     => options[:email],
          "password"      => options[:password],
          "password_confirmation"      => options[:password_confirmation]
        }}

        resp = HTTParty.post(
          path,
          query: query,
          headers: headers
        )
      end

      def confirm_status(options={})
        resp = post_to_users_endpoint(options)

        if resp.code == 200
          body = process_body(resp.body)

          self.confirmed = true if body["success"]

          return body
        else
          return resp.code
        end
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

