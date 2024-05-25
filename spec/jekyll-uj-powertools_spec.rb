require 'jekyll-uj-powertools'

RSpec.describe Jekyll::UJPowertools do
  # Dummy class to include the filter methods
  class DummyClass
    include Jekyll::UJPowertools
  end

  let(:dummy) { DummyClass.new }

  describe '.strip_ads' do
    it 'removes ads from the string with custom HTML elements' do
      expect(dummy.strip_ads('This is <ad-unit>and ad</ad-unit>')).to eq('This is ')
    end

    it 'returns the original string if no ads are present' do
      expect(dummy.strip_ads('No ads here')).to eq('No ads here')
    end

    it 'removes multiple ads from the string' do
      expect(dummy.strip_ads('First part<ad-unit>ad content</ad-unit>Second part<ad-unit>more ad content</ad-unit>Third part')).to eq('First partSecond partThird part')
    end

    it 'removes surrounding whitespace' do
      expect(dummy.strip_ads("Start\n<ad-unit>\n  ad content\n</ad-unit>\nEnd")).to eq("Start\nEnd")
    end
  end

  describe '.json_escape' do
    it 'escapes double quotes in JSON string' do
      expect(dummy.json_escape('this is a "quote"')).to eq('this is a \"quote\"')
    end

    it 'escapes backslashes in JSON string' do
      expect(dummy.json_escape('this is a nothing')).to eq('this is a nothing')
    end
  end
end
