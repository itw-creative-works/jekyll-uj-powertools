require 'jekyll-uj-powertools'

RSpec.describe Jekyll::UJPowertools do
  # Dummy class to include the filter methods
  class DummyClass
    include Jekyll::UJPowertools
  end

  let(:dummy) { DummyClass.new }

  # Test Strip Ads method
  describe '.uj_strip_ads' do
    it 'removes ads from the string with custom HTML elements' do
      expect(dummy.uj_strip_ads('This is <ad-unit>and ad</ad-unit>')).to eq('This is')
    end

    it 'returns the original string if no ads are present' do
      expect(dummy.uj_strip_ads('No ads here')).to eq('No ads here')
    end

    it 'removes multiple ads from the string' do
      expect(dummy.uj_strip_ads("First part\n<ad-unit>ad content</ad-unit>\nSecond part\n<ad-unit>more ad content</ad-unit>\nThird part")).to eq('First partSecond partThird part')
    end

    it 'removes surrounding whitespace' do
      expect(dummy.uj_strip_ads("Start\n<ad-unit>\n  ad content\n</ad-unit>\nEnd")).to eq("StartEnd")
    end
  end

  # Test JSON Escape method
  describe '.uj_json_escape' do
    it 'escapes double quotes in JSON string' do
      expect(dummy.uj_json_escape('this is a "quote"')).to eq('this is a \"quote\"')
    end

    it 'escapes backslashes in JSON string' do
      expect(dummy.uj_json_escape('this is a nothing')).to eq('this is a nothing')
    end
  end

  # Test Increment Return method
  describe '.uj_increment_return' do
    it 'increments a global counter' do
      expect(dummy.uj_increment_return(1)).to eq(1)
      expect(dummy.uj_increment_return(1)).to eq(2)
      expect(dummy.uj_increment_return(1)).to eq(3)
    end
  end

  # Test Random method
  describe '.uj_random' do
    it 'returns a random number between 0 and the input' do
      srand(1)
      expect(dummy.uj_random(10)).to eq(5)
      srand(2)
      expect(dummy.uj_random(10)).to eq(8)
      srand(3)
      expect(dummy.uj_random(10)).to eq(8)
    end
  end

  # Test Cache Buster method
  describe '.uj_cache' do
    it 'returns the current timestamp as a string' do
      expect(dummy.uj_cache('unused')).to eq(Time.now.to_i.to_s)
    end
  end

  # Test Title Case method
  describe '.uj_title_case' do
    it 'capitalizes the first letter of each word' do
      expect(dummy.uj_title_case('this is a title')).to eq('This Is A Title')
    end
  end
end
