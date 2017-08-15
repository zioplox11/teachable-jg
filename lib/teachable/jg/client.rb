require "httparty"

module Teachable
  module Jg
    class Client
      include HTTParty

      format :json

      attr_accessor *Teachable::Jg::Configuration::VALID_CONFIG_KEYS
      attr_accessor :endpoint, :authorized

      def initialize(options={})
        merged_options = Teachable::Jg.options.merge(options)

        Teachable::Jg::Configuration::VALID_CONFIG_KEYS.each do |key|
          send("#{key}=", merged_options[key])
        end

        @endpoint = Teachable::Jg::Configuration::DEFAULT_ENDPOINT
        @status_message = confirm_status(options)
      end

      def user_info(options={})
        if authorized
          path = Teachable::Jg::Configuration::CURRENT_USER_ENDPOINT
          if has_required_attributes?(options, :user_email, :user_token)
            resp = get(path, options)
          else
            self.delivered = false
            {"success"=>false, "user_info"=>"missing or invalid params"}
          end
        else
          self.delivered = false
          {"success"=>false, "login"=>"failed to authorize"}
        end
      end

      def get(path, options)
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

      def post_to_users(options)
        path = endpoint + build_path(options[:registration])

        query = {user: {
          "email"                 => options[:email],
          "password"              => options[:password],
          "password_confirmation" => options[:password_confirmation]
        }}

        resp = HTTParty.post(
          path,
          query: query,
          headers: headers
        )
      end

      def create_order(options)
        if authorized
          path = Teachable::Jg::Configuration::ORDERS_ENDPOINT
          if has_required_attributes?(options, :total, :total_quantity, :email, :user_email, :user_token)
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

      def orders(options)
        if authorized
          path = Teachable::Jg::Configuration::ORDERS_ENDPOINT
          if has_required_attributes?(options, :user_email, :user_token)
            resp = get(path, options)
          else
            self.delivered = false
            {"success"=>false, "get_orders"=>"missing or invalid params"}
          end
        else
          self.delivered = false
          {"success"=>false, "login"=>"failed to authorize"}
        end
      end

      def delete_order(options)
        if authorized
          path = Teachable::Jg::Configuration::ORDERS_ENDPOINT
          if has_required_attributes?(options, :order_id, :user_email, :user_token)
            resp = destroy_order(path, options)
          else
            self.delivered = false
            {"success"=>false, "delete_order"=>"missing or invalid params"}
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

      def destroy_order(path, options)
        path_with_params = path + "/#{options[:order_id]}?user_email=#{options[:user_email]}&user_token=#{options[:user_token]}"

        resp = HTTParty.delete(
          path_with_params,
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

      def build_path(registration)
        registration ? "/register" : "/sign-in"
      end

      def confirm_status(options={})
        if has_required_attributes?(options, :email, :password)

          resp = post_to_users(options)

          if resp.code == 200
            body = process_body(resp.body)

            self.delivered = true if body["success"]
            self.authorized = true if body["login"] == "verified"

            return body
          else
            return resp.code
          end
        else
          self.delivered = false
          {"success"=>false, "user_info"=>"missing or invalid params"}
        end
      end

      def process_body(body)
        if body.is_a?(String)
          JSON.parse(body)
        else
          {"success"=>false, "login"=>"no json response"}
        end
      end

      def has_required_attributes?(options, *attributes)
        attributes << :password_confirmation if options[:registration]

        return false if attributes.detect do |attr|
          !(options.has_key?(attr) && !options[attr].nil?)
        end

        true
      end
    end # Client
  end
end

