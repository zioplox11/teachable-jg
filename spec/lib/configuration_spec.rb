require 'spec_helper'

describe 'configuration' do

  describe '.api_key' do
    it 'returns default key' do
      expect(Teachable::Jg.api_key).to eq(Teachable::Jg::Configuration::DEFAULT_API_KEY)
    end
  end

  describe '.format' do
    it 'returns default format' do
      expect(Teachable::Jg.format).to eq(Teachable::Jg::Configuration::DEFAULT_FORMAT)
    end
  end

  describe '.user_agent' do
    it 'returns default user agent' do
      expect(Teachable::Jg.user_agent).to eq(Teachable::Jg::Configuration::DEFAULT_USER_AGENT)
    end
  end

  describe '.method' do
    it 'returns default http method' do
      expect(Teachable::Jg.method).to eq(Teachable::Jg::Configuration::DEFAULT_METHOD)
    end
  end

  Teachable::Jg::Configuration::VALID_CONFIG_KEYS.each do |key|
    describe ".#{key}" do
      it 'returns the default value' do
        expect(Teachable::Jg.send(key)).to eq(Teachable::Jg::Configuration.const_get("DEFAULT_#{key.upcase}"))
      end
    end
  end

  after do
    Teachable::Jg.reset
  end
end