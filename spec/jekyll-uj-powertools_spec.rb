require 'jekyll-uj-powertools'

RSpec.describe Jekyll::UJPowertools do
  # Dummy class to include the filter methods
  class DummyClass
    include Jekyll::UJPowertools
  end

  let(:dummy) { DummyClass.new }

  # describe '.remove_ads' do
  #   it 'removes ads from the string' do
  #     expect(dummy.remove_ads('This is an ad! Buy now!')).to eq('This is an !')
  #   end

  #   it 'returns the original string if no ads are present' do
  #     expect(dummy.remove_ads('No ads here')).to eq('No ads here')
  #   end
  # end

  describe '.json_escape' do
    it 'escapes double quotes in JSON string' do
      expect(dummy.json_escape('this is a "quote"')).to eq('this is a \"quote\"')
    end

    it 'escapes backslashes in JSON string' do
      expect(dummy.json_escape('this is a nothing')).to eq('this is a nothing')
    end
  end
end
