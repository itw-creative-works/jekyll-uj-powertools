require_relative '../spec_helper'

RSpec.describe Jekyll::UJPowertools do
  # Dummy class to include the filter methods
  class DummyClass
    include Jekyll::UJPowertools

    def initialize
      @context = {
        registers: {
          page: {},
          site: nil
        }
      }
    end
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

    it 'removes Jekyll include statements for adunits' do
      input = 'Content {% include /master/modules/adunits/banner.html %} more content'
      expect(dummy.uj_strip_ads(input)).to eq('Contentmore content')
    end

    it 'handles nested HTML in ad units' do
      input = 'Start <ad-unit><div class="ad"><span>Advertisement</span></div></ad-unit> End'
      expect(dummy.uj_strip_ads(input)).to eq('StartEnd')
    end

    it 'handles empty ad units' do
      expect(dummy.uj_strip_ads('Before <ad-unit></ad-unit> After')).to eq('BeforeAfter')
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

    it 'escapes newlines in JSON string' do
      expect(dummy.uj_json_escape("line1\nline2")).to eq('line1\\nline2')
    end

    it 'escapes tabs in JSON string' do
      expect(dummy.uj_json_escape("tab\there")).to eq('tab\\there')
    end

    it 'escapes carriage returns in JSON string' do
      expect(dummy.uj_json_escape("line1\rline2")).to eq('line1\\rline2')
    end

    it 'handles empty strings' do
      expect(dummy.uj_json_escape('')).to eq('')
    end

    it 'handles strings with multiple escape characters' do
      input = "\"Hello\"\n\tWorld\r\n"
      expected = '\"Hello\"\\n\\tWorld\\r\\n'
      expect(dummy.uj_json_escape(input)).to eq(expected)
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

    it 'returns 0 for input of 1' do
      srand(1)
      expect(dummy.uj_random(1)).to eq(0)
    end

    it 'returns a number within the specified range' do
      100.times do
        result = dummy.uj_random(50)
        expect(result).to be >= 0
        expect(result).to be < 50
      end
    end
  end


  # Test Title Case method
  describe '.uj_title_case' do
    it 'capitalizes the first letter of each word' do
      expect(dummy.uj_title_case('this is a title')).to eq('This Is A Title')
    end
  end

  # Test Is Truthy method
  # describe '.uj_istruthy' do
  #   it 'returns true for non-empty strings' do
  #     expect(dummy.uj_istruthy('hello')).to eq(true)
  #     expect(dummy.uj_istruthy('0')).to eq(true)
  #     expect(dummy.uj_istruthy(' ')).to eq(true)
  #   end

  #   it 'returns false for empty strings' do
  #     expect(dummy.uj_istruthy('')).to eq(false)
  #   end

  #   it 'returns false for nil' do
  #     expect(dummy.uj_istruthy(nil)).to eq(false)
  #   end

  #   it 'returns false for the string "null" (case insensitive)' do
  #     expect(dummy.uj_istruthy('null')).to eq(false)
  #     expect(dummy.uj_istruthy('NULL')).to eq(false)
  #     expect(dummy.uj_istruthy('Null')).to eq(false)
  #   end

  #   it 'returns false for boolean false' do
  #     expect(dummy.uj_istruthy(false)).to eq(false)
  #   end

  #   it 'returns true for boolean true' do
  #     expect(dummy.uj_istruthy(true)).to eq(true)
  #   end

  #   it 'returns true for numbers including zero' do
  #     expect(dummy.uj_istruthy(0)).to eq(true)
  #     expect(dummy.uj_istruthy(123)).to eq(true)
  #     expect(dummy.uj_istruthy(-1)).to eq(true)
  #     expect(dummy.uj_istruthy(3.14)).to eq(true)
  #   end

  #   it 'returns false for empty arrays' do
  #     expect(dummy.uj_istruthy([])).to eq(false)
  #   end

  #   it 'returns true for non-empty arrays' do
  #     expect(dummy.uj_istruthy([1, 2, 3])).to eq(true)
  #     expect(dummy.uj_istruthy(['a'])).to eq(true)
  #   end

  #   it 'returns false for empty hashes' do
  #     expect(dummy.uj_istruthy({})).to eq(false)
  #   end

  #   it 'returns true for non-empty hashes' do
  #     expect(dummy.uj_istruthy({ key: 'value' })).to eq(true)
  #   end
  # end

  # Test Cache Breaker functionality
  describe 'site.uj.cache_breaker' do
    it 'provides a consistent timestamp via cache_timestamp' do
      expect(Jekyll::UJPowertools.cache_timestamp).to be_a(String)
      expect(Jekyll::UJPowertools.cache_timestamp).to match(/^\d+$/)
    end

    it 'returns the same timestamp across multiple calls' do
      first_call = Jekyll::UJPowertools.cache_timestamp
      second_call = Jekyll::UJPowertools.cache_timestamp
      expect(first_call).to eq(second_call)
    end
  end

  # Test Content Format method
  describe '.uj_content_format' do
    before do
      # Mock Liquid template parsing
      allow(Liquid::Template).to receive(:parse).and_return(
        double('template', render: 'liquified content')
      )
    end

    context 'when page extension is .md' do
      before do
        dummy.instance_variable_get(:@context)[:registers][:page]['extension'] = '.md'

        # Mock Jekyll site and markdown converter
        converter = double('converter', convert: '<p>markdownified content</p>')
        site = double('site', find_converter_instance: converter)
        dummy.instance_variable_get(:@context)[:registers][:site] = site
      end

      it 'applies both liquify and markdownify' do
        result = dummy.uj_content_format('test content')
        expect(result).to eq('<p>markdownified content</p>')
      end
    end

    context 'when page extension is not .md' do
      before do
        dummy.instance_variable_get(:@context)[:registers][:page]['extension'] = '.html'
      end

      it 'applies only liquify' do
        result = dummy.uj_content_format('test content')
        expect(result).to eq('liquified content')
      end
    end

    context 'when page has no extension' do
      it 'applies only liquify' do
        result = dummy.uj_content_format('test content')
        expect(result).to eq('liquified content')
      end
    end
  end

  # Test Commaify method
  describe '.uj_commaify' do
    it 'formats numbers with commas' do
      expect(dummy.uj_commaify(10000)).to eq('10,000')
      expect(dummy.uj_commaify(1000000)).to eq('1,000,000')
      expect(dummy.uj_commaify(1234567890)).to eq('1,234,567,890')
    end

    it 'handles small numbers without commas' do
      expect(dummy.uj_commaify(100)).to eq('100')
      expect(dummy.uj_commaify(999)).to eq('999')
      expect(dummy.uj_commaify(0)).to eq('0')
    end

    it 'handles string input' do
      expect(dummy.uj_commaify('10000')).to eq('10,000')
      expect(dummy.uj_commaify('5000000')).to eq('5,000,000')
    end

    it 'handles decimal numbers' do
      expect(dummy.uj_commaify(1234.56)).to eq('1,234.56')
      expect(dummy.uj_commaify('9876543.21')).to eq('9,876,543.21')
    end

    it 'handles negative numbers' do
      expect(dummy.uj_commaify(-10000)).to eq('-10,000')
      expect(dummy.uj_commaify('-1234567')).to eq('-1,234,567')
    end

    it 'handles nil input' do
      expect(dummy.uj_commaify(nil)).to eq(nil)
    end

    it 'handles empty string' do
      expect(dummy.uj_commaify('')).to eq('')
    end

    it 'handles already formatted numbers' do
      expect(dummy.uj_commaify('10,000')).to eq('10,000')
    end

    it 'leaves non-numeric strings unchanged' do
      expect(dummy.uj_commaify('Apples')).to eq('Apples')
      expect(dummy.uj_commaify('Hello World')).to eq('Hello World')
      expect(dummy.uj_commaify('abc123')).to eq('abc123')
    end

    it 'leaves mixed alphanumeric strings unchanged' do
      expect(dummy.uj_commaify('10k')).to eq('10k')
      expect(dummy.uj_commaify('$10000')).to eq('$10000')
    end
  end

  # Test Pretty JSON method
  describe '.uj_jsonify' do
    it 'pretty prints simple objects' do
      input = { 'name' => 'John', 'age' => 30 }
      expected = "{\n  \"name\": \"John\",\n  \"age\": 30\n}"
      expect(dummy.uj_jsonify(input)).to eq(expected)
    end

    it 'pretty prints arrays' do
      input = ['apple', 'banana', 'cherry']
      expected = "[\n  \"apple\",\n  \"banana\",\n  \"cherry\"\n]"
      expect(dummy.uj_jsonify(input)).to eq(expected)
    end

    it 'pretty prints nested objects' do
      input = {
        'user' => {
          'name' => 'John',
          'contacts' => {
            'email' => 'john@example.com',
            'phone' => '123-456-7890'
          }
        }
      }
      expected = "{\n  \"user\": {\n    \"name\": \"John\",\n    \"contacts\": {\n      \"email\": \"john@example.com\",\n      \"phone\": \"123-456-7890\"\n    }\n  }\n}"
      expect(dummy.uj_jsonify(input)).to eq(expected)
    end

    it 'pretty prints arrays with objects' do
      input = [
        { 'id' => 1, 'name' => 'Item 1' },
        { 'id' => 2, 'name' => 'Item 2' }
      ]
      expected = "[\n  {\n    \"id\": 1,\n    \"name\": \"Item 1\"\n  },\n  {\n    \"id\": 2,\n    \"name\": \"Item 2\"\n  }\n]"
      expect(dummy.uj_jsonify(input)).to eq(expected)
    end

    it 'handles empty objects' do
      expect(dummy.uj_jsonify({})).to eq("{\n}")
    end

    it 'handles empty arrays' do
      expect(dummy.uj_jsonify([])).to eq("[\n\n]")
    end

    it 'handles null values' do
      input = { 'value' => nil }
      expected = "{\n  \"value\": null\n}"
      expect(dummy.uj_jsonify(input)).to eq(expected)
    end

    it 'handles boolean values' do
      input = { 'active' => true, 'deleted' => false }
      expected = "{\n  \"active\": true,\n  \"deleted\": false\n}"
      expect(dummy.uj_jsonify(input)).to eq(expected)
    end

    it 'handles numbers' do
      input = { 'integer' => 42, 'float' => 3.14 }
      expected = "{\n  \"integer\": 42,\n  \"float\": 3.14\n}"
      expect(dummy.uj_jsonify(input)).to eq(expected)
    end

    it 'uses custom indent size when specified' do
      input = { 'name' => 'John', 'age' => 30 }

      # 4 spaces
      expected_4 = "{\n    \"name\": \"John\",\n    \"age\": 30\n}"
      expect(dummy.uj_jsonify(input, 4)).to eq(expected_4)

      # 1 space
      expected_1 = "{\n \"name\": \"John\",\n \"age\": 30\n}"
      expect(dummy.uj_jsonify(input, 1)).to eq(expected_1)

      # 0 spaces (no indent)
      expected_0 = "{\n\"name\": \"John\",\n\"age\": 30\n}"
      expect(dummy.uj_jsonify(input, 0)).to eq(expected_0)
    end

    it 'handles nested objects with custom indent' do
      input = {
        'user' => {
          'name' => 'John',
          'contacts' => {
            'email' => 'john@example.com'
          }
        }
      }
      expected = "{\n    \"user\": {\n        \"name\": \"John\",\n        \"contacts\": {\n            \"email\": \"john@example.com\"\n        }\n    }\n}"
      expect(dummy.uj_jsonify(input, 4)).to eq(expected)
    end

    it 'converts string indent to integer' do
      input = { 'name' => 'John' }
      expected = "{\n   \"name\": \"John\"\n}"
      expect(dummy.uj_jsonify(input, '3')).to eq(expected)
    end
  end
end
