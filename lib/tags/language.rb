# Libraries
require "jekyll"

module Jekyll
  class UJLanguageTag < Liquid::Tag
    # Language mappings: ISO code => [English name, Native name]
    LANGUAGE_MAPPINGS = {
      'aa' => ['Afar', 'Afaraf'],
      'ab' => ['Abkhazian', 'аҧсуа бызшәа'],
      'ae' => ['Avestan', 'avesta'],
      'af' => ['Afrikaans', 'Afrikaans'],
      'ak' => ['Akan', 'Akan'],
      'am' => ['Amharic', 'አማርኛ'],
      'an' => ['Aragonese', 'aragonés'],
      'ar' => ['Arabic', 'العربية'],
      'as' => ['Assamese', 'অসমীয়া'],
      'av' => ['Avaric', 'авар мацӀ'],
      'ay' => ['Aymara', 'aymar aru'],
      'az' => ['Azerbaijani', 'azərbaycan dili'],
      'ba' => ['Bashkir', 'башҡорт теле'],
      'be' => ['Belarusian', 'беларуская мова'],
      'bg' => ['Bulgarian', 'български език'],
      'bh' => ['Bihari languages', 'भोजपुरी'],
      'bi' => ['Bislama', 'Bislama'],
      'bm' => ['Bambara', 'bamanankan'],
      'bn' => ['Bengali', 'বাংলা'],
      'bo' => ['Tibetan', 'བོད་ཡིག'],
      'br' => ['Breton', 'brezhoneg'],
      'bs' => ['Bosnian', 'bosanski jezik'],
      'ca' => ['Catalan', 'català'],
      'ce' => ['Chechen', 'нохчийн мотт'],
      'ch' => ['Chamorro', 'Chamoru'],
      'co' => ['Corsican', 'corsu'],
      'cr' => ['Cree', 'ᓀᐦᐃᔭᐍᐏᐣ'],
      'cs' => ['Czech', 'čeština'],
      'cu' => ['Church Slavic', 'ѩзыкъ словѣньскъ'],
      'cv' => ['Chuvash', 'чӑваш чӗлхи'],
      'cy' => ['Welsh', 'Cymraeg'],
      'da' => ['Danish', 'dansk'],
      'de' => ['German', 'Deutsch'],
      'dv' => ['Divehi', 'ދިވެހި'],
      'dz' => ['Dzongkha', 'རྫོང་ཁ'],
      'ee' => ['Ewe', 'Eʋegbe'],
      'el' => ['Greek', 'ελληνικά'],
      'en' => ['English', 'English'],
      'eo' => ['Esperanto', 'Esperanto'],
      'es' => ['Spanish', 'español'],
      'et' => ['Estonian', 'eesti'],
      'eu' => ['Basque', 'euskera'],
      'fa' => ['Persian', 'فارسی'],
      'ff' => ['Fulah', 'Fulfulde'],
      'fi' => ['Finnish', 'suomi'],
      'fj' => ['Fijian', 'vosa Vakaviti'],
      'fo' => ['Faroese', 'føroyskt'],
      'fr' => ['French', 'français'],
      'fy' => ['Western Frisian', 'Frysk'],
      'ga' => ['Irish', 'Gaeilge'],
      'gd' => ['Gaelic', 'Gàidhlig'],
      'gl' => ['Galician', 'galego'],
      'gn' => ['Guarani', 'Avañe\'ẽ'],
      'gu' => ['Gujarati', 'ગુજરાતી'],
      'gv' => ['Manx', 'Gaelg'],
      'ha' => ['Hausa', 'هَوُسَ'],
      'he' => ['Hebrew', 'עברית'],
      'hi' => ['Hindi', 'हिन्दी'],
      'ho' => ['Hiri Motu', 'Hiri Motu'],
      'hr' => ['Croatian', 'hrvatski jezik'],
      'ht' => ['Haitian', 'Kreyòl ayisyen'],
      'hu' => ['Hungarian', 'magyar'],
      'hy' => ['Armenian', 'Հայերեն'],
      'hz' => ['Herero', 'Otjiherero'],
      'ia' => ['Interlingua', 'Interlingua'],
      'id' => ['Indonesian', 'Bahasa Indonesia'],
      'ie' => ['Interlingue', 'Interlingue'],
      'ig' => ['Igbo', 'Asụsụ Igbo'],
      'ii' => ['Nuosu', 'ꆈꌠ꒿ Nuosuhxop'],
      'ik' => ['Inupiaq', 'Iñupiaq'],
      'io' => ['Ido', 'Ido'],
      'is' => ['Icelandic', 'Íslenska'],
      'it' => ['Italian', 'italiano'],
      'iu' => ['Inuktitut', 'ᐃᓄᒃᑎᑐᑦ'],
      'ja' => ['Japanese', '日本語'],
      'jv' => ['Javanese', 'basa Jawa'],
      'ka' => ['Georgian', 'ქართული'],
      'kg' => ['Kongo', 'Kikongo'],
      'ki' => ['Kikuyu', 'Gĩkũyũ'],
      'kj' => ['Kwanyama', 'Kuanyama'],
      'kk' => ['Kazakh', 'қазақ тілі'],
      'kl' => ['Kalaallisut', 'kalaallisut'],
      'km' => ['Khmer', 'ខ្មែរ'],
      'kn' => ['Kannada', 'ಕನ್ನಡ'],
      'ko' => ['Korean', '한국어'],
      'kr' => ['Kanuri', 'Kanuri'],
      'ks' => ['Kashmiri', 'कश्मीरी'],
      'ku' => ['Kurdish', 'Kurdî'],
      'kv' => ['Komi', 'коми кыв'],
      'kw' => ['Cornish', 'Kernewek'],
      'ky' => ['Kirghiz', 'Кыргызча'],
      'la' => ['Latin', 'latine'],
      'lb' => ['Luxembourgish', 'Lëtzebuergesch'],
      'lg' => ['Ganda', 'Luganda'],
      'li' => ['Limburgish', 'Limburgs'],
      'ln' => ['Lingala', 'Lingála'],
      'lo' => ['Lao', 'ພາສາລາວ'],
      'lt' => ['Lithuanian', 'lietuvių kalba'],
      'lu' => ['Luba-Katanga', 'Tshiluba'],
      'lv' => ['Latvian', 'latviešu valoda'],
      'mg' => ['Malagasy', 'fiteny malagasy'],
      'mh' => ['Marshallese', 'Kajin M̧ajeļ'],
      'mi' => ['Māori', 'te reo Māori'],
      'mk' => ['Macedonian', 'македонски јазик'],
      'ml' => ['Malayalam', 'മലയാളം'],
      'mn' => ['Mongolian', 'Монгол хэл'],
      'mr' => ['Marathi', 'मराठी'],
      'ms' => ['Malay', 'bahasa Melayu'],
      'mt' => ['Maltese', 'Malti'],
      'my' => ['Burmese', 'ဗမာစာ'],
      'na' => ['Nauru', 'Dorerin Naoero'],
      'nb' => ['Norwegian Bokmål', 'Norsk bokmål'],
      'nd' => ['North Ndebele', 'isiNdebele'],
      'ne' => ['Nepali', 'नेपाली'],
      'ng' => ['Ndonga', 'Owambo'],
      'nl' => ['Dutch', 'Nederlands'],
      'nn' => ['Norwegian Nynorsk', 'Norsk nynorsk'],
      'no' => ['Norwegian', 'Norsk'],
      'nr' => ['South Ndebele', 'isiNdebele'],
      'nv' => ['Navajo', 'Diné bizaad'],
      'ny' => ['Chichewa', 'chiCheŵa'],
      'oc' => ['Occitan', 'occitan'],
      'oj' => ['Ojibwa', 'ᐊᓂᔑᓈᐯᒧᐎᓐ'],
      'om' => ['Oromo', 'Afaan Oromoo'],
      'or' => ['Oriya', 'ଓଡ଼ିଆ'],
      'os' => ['Ossetian', 'ирон æвзаг'],
      'pa' => ['Panjabi', 'ਪੰਜਾਬੀ'],
      'pi' => ['Pāli', 'पाऴि'],
      'pl' => ['Polish', 'język polski'],
      'ps' => ['Pashto', 'پښتو'],
      'pt' => ['Portuguese', 'português'],
      'qu' => ['Quechua', 'Runa Simi'],
      'rm' => ['Romansh', 'rumantsch grischun'],
      'rn' => ['Kirundi', 'Ikirundi'],
      'ro' => ['Romanian', 'română'],
      'ru' => ['Russian', 'русский'],
      'rw' => ['Kinyarwanda', 'Ikinyarwanda'],
      'sa' => ['Sanskrit', 'संस्कृतम्'],
      'sc' => ['Sardinian', 'sardu'],
      'sd' => ['Sindhi', 'सिन्धी'],
      'se' => ['Northern Sami', 'Davvisámegiella'],
      'sg' => ['Sango', 'yângâ tî sängö'],
      'si' => ['Sinhala', 'සිංහල'],
      'sk' => ['Slovak', 'slovenčina'],
      'sl' => ['Slovene', 'slovenski jezik'],
      'sm' => ['Samoan', 'gagana fa\'a Samoa'],
      'sn' => ['Shona', 'chiShona'],
      'so' => ['Somali', 'Soomaaliga'],
      'sq' => ['Albanian', 'gjuha shqipe'],
      'sr' => ['Serbian', 'српски језик'],
      'ss' => ['Swati', 'SiSwati'],
      'st' => ['Southern Sotho', 'Sesotho'],
      'su' => ['Sundanese', 'Basa Sunda'],
      'sv' => ['Swedish', 'svenska'],
      'sw' => ['Swahili', 'Kiswahili'],
      'ta' => ['Tamil', 'தமிழ்'],
      'te' => ['Telugu', 'తెలుగు'],
      'tg' => ['Tajik', 'тоҷикӣ'],
      'th' => ['Thai', 'ไทย'],
      'ti' => ['Tigrinya', 'ትግርኛ'],
      'tk' => ['Turkmen', 'Türkmen'],
      'tl' => ['Tagalog', 'Wikang Tagalog'],
      'tn' => ['Tswana', 'Setswana'],
      'to' => ['Tonga', 'faka Tonga'],
      'tr' => ['Turkish', 'Türkçe'],
      'ts' => ['Tsonga', 'Xitsonga'],
      'tt' => ['Tatar', 'татар теле'],
      'tw' => ['Twi', 'Twi'],
      'ty' => ['Tahitian', 'Reo Tahiti'],
      'ug' => ['Uighur', 'ئۇيغۇرچە‎'],
      'uk' => ['Ukrainian', 'українська мова'],
      'ur' => ['Urdu', 'اردو'],
      'uz' => ['Uzbek', 'Oʻzbek'],
      've' => ['Venda', 'Tshivenḓa'],
      'vi' => ['Vietnamese', 'Tiếng Việt'],
      'vo' => ['Volapük', 'Volapük'],
      'wa' => ['Walloon', 'walon'],
      'wo' => ['Wolof', 'Wollof'],
      'xh' => ['Xhosa', 'isiXhosa'],
      'yi' => ['Yiddish', 'ייִדיש'],
      'yo' => ['Yoruba', 'Yorùbá'],
      'za' => ['Zhuang', 'Saɯ cueŋƅ'],
      'zh' => ['Chinese', '中文'],
      'zu' => ['Zulu', 'isiZulu']
    }

    def initialize(tag_name, markup, tokens)
      super
      @markup = markup.strip
    end

    def render(context)
      # Parse arguments that can be quoted or unquoted
      parts = parse_arguments(@markup)
      iso_code_input = parts[0]
      output_type = parts[1] || 'english' # default to english

      # Check if the input was originally quoted (literal string)
      is_quoted = @markup.strip.match(/^['"]/)

      # If quoted, use as literal. Otherwise, try to resolve as variable
      if is_quoted
        iso_code = iso_code_input
      else
        # Try to resolve as a variable
        iso_code = resolve_variable(context, iso_code_input)
        # If it didn't resolve to a string, use the input as literal
        iso_code = iso_code_input if iso_code.nil? || !iso_code.is_a?(String)
      end

      # Strip quotes from resolved iso code if present
      if iso_code.is_a?(String) && iso_code.match(/^['"].*['"]$/)
        iso_code = iso_code[1..-2]
      end

      # Strip quotes from output type if present
      if output_type.is_a?(String) && output_type.match(/^['"].*['"]$/)
        output_type = output_type[1..-2]
      end

      # Convert to lowercase for lookup
      iso_code = iso_code.to_s.downcase
      output_type = output_type.to_s.downcase

      # Look up the language
      language_data = LANGUAGE_MAPPINGS[iso_code]
      return iso_code if language_data.nil? # Return original code if not found

      # Return appropriate language name based on output type
      case output_type
      when 'native'
        language_data[1] # Native name
      else
        language_data[0] # English name (default)
      end
    end

    private

    def parse_arguments(markup)
      # Parse arguments that can be quoted or unquoted
      # Examples: de, english  OR  'de', 'english'  OR  myVar, "native"
      args = []
      current_arg = ''
      in_quotes = false
      quote_char = nil

      markup.each_char.with_index do |char, i|
        if !in_quotes && (char == '"' || char == "'")
          # Start of quoted string
          in_quotes = true
          quote_char = char
        elsif in_quotes && char == quote_char
          # End of quoted string
          in_quotes = false
          quote_char = nil
        elsif !in_quotes && char == ','
          # Argument separator
          args << current_arg.strip
          current_arg = ''
        else
          # Regular character
          current_arg += char
        end
      end

      # Add the last argument
      args << current_arg.strip if current_arg.strip.length > 0

      args
    end

    def resolve_variable(context, variable_name)
      # Handle nested variable access like page.language
      parts = variable_name.split('.')
      current = context

      parts.each do |part|
        if current.respond_to?(:[])
          current = current[part]
        elsif current.respond_to?(:key?) && current.key?(part)
          current = current[part]
        else
          return nil
        end
        return nil if current.nil?
      end

      current
    end
  end
end

Liquid::Template.register_tag('uj_language', Jekyll::UJLanguageTag)