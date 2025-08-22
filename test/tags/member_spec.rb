require_relative '../spec_helper'

RSpec.describe Jekyll::UJMemberTag do
  let(:site_config) do
    {
      'url' => 'https://example.com'
    }
  end

  let(:site) { Jekyll::Site.new(Jekyll.configuration(site_config)) }
  
  # Create mock team members
  let(:member1_data) do
    {
      'member' => {
        'name' => 'John Doe',
        'bio' => 'Software Engineer',
        'role' => 'Developer',
        'email' => 'john@example.com'
      }
    }
  end
  
  let(:member2_data) do
    {
      'member' => {
        'name' => 'Jane Smith',
        'bio' => 'Product Manager',
        'role' => 'PM',
        'twitter' => 'janesmith'
      }
    }
  end

  let(:member1) do
    doc = double('Document')
    allow(doc).to receive(:id).and_return('/team/john-doe')
    allow(doc).to receive(:url).and_return('/team/john-doe')
    allow(doc).to receive(:data).and_return(member1_data)
    doc
  end

  let(:member2) do
    doc = double('Document')
    allow(doc).to receive(:id).and_return('/team/jane-smith')
    allow(doc).to receive(:url).and_return('/team/jane-smith')
    allow(doc).to receive(:data).and_return(member2_data)
    doc
  end

  let(:team_collection) do
    collection = double('Collection')
    allow(collection).to receive(:docs).and_return([member1, member2])
    collection
  end

  before do
    allow(site).to receive(:collections).and_return({'team' => team_collection})
  end

  let(:context) do
    ctx = Liquid::Context.new
    ctx.registers[:site] = site
    ctx
  end

  def render_tag(markup)
    template = Liquid::Template.parse("{% uj_member #{markup} %}")
    template.render(context)
  end

  describe 'basic member rendering' do
    it 'renders member name by default' do
      result = render_tag('"john-doe"')
      expect(result).to eq('John Doe')
    end

    it 'renders empty string for non-existent member' do
      result = render_tag('"nonexistent"')
      expect(result).to eq('')
    end

    it 'renders member name when property is explicitly specified' do
      result = render_tag('"jane-smith", "name"')
      expect(result).to eq('Jane Smith')
    end
  end

  describe 'member properties' do
    it 'renders member URL' do
      result = render_tag('"john-doe", "url"')
      expect(result).to eq('https://example.com/team/john-doe')
    end

    it 'renders member path' do
      result = render_tag('"john-doe", "path"')
      expect(result).to eq('/team/john-doe')
    end

    it 'renders member image path' do
      result = render_tag('"john-doe", "image"')
      expect(result).to eq('/assets/images/team/john-doe/profile.jpg')
    end

    it 'renders custom member properties' do
      result = render_tag('"john-doe", "bio"')
      expect(result).to eq('Software Engineer')
      
      result = render_tag('"john-doe", "role"')
      expect(result).to eq('Developer')
      
      result = render_tag('"john-doe", "email"')
      expect(result).to eq('john@example.com')
    end

    it 'returns empty string for non-existent properties' do
      result = render_tag('"john-doe", "nonexistent"')
      expect(result).to eq('')
    end
  end

  describe 'variable resolution' do
    it 'resolves member ID from context variable' do
      context['authorId'] = 'jane-smith'
      template = Liquid::Template.parse("{% uj_member authorId, 'name' %}")
      result = template.render(context)
      expect(result).to eq('Jane Smith')
    end

    it 'resolves nested variables' do
      context['page'] = { 'post' => { 'author' => 'john-doe' } }
      template = Liquid::Template.parse("{% uj_member page.post.author, 'role' %}")
      result = template.render(context)
      expect(result).to eq('Developer')
    end

    it 'uses default sources when no member ID provided' do
      context['page'] = { 'post' => { 'member' => 'jane-smith' } }
      template = Liquid::Template.parse("{% uj_member %}")
      result = template.render(context)
      expect(result).to eq('Jane Smith')
    end

    it 'uses page.id when page.member.name exists' do
      context['page'] = { 
        'id' => '/team/john-doe',
        'member' => { 'name' => 'John Doe' } 
      }
      template = Liquid::Template.parse("{% uj_member %}")
      result = template.render(context)
      expect(result).to eq('John Doe')
    end
  end

  describe 'quoted vs unquoted arguments' do
    it 'treats quoted strings as literals' do
      context['john-doe'] = 'some-other-value'
      result = render_tag('"john-doe", "name"')
      expect(result).to eq('John Doe')
    end

    it 'resolves unquoted strings as variables' do
      context['memberId'] = 'jane-smith'
      result = render_tag('memberId, "bio"')
      expect(result).to eq('Product Manager')
    end

    it 'handles mixed quoted and unquoted arguments' do
      context['memberId'] = 'john-doe'
      result = render_tag('memberId, "role"')
      expect(result).to eq('Developer')
    end
  end

  describe 'edge cases' do
    it 'handles missing data structures gracefully' do
      # Member without nested 'member' data
      doc = double('Document')
      allow(doc).to receive(:id).and_return('/team/minimal')
      allow(doc).to receive(:url).and_return('/team/minimal')
      allow(doc).to receive(:data).and_return({ 'title' => 'Minimal Member' })
      
      allow(team_collection).to receive(:docs).and_return([doc])
      
      result = render_tag('"minimal", "name"')
      expect(result).to eq('')
    end

    it 'handles nil values gracefully' do
      context['memberId'] = nil
      result = render_tag('memberId, "name"')
      expect(result).to eq('')
    end

    it 'handles missing collections gracefully' do
      allow(site).to receive(:collections).and_return({})
      result = render_tag('"john-doe", "name"')
      expect(result).to eq('')
    end

    it 'strips extra whitespace from arguments' do
      result = render_tag(' "john-doe" ,  "name" ')
      expect(result).to eq('John Doe')
    end
  end

  describe 'member ID cleaning' do
    it 'removes /team/ prefix from image paths' do
      result = render_tag('"john-doe", "image"')
      expect(result).not_to include('/team//team/')
      expect(result).to eq('/assets/images/team/john-doe/profile.jpg')
    end
  end
end