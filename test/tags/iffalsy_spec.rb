require 'jekyll-uj-powertools'

RSpec.describe Jekyll::UJPowertools::IfFalsyTag do
  let(:site) { Jekyll::Site.new(Jekyll.configuration) }
  let(:context) { Liquid::Context.new({}, {}, { site: site }) }

  def render_tag(variable_name, content, variable_value = nil)
    context[variable_name] = variable_value unless variable_value.nil?
    template = Liquid::Template.parse("{% iffalsy #{variable_name} %}#{content}{% endiffalsy %}")
    template.render(context)
  end

  describe 'falsy value handling' do
    it 'renders content when variable is nil' do
      expect(render_tag('myvar', 'PRINTED', nil)).to eq('PRINTED')
    end

    it 'renders content when variable is false' do
      expect(render_tag('myvar', 'PRINTED', false)).to eq('PRINTED')
    end

    it 'renders content when variable is an empty string' do
      expect(render_tag('myvar', 'PRINTED', '')).to eq('PRINTED')
    end

    it 'renders content when variable is 0' do
      expect(render_tag('myvar', 'PRINTED', 0)).to eq('PRINTED')
    end

    it 'renders content when variable is undefined' do
      # Variable not set in context
      expect(render_tag('undefined_var', 'PRINTED')).to eq('PRINTED')
    end
  end

  describe 'truthy value handling' do
    it 'does not render content when variable is a non-empty string' do
      expect(render_tag('myvar', 'PRINTED', 'hello')).to eq('')
    end

    it 'does not render content when variable is a non-zero number' do
      expect(render_tag('myvar', 'PRINTED', 42)).to eq('')
      expect(render_tag('myvar', 'PRINTED', -1)).to eq('')
    end

    it 'does not render content when variable is true' do
      expect(render_tag('myvar', 'PRINTED', true)).to eq('')
    end

    it 'does not render content when variable is an array' do
      expect(render_tag('myvar', 'PRINTED', [])).to eq('')
      expect(render_tag('myvar', 'PRINTED', [1, 2, 3])).to eq('')
    end

    it 'does not render content when variable is a hash' do
      expect(render_tag('myvar', 'PRINTED', {})).to eq('')
      expect(render_tag('myvar', 'PRINTED', { 'key' => 'value' })).to eq('')
    end
  end

  describe 'nested variable access' do
    it 'handles undefined nested properties' do
      context['page'] = { 'other' => 'value' }
      template = Liquid::Template.parse("{% iffalsy page.my.variable %}PRINTED{% endiffalsy %}")
      expect(template.render(context)).to eq('PRINTED')
    end

    it 'handles partially defined nested properties' do
      context['page'] = { 'my' => {} }
      template = Liquid::Template.parse("{% iffalsy page.my.variable %}PRINTED{% endiffalsy %}")
      expect(template.render(context)).to eq('PRINTED')
    end

    it 'does not render for defined nested properties' do
      context['page'] = { 'my' => { 'variable' => 'value' } }
      template = Liquid::Template.parse("{% iffalsy page.my.variable %}PRINTED{% endiffalsy %}")
      expect(template.render(context)).to eq('')
    end

    it 'renders for nested properties with falsy values' do
      context['page'] = { 'my' => { 'variable' => false } }
      template = Liquid::Template.parse("{% iffalsy page.my.variable %}PRINTED{% endiffalsy %}")
      expect(template.render(context)).to eq('PRINTED')
    end
  end

  describe 'complex content handling' do
    it 'renders multi-line content correctly for falsy values' do
      content = "Line 1\nLine 2\nLine 3"
      expect(render_tag('myvar', content, false)).to eq(content)
    end

    it 'handles nested Liquid tags' do
      context['myvar'] = nil
      context['message'] = 'No value set'
      template = Liquid::Template.parse("{% iffalsy myvar %}{{ message }}{% endiffalsy %}")
      expect(template.render(context)).to eq('No value set')
    end

    it 'handles HTML content' do
      content = '<div class="error">Value not found</div>'
      expect(render_tag('myvar', content, nil)).to eq(content)
    end
  end

  describe 'edge cases' do
    it 'handles whitespace in variable names' do
      context['myvar'] = false
      template = Liquid::Template.parse("{% iffalsy   myvar   %}PRINTED{% endiffalsy %}")
      expect(template.render(context)).to eq('PRINTED')
    end

    it 'does not render content for string "0"' do
      expect(render_tag('myvar', 'PRINTED', '0')).to eq('')
    end

    it 'does not render content for string with only spaces' do
      expect(render_tag('myvar', 'PRINTED', '   ')).to eq('')
    end

    it 'works with variables containing special characters' do
      context['my-var'] = nil
      template = Liquid::Template.parse("{% iffalsy my-var %}PRINTED{% endiffalsy %}")
      expect(template.render(context)).to eq('PRINTED')
    end
  end

  describe 'comparison with standard Jekyll if' do
    it 'behaves consistently with manual falsy check' do
      test_values = [
        ['value', false],
        ['', true],
        [nil, true],
        [false, true],
        [true, false],
        [0, true],
        [42, false],
        [[], false],
        [{}, false],
        ['0', false],
        ['   ', false]
      ]

      test_values.each do |value, should_render_falsy|
        context['test'] = value

        # Manual falsy check template
        manual_template = Liquid::Template.parse(
          '{% if test == null or test == false or test == "" or test == 0 %}MANUAL{% endif %}'
        )

        # iffalsy template
        falsy_template = Liquid::Template.parse(
          '{% iffalsy test %}FALSY{% endiffalsy %}'
        )

        manual_result = manual_template.render(context)
        falsy_result = falsy_template.render(context)

        expect(falsy_result == 'FALSY').to eq(should_render_falsy),
          "Failed for value: #{value.inspect}"
      end
    end
  end

  describe 'opposite behavior to iftruthy' do
    it 'renders opposite to iftruthy for all values' do
      test_values = [nil, false, '', 0, 'value', 42, true, [], {}, '0', '   ']

      test_values.each do |value|
        context['test'] = value

        truthy_template = Liquid::Template.parse('{% iftruthy test %}TRUTHY{% endiftruthy %}')
        falsy_template = Liquid::Template.parse('{% iffalsy test %}FALSY{% endiffalsy %}')

        truthy_result = truthy_template.render(context)
        falsy_result = falsy_template.render(context)

        # They should never both render content
        both_empty = truthy_result.empty? || falsy_result.empty?
        expect(both_empty).to be(true), "Both rendered for value: #{value.inspect}"

        # At least one should render (except for edge cases)
        if [nil, false, '', 0].include?(value)
          expect(falsy_result).to eq('FALSY')
          expect(truthy_result).to eq('')
        else
          expect(truthy_result).to eq('TRUTHY')
          expect(falsy_result).to eq('')
        end
      end
    end
  end
end