# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveGrammar::Client do
  subject(:client) { described_class.new }

  describe 'runner method availability' do
    it 'responds to create_grammar_construction' do
      expect(client).to respond_to(:create_grammar_construction)
    end

    it 'responds to create_grammar_construal' do
      expect(client).to respond_to(:create_grammar_construal)
    end

    it 'responds to use_grammar_construction' do
      expect(client).to respond_to(:use_grammar_construction)
    end

    it 'responds to construals_for_scene_report' do
      expect(client).to respond_to(:construals_for_scene_report)
    end

    it 'responds to entrenched_constructions_report' do
      expect(client).to respond_to(:entrenched_constructions_report)
    end

    it 'responds to constructions_by_domain_report' do
      expect(client).to respond_to(:constructions_by_domain_report)
    end

    it 'responds to most_used_constructions' do
      expect(client).to respond_to(:most_used_constructions)
    end

    it 'responds to update_cognitive_grammar' do
      expect(client).to respond_to(:update_cognitive_grammar)
    end

    it 'responds to cognitive_grammar_stats' do
      expect(client).to respond_to(:cognitive_grammar_stats)
    end
  end

  describe 'full lifecycle' do
    let(:construction_params) do
      { form: 'the house', meaning: 'definite dwelling', expression_type: :nominal, domain: 'architecture' }
    end

    it 'creates a construction and retrieves stats' do
      client.create_grammar_construction(**construction_params)
      stats = client.cognitive_grammar_stats
      expect(stats[:constructions_count]).to eq(1)
    end

    it 'creates a construal and retrieves it by scene' do
      client.create_grammar_construal(
        scene: 'house on hill', perspective: 'valley', figure: 'house', ground: 'hill'
      )
      result = client.construals_for_scene_report(scene: 'house on hill')
      expect(result[:count]).to eq(1)
      expect(result[:construals].first[:figure]).to eq('house')
    end

    it 'entrenchment: construction becomes entrenched after 5 uses from default activation' do
      created = client.create_grammar_construction(**construction_params)
      expect(client.entrenched_constructions_report[:count]).to eq(0)

      5.times { client.use_grammar_construction(construction_id: created[:id]) }

      report = client.entrenched_constructions_report
      expect(report[:count]).to eq(1)
      expect(report[:constructions].first[:form]).to eq('the house')
    end

    it 'domain report scopes to correct domain' do
      client.create_grammar_construction(**construction_params)
      client.create_grammar_construction(form: 'fast', meaning: 'speed', expression_type: :relational, domain: 'motion')

      result = client.constructions_by_domain_report(domain: 'architecture')
      expect(result[:count]).to eq(1)
      expect(result[:constructions].first[:domain]).to eq('architecture')
    end

    it 'most_used_constructions tracks usage correctly' do
      c1 = client.create_grammar_construction(**construction_params)
      c2 = client.create_grammar_construction(form: 'run', meaning: 'motion', expression_type: :relational, domain: 'motion')

      2.times { client.use_grammar_construction(construction_id: c1[:id]) }
      5.times { client.use_grammar_construction(construction_id: c2[:id]) }

      top = client.most_used_constructions(limit: 1)
      expect(top[:constructions].first[:form]).to eq('run')
    end

    it 'update_cognitive_grammar decays activation' do
      created = client.create_grammar_construction(**construction_params)
      result  = client.update_cognitive_grammar
      expect(result[:stats][:constructions_count]).to be >= 0
      # After decay, activation should be lower than initial 0.3
      engine = client.send(:engine)
      const  = engine.instance_variable_get(:@constructions)[created[:id]]
      expect(const.activation).to be < 0.3
    end

    it 'construal figure/ground prominence model' do
      client.create_grammar_construal(
        scene:       'cup on table',
        perspective: 'human-scale',
        figure:      'cup',
        ground:      'table',
        specificity: :intermediate,
        scope:       :local
      )
      report = client.construals_for_scene_report(scene: 'cup on table')
      construal_h = report[:construals].first
      expect(construal_h[:figure]).to eq('cup')
      expect(construal_h[:ground]).to eq('table')
    end
  end
end
