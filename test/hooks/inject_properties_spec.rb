require_relative '../spec_helper'

RSpec.describe 'Jekyll Hooks - Inject Properties' do
  let(:site) do
    double('site', config: {})
  end

  before do
    # Reload the hook to ensure it's registered
    load File.expand_path('../../lib/hooks/inject-properties.rb', __dir__)
  end

  describe 'site pre_render hook' do
    it 'initializes uj config if not present' do
      Jekyll::Hooks.trigger(:site, :pre_render, site)
      
      expect(site.config['uj']).to be_a(Hash)
      expect(site.config['uj']['cache_breaker']).to eq(Jekyll::UJPowertools.cache_timestamp)
    end

    it 'preserves existing uj config and adds cache_breaker' do
      existing_config = { 'existing_key' => 'existing_value' }
      site.config['uj'] = existing_config

      Jekyll::Hooks.trigger(:site, :pre_render, site)

      expect(site.config['uj']['existing_key']).to eq('existing_value')
      expect(site.config['uj']['cache_breaker']).to eq(Jekyll::UJPowertools.cache_timestamp)
    end

    it 'sets cache_breaker to the consistent timestamp' do
      site.config['uj'] = {}
      
      Jekyll::Hooks.trigger(:site, :pre_render, site)

      expect(site.config['uj']['cache_breaker']).to eq(Jekyll::UJPowertools.cache_timestamp)
    end

    it 'uses the same timestamp value from UJPowertools' do
      timestamp = Jekyll::UJPowertools.cache_timestamp
      site.config['uj'] = {}

      Jekyll::Hooks.trigger(:site, :pre_render, site)

      expect(site.config['uj']['cache_breaker']).to eq(timestamp)
    end

    it 'initializes date properties with year, month, and day' do
      Jekyll::Hooks.trigger(:site, :pre_render, site)
      
      expect(site.config['uj']['date']).to be_a(Hash)
      expect(site.config['uj']['date']['year']).to eq(Time.now.year)
      expect(site.config['uj']['date']['month']).to eq(Time.now.month)
      expect(site.config['uj']['date']['day']).to eq(Time.now.day)
    end

    it 'preserves existing date config and updates values' do
      existing_date = { 'custom_key' => 'custom_value' }
      site.config['uj'] = { 'date' => existing_date }

      Jekyll::Hooks.trigger(:site, :pre_render, site)

      expect(site.config['uj']['date']['custom_key']).to eq('custom_value')
      expect(site.config['uj']['date']['year']).to eq(Time.now.year)
      expect(site.config['uj']['date']['month']).to eq(Time.now.month)
      expect(site.config['uj']['date']['day']).to eq(Time.now.day)
    end
  end

  describe 'hook registration' do
    it 'registers a hook for site pre_render event' do
      hooks = Jekyll::Hooks.instance_variable_get(:@registry)
      expect(hooks[:site]).to have_key(:pre_render)
      expect(hooks[:site][:pre_render]).not_to be_empty
    end
  end
end