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
        expect(api.send(key)).to eq(key)
      end
    end

    describe 'with class configuration' do
      before do
        @config = {
          :api_key    => 'ak',
          :format     => 'of',
          :endpoint   => 'ep',
          :user_agent => 'ua',
          :method     => 'hm',
        }
      end

      it 'overrides module configuration' do
        api = Teachable::Jg::Client.new(@config)
        @keys.each do |key|
          expect(api.send(key)).to eq(@config[key])
        end
      end

      it 'overrides module configuration after' do
        api = Teachable::Jg::Client.new

        @config.each do |key, value|
          api.send("#{key}=", value)
        end

        @keys.each do |key|
          expect(api.send("#{key}")).to eq(@config[key])
        end
      end
    end

    describe '.authorize' do

      let(:authorized) { {"success"=>true, "login"=>"verified"} }
      let(:unrecognized) { {"success"=>true, "login"=>"unrecognized or malformed"} }

      let(:invalid) { {"success"=>false, "login"=>"missing or invalid" } }

      context "has user param" do
        it 'verifies login as successful' do
          tester = Teachable::Jg::Client.new


          VCR.use_cassette('teachable_client_successful') do
            expect(JSON.parse(tester.authorize(email: "dev-8@example.com", password: "password"))).to eq(authorized)
          end
        end

        it 'does not verify login if password incorrect' do
          tester = Teachable::Jg::Client.new


          VCR.use_cassette('teachable_client_successful_malformed1') do
            expect(JSON.parse(tester.authorize(email: "unregistered@example.com", password: "password"))).to eq(unrecognized)
          end
        end

        it 'does not verify login if email is unrecognized' do
          tester = Teachable::Jg::Client.new


          VCR.use_cassette('teachable_client_successful_malformed2') do
            expect(JSON.parse(tester.authorize(email: "dev-8@example.com", password: "smashword"))).to eq(unrecognized)
          end
        end
      end

      context "without user param" do
        it 'does not verify login' do
          tester = Teachable::Jg::Client.new


          VCR.use_cassette('teachable_client_unsuccessful') do
            expect(JSON.parse(tester.authorize(random: "dev-8@example.com", alsorandom: "password"))).to eq(invalid)
          end
        end
      end

    end

  end

end