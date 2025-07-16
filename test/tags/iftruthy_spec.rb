require 'jekyll-uj-powertools'

RSpec.describe Jekyll::UJPowertools::IfTruthyTag do
  let(:site) { Jekyll::Site.new(Jekyll.configuration) }
  let(:context) { Liquid::Context.new({}, {}, { site: site }) }

  def render_tag(variable_name, content, variable_value = nil)
    context[variable_name] = variable_value unless variable_value.nil?
    template = Liquid::Template.parse("{% iftruthy #{variable_name} %}#{content}{% endiftruthy %}")
    template.render(context)
  end

  describe 'truthy value handling' do
    it 'renders content when variable is a non-empty string' do
      expect(render_tag('myvar', 'PRINTED', 'hello')).to eq('PRINTED')
    end

    it 'renders content when variable is a number' do
      expect(render_tag('myvar', 'PRINTED', 42)).to eq('PRINTED')
      expect(render_tag('myvar', 'PRINTED', -1)).to eq('PRINTED')
    end

    it 'does not render content when variable is 0' do
      expect(render_tag('myvar', 'PRINTED', 0)).to eq('')
    end

    it 'renders content when variable is true' do
      expect(render_tag('myvar', 'PRINTED', true)).to eq('PRINTED')
    end

    it 'renders content when variable is an array' do
      expect(render_tag('myvar', 'PRINTED', [])).to eq('PRINTED')
      expect(render_tag('myvar', 'PRINTED', [1, 2, 3])).to eq('PRINTED')
    end

    it 'renders content when variable is a hash' do
      expect(render_tag('myvar', 'PRINTED', {})).to eq('PRINTED')
      expect(render_tag('myvar', 'PRINTED', { 'key' => 'value' })).to eq('PRINTED')
    end
  end

  describe 'falsy value handling' do
    it 'does not render content when variable is nil' do
      expect(render_tag('myvar', 'PRINTED', nil)).to eq('')
    end

    it 'does not render content when variable is false' do
      expect(render_tag('myvar', 'PRINTED', false)).to eq('')
    end

    it 'does not render content when variable is an empty string' do
      expect(render_tag('myvar', 'PRINTED', '')).to eq('')
    end

    it 'does not render content when variable is undefined' do
      # Variable not set in context
      expect(render_tag('undefined_var', 'PRINTED')).to eq('')
    end
  end

  describe 'nested variable access' do
    it 'works with nested object properties' do
      context['page'] = { 'my' => { 'variable' => 'value' } }
      template = Liquid::Template.parse("{% iftruthy page.my.variable %}PRINTED{% endiftruthy %}")
      expect(template.render(context)).to eq('PRINTED')
    end

    it 'handles undefined nested properties' do
      context['page'] = { 'other' => 'value' }
      template = Liquid::Template.parse("{% iftruthy page.my.variable %}PRINTED{% endiftruthy %}")
      expect(template.render(context)).to eq('')
    end

    it 'handles partially defined nested properties' do
      context['page'] = { 'my' => {} }
      template = Liquid::Template.parse("{% iftruthy page.my.variable %}PRINTED{% endiftruthy %}")
      expect(template.render(context)).to eq('')
    end
  end

  describe 'complex content handling' do
    it 'renders multi-line content correctly' do
      content = "Line 1\nLine 2\nLine 3"
      expect(render_tag('myvar', content, 'truthy')).to eq(content)
    end

    it 'handles nested Liquid tags' do
      context['myvar'] = 'truthy'
      context['name'] = 'World'
      template = Liquid::Template.parse("{% iftruthy myvar %}Hello {{ name }}!{% endiftruthy %}")
      expect(template.render(context)).to eq('Hello World!')
    end

    it 'handles HTML content' do
      content = '<div class="test">Content</div>'
      expect(render_tag('myvar', content, 'truthy')).to eq(content)
    end
  end

  describe 'edge cases' do
    it 'handles whitespace in variable names' do
      context['myvar'] = 'truthy'
      template = Liquid::Template.parse("{% iftruthy   myvar   %}PRINTED{% endiftruthy %}")
      expect(template.render(context)).to eq('PRINTED')
    end

    it 'renders content for string "0"' do
      expect(render_tag('myvar', 'PRINTED', '0')).to eq('PRINTED')
    end

    it 'renders content for string with only spaces' do
      expect(render_tag('myvar', 'PRINTED', '   ')).to eq('PRINTED')
    end

    it 'works with variables containing special characters' do
      context['my-var'] = 'value'
      template = Liquid::Template.parse("{% iftruthy my-var %}PRINTED{% endiftruthy %}")
      expect(template.render(context)).to eq('PRINTED')
    end
  end

  describe 'comparison with standard Jekyll if' do
    it 'behaves consistently with manual truthy check' do
      test_values = [
        ['value', true, true],
        ['', true, false],
        [nil, true, false],
        [false, true, false],
        [true, true, true],
        [0, true, false],
        [[], true, true],
        [{}, true, true]
      ]

      test_values.each do |value, should_render_manual, should_render_truthy|
        context['test'] = value

        # Manual check template
        manual_template = Liquid::Template.parse(
          '{% if test != null and test != false and test != "" and test != 0 %}MANUAL{% endif %}'
        )

        # iftruthy template
        truthy_template = Liquid::Template.parse(
          '{% iftruthy test %}TRUTHY{% endiftruthy %}'
        )

        manual_result = manual_template.render(context)
        truthy_result = truthy_template.render(context)

        expect(truthy_result == 'TRUTHY').to eq(should_render_truthy),
          "Failed for value: #{value.inspect}"

        # Verify our tag behaves the same as the manual check
        expect((manual_result == 'MANUAL')).to eq((truthy_result == 'TRUTHY')),
          "Inconsistent behavior for value: #{value.inspect}"
      end
    end
  end
end
