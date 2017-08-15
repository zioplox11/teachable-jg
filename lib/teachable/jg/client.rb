require "httparty"

module Teachable
  module Jg
    class Client
      include HTTParty

      format :json

      # SUCCESSFUL_LOGIN = {"success"=>true, "login"=>"verified"}
      # SUCCESSFUL_REGISTRATION = {"success"=>true, "registration"=>"verified"}

      # Define the same set of accessors as the Teachable module
      attr_accessor *Teachable::Jg::Configuration::VALID_CONFIG_KEYS
      attr_accessor :endpoint, :authorized

      # curl -X POST -d '{ "user": { "email": "dev-8@example.com", "password": "password" }}' localhost:3000/users/sign_in.json -i -H "Accept: application/json" -H "Content-Type: application/json"
      def initialize(options={})
        merged_options = Teachable::Jg.options.merge(options)

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

          self.delivered = true if body["success"]
          self.authorized = true if body["login"] == "verified"

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

      def get_user_info(path, options)
        user_headers = headers.reject {|key| key == "Accept" }

        query = {
          user_email: options[:user_email],
          user_token: options[:user_token]
        }

        resp = HTTParty.get(
          path,
          query: query,
          headers: user_headers
        )

        if resp.code == 200
          body = process_body(resp.body)
          self.delivered = true if body["success"]
          return body
        else
          return resp.code
        end
      end

      def user_info(options={})
        if authorized
          path = options[:path] || Teachable::Jg::Configuration::CURRENT_USER_ENDPOINT
          if options[:user_email] && !options[:user_email].nil? && options[:user_token] && !options[:user_token].nil?
            resp = get_user_info(path, options)
          else
            self.delivered = false
            {"success"=>false, "user_info"=>"missing or invalid params"}
          end
        else
          self.delivered = false
          {"success"=>false, "login"=>"failed to authorize"}
        end
      end

      def post_to_orders(path, options)
        query = {order: {
          "total"                => options[:total],
          "total_quantity"       => options[:total_quantity],
          "email"                => options[:email],
          "special_instructions" => options[:special_instructions]
        }}

        path_with_params = path + "?user_email=#{options[:user_email]}&user_token=#{options[:user_token]}"

        resp = HTTParty.post(
          path_with_params,
          query: query,
          headers: headers
        )

        if resp.code == 200
          body = process_body(resp.body)
          self.delivered = true if body["success"]
          return body
        else
          return resp.code
        end
      end

      def create_order(options)
        if authorized
          path = options[:path] || Teachable::Jg::Configuration::ORDERS_ENDPOINT
          if options[:total] && !options[:total].nil? &&
            options[:total_quantity] && !options[:total_quantity].nil? &&
            options[:email] && !options[:email].nil?
            resp = post_to_orders(path, options)
          else
            self.delivered = false
            {"success"=>false, "create_order"=>"missing or invalid params"}
          end
        else
          self.delivered = false
          {"success"=>false, "login"=>"failed to authorize"}
        end

      end

    end # Client
  end
end

