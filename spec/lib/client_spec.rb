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
          confirmed:            'zy',
          status_message: 'nn',
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

    describe 'registration via .confirm_status' do
      let(:registered)         { {"success" =>true, "registration"=>"verified"} }
      let(:already_registered) { {"success" =>true, "registration"=>"already_registered"} }
      let(:unregistered)       { {"success" =>true, "registration"=>"unrecognized or malformed"} }
      let(:invalid)            { {"success" =>false, "registration"=>"missing or invalid" } }


      it 'verifies registration as successful' do
        tester = Teachable::Jg::Client.new(registration: true, email: "dev-8@example.com", password: "password", password_confirmation: "password")

        VCR.use_cassette('teachable_client_successful_registration') do
          expect(tester.confirmed).to eq(true)
          expect(tester.status_message).to eq(registered)
        end
      end

      it 'does not verify registration if password does not match password_confirmation' do
        tester = Teachable::Jg::Client.new(registration: true, email: "dev-8@example.com", password: "password", password_confirmation: "PASSwoRd")

        VCR.use_cassette('teachable_client_unsuccessful_registration') do
          expect(tester.confirmed).to eq(true)
          expect(tester.status_message).to eq(unregistered)
        end
      end

      it 'confirms registration has already occurred if user already registered' do
        tester = Teachable::Jg::Client.new(registration: true, email: "dev-8@example.com", password: "already_registered", password_confirmation: "already_registered")

        VCR.use_cassette('teachable_client_already_registered') do
          expect(tester.confirmed).to eq(true)
          expect(tester.status_message).to eq(already_registered)
        end
      end

      it 'does not confirm registration if missing params' do
        tester = Teachable::Jg::Client.new(registration: true, emmmail: "dev-8@example.com", passsword: "already_registered", password_confirmation: "already_registered")

        VCR.use_cassette('teachable_client_unsuccessful_missing_params') do
          expect(tester.confirmed).to eq(false)
          expect(tester.status_message).to eq(invalid)
        end
      end
    end

    describe 'status via .confirm_status' do
      let(:authorized)   { {"success" =>true, "login"=>"verified"} }
      let(:unrecognized) { {"success" =>true, "login"=>"unrecognized or malformed"} }
      let(:invalid)      { {"success" =>false, "login"=>"missing or invalid" } }

      context "has user param" do
        it 'verifies login as successful' do
          tester = Teachable::Jg::Client.new


          VCR.use_cassette('teachable_client_successful') do
            expect(tester.confirm_status(email: "dev-8@example.com", password: "password")).to eq(authorized)
          end
        end

        it 'does not verify login if password incorrect' do
          tester = Teachable::Jg::Client.new


          VCR.use_cassette('teachable_client_successful_malformed1') do
            expect(tester.confirm_status(email: "unregistered@example.com", password: "password")).to eq(unrecognized)
          end
        end

        it 'does not verify login if email is unrecognized' do
          tester = Teachable::Jg::Client.new


          VCR.use_cassette('teachable_client_successful_malformed2') do
            expect(tester.confirm_status(email: "dev-8@example.com", password: "smashword")).to eq(unrecognized)
          end
        end
      end

      context "without user param" do
        it 'does not verify login' do
          tester = Teachable::Jg::Client.new


          VCR.use_cassette('teachable_client_unsuccessful') do
            expect(tester.confirm_status(random: "dev-8@example.com", alsorandom: "password")).to eq(invalid)
          end
        end
      end
    end
  end

end