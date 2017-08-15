require 'spec_helper'

describe Teachable::Jg::Client do

  before do
    @keys = Teachable::Jg::Configuration::VALID_CONFIG_KEYS
  end

  describe 'with module configuration' do
    before do
      Teachable::Jg.configure do |config|
        @keys.each do |key|
          config.send("#{key}=", key)
        end
      end
    end

    after do
      Teachable::Jg.reset
    end

    it "inherits module configuration" do
      api = Teachable::Jg::Client.new
      @keys.each do |key|
        expect(api.send(key)).to eq(Teachable::Jg.send(key)) unless key == :status_message
      end
    end

    describe 'with class configuration' do
      before do
        @config = {
          format:                'of',
          endpoint:              'ep',
          method:                'hm',
          delivered:             'zy',
          status_message:        'nn',
          authorized:            'am',
          headers:               {'qn'=>'ff'}
        }
      end

      it 'overrides module configuration' do
        api = Teachable::Jg::Client.new(@config)
        @keys.each do |key|
          expect(api.send(key)).to eq(@config[key]) unless key == :status_message
        end
      end

      it 'overrides module configuration after' do
        api = Teachable::Jg::Client.new

        @config.each do |key, value|
          api.send("#{key}=", value)
        end

        @keys.each do |key|
          expect(api.send("#{key}")).to eq(@config[key]) unless key == :status_message
        end
      end
    end

    describe 'login and authorization via .confirm_status' do
      let(:authorized)   { {"success" =>true, "login"=>"verified"} }
      let(:unrecognized) { {"success" =>true, "login"=>"unrecognized or malformed"} }
      let(:invalid)      { {"success" =>false, "login"=>"missing or invalid" } }

      let(:login_client) { Teachable::Jg::Client.new }

      context "has user param" do
        it 'verifies login as successful' do
          VCR.use_cassette('teachable_client_successful') do
            expect(login_client.confirm_status(email: "dev-8@example.com", password: "password")).to eq(authorized)
            expect(login_client.delivered).to be_truthy
            expect(login_client.authorized).to be_truthy
          end
        end

        it 'does not verify login if password incorrect' do
          VCR.use_cassette('teachable_client_successful_malformed1') do
            expect(login_client.confirm_status(email: "unregistered@example.com", password: "password")).to eq(unrecognized)
            expect(login_client.delivered).to be_truthy
            expect(login_client.authorized).to be_falsey
          end
        end

        it 'does not verify login if email is unrecognized' do
          VCR.use_cassette('teachable_client_successful_malformed2') do
            expect(login_client.confirm_status(email: "dev-8@example.com", password: "smashword")).to eq(unrecognized)
            expect(login_client.delivered).to be_truthy
            expect(login_client.authorized).to be_falsey
          end
        end
      end

      context "without user param" do
        it 'does not verify login' do
          VCR.use_cassette('teachable_client_unsuccessful') do
            expect(login_client.confirm_status(random: "dev-8@example.com", alsorandom: "password")).to eq(invalid)
            expect(login_client.delivered).to be_falsey
            expect(login_client.authorized).to be_falsey
          end
        end
      end
    end

    describe 'user registration via .confirm_status' do
      let(:registered)         { {"success" =>true, "registration"=>"verified"} }
      let(:already_registered) { {"success" =>true, "registration"=>"already_registered"} }
      let(:unregistered)       { {"success" =>true, "registration"=>"unrecognized or malformed"} }
      let(:invalid)            { {"success" =>false, "registration"=>"missing or invalid" } }

      context ".authorized" do
        it "is false for authorization" do
          VCR.use_cassette('teachable_client_successful_registration') do
            registration_client = Teachable::Jg::Client.new(registration: true, email: "dev-8@example.com", password: "password", password_confirmation: "password")

            expect(registration_client.authorized).to be_falsey
          end
        end
      end

      it 'verifies registration as successful' do
        VCR.use_cassette('teachable_client_successful_registration') do
          registration_client = Teachable::Jg::Client.new(registration: true, email: "dev-8@example.com", password: "password", password_confirmation: "password")

          expect(registration_client.delivered).to be_truthy
          expect(registration_client.status_message).to eq(registered)
        end
      end

      it 'does not verify registration if password does not match password_confirmation' do
        VCR.use_cassette('teachable_client_unsuccessful_registration') do
          registration_client = Teachable::Jg::Client.new(registration: true, email: "dev-8@example.com", password: "password", password_confirmation: "PASSwoRd")

          expect(registration_client.delivered).to be_truthy
          expect(registration_client.status_message).to eq(unregistered)
        end
      end

      it 'confirms registration has already occurred if user already registered' do
        VCR.use_cassette('teachable_client_already_registered') do
          registration_client = Teachable::Jg::Client.new(registration: true, email: "dev-8@example.com", password: "already_registered", password_confirmation: "already_registered")

          expect(registration_client.delivered).to be_truthy
          expect(registration_client.status_message).to eq(already_registered)
        end
      end

      it 'does not confirm registration if missing params' do
        VCR.use_cassette('teachable_client_unsuccessful_missing_params') do
          registration_client = Teachable::Jg::Client.new(registration: true, emmmail: "dev-8@example.com", passsword: "already_registered", password_confirmation: "already_registered")

          expect(registration_client.delivered).to be_falsey
          expect(registration_client.status_message).to eq(invalid)
        end
      end
    end
  end

  describe 'gathering current_user information' do
    let(:successful_user_info) do
      { "success"       =>  true,
      "user_info"       =>  "verified",
      "user_name"       =>  "Mike Smith",
      "user_login"      =>  "dev-6@example.com",
      "user_phone"      =>  "14152204981",
      "user_registered" =>  Time.utc(2000,"jan",1,20,15,1).to_s }
    end

    let(:unauthorized_login)     { {"success"    =>false, "login"=>"failed to authorize"} }
    let(:unrecognized_user_info) { {"success"    =>true,  "user_info" => "unrecognized or malformed"} }
    let(:invalid_user_info)      { {"success"    =>false, "user_info"=>"missing or invalid params" } }
    let(:successful_auth_client) { Teachable::Jg::Client.new(email: "dev-8@example.com", password: "password") }

    context "unauthorized" do
      it "is must be authorized to make http request for user info" do
        VCR.use_cassette('teachable_client_successful') do
          unauthorized_client = successful_auth_client
          unauthorized_client.authorized = false

          expect(unauthorized_client.authorized).to be_falsey
          expect(unauthorized_client.user_info(user_email: "dev-6@example.com", user_token: "3kpLtJAd4fBmPsPnmaiZ")).to eq(unauthorized_login)
          expect(unauthorized_client.delivered).to be_falsey
        end
      end
    end

    it "gathers user info" do
      VCR.use_cassette('teachable_client_successful_user_info') do
        info = successful_auth_client.user_info(user_email: "dev-6@example.com", user_token: "3kpLtJAd4fBmPsPnmaiZ")

        expect(successful_auth_client.authorized).to be_truthy
        expect(successful_auth_client.delivered).to be_truthy
        expect(info).to eq(successful_user_info)
      end
    end

    it 'does not gather user info if token incorrect' do
      VCR.use_cassette('teachable_client_unsuccessful_user_token') do
        info = successful_auth_client.user_info(user_email: "dev-6@example.com", user_token: "3kpLtJAd4fBmPsPnmaiZnnnn")

        expect(successful_auth_client.authorized).to be_truthy
        expect(successful_auth_client.delivered).to be_truthy
        expect(info).to eq(unrecognized_user_info)
      end
    end

    it 'does not gather user info if token does not match user email' do
      VCR.use_cassette('teachable_client_unsuccessful_user_email') do
        info = successful_auth_client.user_info(user_email: "dev-8@example.com", user_token: "3kpLtJAd4fBmPsPnmaiZ")

        expect(successful_auth_client.authorized).to be_truthy
        expect(successful_auth_client.delivered).to be_truthy
        expect(info).to eq(unrecognized_user_info)
      end
    end

    it 'does not gather user info if token does not match user email' do
      VCR.use_cassette('teachable_client_unsuccessful_missing_params') do
        info = successful_auth_client.user_info(user_token: "3kpLtJAd4fBmPsPnmaiZ")

        expect(successful_auth_client.authorized).to be_truthy
        expect(successful_auth_client.delivered).to be_falsey
        expect(info).to eq(invalid_user_info)
      end
    end
  end

  context "orders" do
    let(:successful_new_order) do
      { "success"            =>  true,
      "create_order"         =>  "verified",
      "total"                =>  "3.00",
      "total_quantity"       =>  "3",
      "email"                =>  "dev-6@example.com",
      "special_instructions" =>  "special instructions foo bar",
      "order_created"        =>  Time.utc(2000,"jan",1,20,15,1).to_s }
    end

    let(:valid_order_options) do
      { total: "3.00",
      total_quantity: "3",
      email: "dev-6@example.com",
      special_instructions:  "special instructions foo bar" }
    end

    let(:unauthorized_login)     { {"success"    =>false, "login"=>"failed to authorize"} }
    let(:successful_auth_client) { Teachable::Jg::Client.new(email: "dev-8@example.com", password: "password") }

    context "unauthorized" do
      it "is must be authorized to make http request for new order" do
        VCR.use_cassette('teachable_client_successful') do
          unauthorized_client = successful_auth_client
          unauthorized_client.authorized = false

          expect(unauthorized_client.authorized).to be_falsey
          expect(unauthorized_client.create_order(valid_order_options)).to eq(unauthorized_login)
          expect(unauthorized_client.delivered).to be_falsey
        end
      end
    end

    describe ".create_order" do




    end


  end
end