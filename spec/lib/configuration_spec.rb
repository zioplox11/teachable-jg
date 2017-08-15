require 'spec_helper'

describe 'configuration' do

  describe '.delivered' do
    it 'returns default key' do
      expect(Teachable::Jg.delivered).to eq(Teachable::Jg::Configuration::DEFAULT_DELIVERED)
    end
  end

  describe '.authorized' do
    it 'returns default key' do
      expect(Teachable::Jg.authorized).to eq(Teachable::Jg::Configuration::DEFAULT_AUTHORIZED)
    end
  end

  describe '.format' do
    it 'returns default format' do
      expect(Teachable::Jg.format).to eq(Teachable::Jg::Configuration::DEFAULT_FORMAT)
    end
  end

  describe '.headers' do
    it 'returns default headers' do
      expect(Teachable::Jg.headers).to eq(Teachable::Jg::Configuration::DEFAULT_HEADERS)
    end
  end

  describe '.status_message' do
    it 'returns default status message' do
      expect(Teachable::Jg.status_message).to eq(Teachable::Jg::Configuration::DEFAULT_STATUS_MESSAGE)
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