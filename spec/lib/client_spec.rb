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

  end

end