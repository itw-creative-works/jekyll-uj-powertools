# require 'jekyll'
# require 'jekyll-uj-powertools'

# RSpec.describe 'IfIsTruthy and UnlessIsTruthy tags' do
#   let(:site) { Jekyll::Site.new(Jekyll.configuration) }

#   def render_liquid(content, assigns = {})
#     template = Liquid::Template.parse(content)
#     template.render!(assigns, registers: { site: site })
#   end

#   describe '{% ifistruthy %} tag' do
#     it 'renders content for truthy values' do
#       result = render_liquid('{% ifistruthy var %}truthy{% endifistruthy %}', 'var' => 'hello')
#       expect(result).to eq('truthy')
#     end

#     it 'does not render content for nil' do
#       result = render_liquid('{% ifistruthy var %}truthy{% endifistruthy %}', 'var' => nil)
#       expect(result).to eq('')
#     end

#     it 'does not render content for empty string' do
#       result = render_liquid('{% ifistruthy var %}truthy{% endifistruthy %}', 'var' => '')
#       expect(result).to eq('')
#     end

#     it 'does not render content for "null" string' do
#       result = render_liquid('{% ifistruthy var %}truthy{% endifistruthy %}', 'var' => 'null')
#       expect(result).to eq('')

#       result = render_liquid('{% ifistruthy var %}truthy{% endifistruthy %}', 'var' => 'NULL')
#       expect(result).to eq('')
#     end

#     it 'does not render content for false' do
#       result = render_liquid('{% ifistruthy var %}truthy{% endifistruthy %}', 'var' => false)
#       expect(result).to eq('')
#     end

#     it 'renders content for true' do
#       result = render_liquid('{% ifistruthy var %}truthy{% endifistruthy %}', 'var' => true)
#       expect(result).to eq('truthy')
#     end

#     it 'renders content for numbers including zero' do
#       result = render_liquid('{% ifistruthy var %}truthy{% endifistruthy %}', 'var' => 0)
#       expect(result).to eq('truthy')

#       result = render_liquid('{% ifistruthy var %}truthy{% endifistruthy %}', 'var' => 123)
#       expect(result).to eq('truthy')
#     end

#     it 'does not render content for empty arrays' do
#       result = render_liquid('{% ifistruthy var %}truthy{% endifistruthy %}', 'var' => [])
#       expect(result).to eq('')
#     end

#     it 'renders content for non-empty arrays' do
#       result = render_liquid('{% ifistruthy var %}truthy{% endifistruthy %}', 'var' => [1, 2, 3])
#       expect(result).to eq('truthy')
#     end

#     it 'supports else clause' do
#       template = '{% ifistruthy var %}truthy{% else %}falsy{% endifistruthy %}'

#       result = render_liquid(template, 'var' => 'hello')
#       expect(result).to eq('truthy')

#       result = render_liquid(template, 'var' => '')
#       expect(result).to eq('falsy')

#       result = render_liquid(template, 'var' => nil)
#       expect(result).to eq('falsy')
#     end
#   end

#   describe '{% unlessistruthy %} tag' do
#     it 'renders content for falsy values' do
#       result = render_liquid('{% unlessistruthy var %}falsy{% endunlessistruthy %}', 'var' => nil)
#       expect(result).to eq('falsy')

#       result = render_liquid('{% unlessistruthy var %}falsy{% endunlessistruthy %}', 'var' => '')
#       expect(result).to eq('falsy')

#       result = render_liquid('{% unlessistruthy var %}falsy{% endunlessistruthy %}', 'var' => 'null')
#       expect(result).to eq('falsy')

#       result = render_liquid('{% unlessistruthy var %}falsy{% endunlessistruthy %}', 'var' => false)
#       expect(result).to eq('falsy')
#     end

#     it 'does not render content for truthy values' do
#       result = render_liquid('{% unlessistruthy var %}falsy{% endunlessistruthy %}', 'var' => 'hello')
#       expect(result).to eq('')

#       result = render_liquid('{% unlessistruthy var %}falsy{% endunlessistruthy %}', 'var' => true)
#       expect(result).to eq('')

#       result = render_liquid('{% unlessistruthy var %}falsy{% endunlessistruthy %}', 'var' => 123)
#       expect(result).to eq('')
#     end

#     it 'supports else clause' do
#       template = '{% unlessistruthy var %}falsy{% else %}truthy{% endunlessistruthy %}'

#       result = render_liquid(template, 'var' => '')
#       expect(result).to eq('falsy')

#       result = render_liquid(template, 'var' => 'hello')
#       expect(result).to eq('truthy')
#     end
#   end

#   describe 'Complex usage scenarios' do
#     it 'works with nested content' do
#       template = <<~LIQUID
#         {% ifistruthy title %}
#           <h1>{{ title }}</h1>
#           {% ifistruthy subtitle %}
#             <h2>{{ subtitle }}</h2>
#           {% endifistruthy %}
#         {% else %}
#           <p>No title</p>
#         {% endifistruthy %}
#       LIQUID

#       result = render_liquid(template, 'title' => 'Main Title', 'subtitle' => 'Subtitle')
#       expect(result.strip).to include('<h1>Main Title</h1>')
#       expect(result.strip).to include('<h2>Subtitle</h2>')

#       result = render_liquid(template, 'title' => '', 'subtitle' => 'Subtitle')
#       expect(result.strip).to eq('<p>No title</p>')
#     end

#     it 'handles the common use case from the original request' do
#       # Simulating the original use case: {% if var and var != '' and var != 'null' %}
#       template = '{% ifistruthy var %}Content to show{% endifistruthy %}'

#       # Should show content
#       expect(render_liquid(template, 'var' => 'some value')).to eq('Content to show')

#       # Should not show content
#       expect(render_liquid(template, 'var' => nil)).to eq('')
#       expect(render_liquid(template, 'var' => '')).to eq('')
#       expect(render_liquid(template, 'var' => 'null')).to eq('')
#     end
#   end
# end
