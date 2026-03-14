# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveGrammar::Helpers::GrammarEngine do
  subject(:engine) { described_class.new }

  let(:construction_params) do
    { form: 'the bird', meaning: 'definite avian', expression_type: :nominal, domain: 'nature' }
  end

  let(:construal_params) do
    { scene: 'bird on branch', perspective: 'ground-level', figure: 'bird', ground: 'branch' }
  end

  describe '#create_construction' do
    it 'returns a Construction instance' do
      c = engine.create_construction(**construction_params)
      expect(c).to be_a(Legion::Extensions::CognitiveGrammar::Helpers::Construction)
    end

    it 'stores the construction internally' do
      engine.create_construction(**construction_params)
      expect(engine.to_h[:constructions_count]).to eq(1)
    end

    it 'assigns correct attributes' do
      c = engine.create_construction(**construction_params)
      expect(c.form).to eq('the bird')
      expect(c.meaning).to eq('definite avian')
      expect(c.expression_type).to eq(:nominal)
      expect(c.domain).to eq('nature')
    end
  end

  describe '#create_construal' do
    it 'returns a Construal instance' do
      c = engine.create_construal(**construal_params)
      expect(c).to be_a(Legion::Extensions::CognitiveGrammar::Helpers::Construal)
    end

    it 'stores the construal' do
      engine.create_construal(**construal_params)
      expect(engine.to_h[:construals_count]).to eq(1)
    end

    it 'forwards all keyword args' do
      c = engine.create_construal(**construal_params, specificity: :detailed, scope: :global, dynamicity: 0.8)
      expect(c.specificity).to eq(:detailed)
      expect(c.scope).to eq(:global)
      expect(c.dynamicity).to eq(0.8)
    end
  end

  describe '#use_construction' do
    it 'returns nil for unknown id' do
      expect(engine.use_construction(construction_id: 'nonexistent')).to be_nil
    end

    it 'increments usage_count' do
      c = engine.create_construction(**construction_params)
      engine.use_construction(construction_id: c.id)
      expect(c.usage_count).to eq(1)
    end

    it 'returns the updated construction' do
      c = engine.create_construction(**construction_params)
      result = engine.use_construction(construction_id: c.id)
      expect(result).to eq(c)
    end
  end

  describe '#construals_for_scene' do
    it 'returns empty array when no construals exist' do
      expect(engine.construals_for_scene(scene: 'nothing')).to eq([])
    end

    it 'returns only construals matching the scene' do
      engine.create_construal(**construal_params)
      engine.create_construal(scene: 'other scene', perspective: 'p', figure: 'f', ground: 'g')
      results = engine.construals_for_scene(scene: 'bird on branch')
      expect(results.size).to eq(1)
      expect(results.first.scene).to eq('bird on branch')
    end

    it 'returns multiple construals for same scene (different perspectives)' do
      engine.create_construal(**construal_params)
      engine.create_construal(scene: 'bird on branch', perspective: 'aerial', figure: 'bird', ground: 'branch')
      results = engine.construals_for_scene(scene: 'bird on branch')
      expect(results.size).to eq(2)
    end
  end

  describe '#entrenched_constructions' do
    it 'returns empty when none are entrenched' do
      engine.create_construction(**construction_params)
      expect(engine.entrenched_constructions).to be_empty
    end

    it 'returns constructions once they reach entrenchment threshold via use!' do
      c = engine.create_construction(**construction_params)
      5.times { engine.use_construction(construction_id: c.id) }
      expect(engine.entrenched_constructions).to include(c)
    end
  end

  describe '#constructions_by_domain' do
    it 'returns only constructions in the specified domain' do
      engine.create_construction(**construction_params)
      engine.create_construction(form: 'run', meaning: 'motion', expression_type: :relational, domain: 'motion')
      results = engine.constructions_by_domain(domain: 'nature')
      expect(results.size).to eq(1)
      expect(results.first.domain).to eq('nature')
    end
  end

  describe '#constructions_by_type' do
    it 'returns only constructions with the specified expression_type' do
      engine.create_construction(**construction_params) # :nominal
      engine.create_construction(form: 'runs', meaning: 'action', expression_type: :relational, domain: 'action')
      results = engine.constructions_by_type(expression_type: :nominal)
      expect(results.size).to eq(1)
      expect(results.first.expression_type).to eq(:nominal)
    end

    it 'accepts string type and symbolizes it' do
      engine.create_construction(**construction_params)
      results = engine.constructions_by_type(expression_type: 'nominal')
      expect(results.size).to eq(1)
    end
  end

  describe '#most_used' do
    it 'returns constructions sorted by usage_count desc' do
      c1 = engine.create_construction(**construction_params)
      c2 = engine.create_construction(form: 'runs', meaning: 'action', expression_type: :relational, domain: 'action')
      3.times { engine.use_construction(construction_id: c1.id) }
      engine.use_construction(construction_id: c2.id)
      top = engine.most_used(limit: 2)
      expect(top.first).to eq(c1)
      expect(top.last).to eq(c2)
    end

    it 'respects the limit' do
      5.times { |i| engine.create_construction(form: "form#{i}", meaning: "m#{i}", expression_type: :nominal, domain: 'd') }
      expect(engine.most_used(limit: 3).size).to eq(3)
    end
  end

  describe '#most_activated' do
    it 'returns constructions sorted by activation desc' do
      c1 = engine.create_construction(**construction_params)
      c2 = engine.create_construction(form: 'x', meaning: 'y', expression_type: :nominal, domain: 'd', activation: 0.8)
      top = engine.most_activated(limit: 2)
      expect(top.first).to eq(c2)
      expect(top.last).to eq(c1)
    end
  end

  describe '#decay_all' do
    it 'reduces activation of all constructions' do
      c = engine.create_construction(**construction_params)
      original = c.activation
      engine.decay_all
      expect(c.activation).to be < original
    end
  end

  describe '#prune_inactive' do
    it 'removes constructions with activation <= 0.05' do
      c1 = engine.create_construction(**construction_params) # activation 0.3 — kept
      c2 = engine.create_construction(form: 'x', meaning: 'y', expression_type: :nominal, domain: 'd', activation: 0.05)
      engine.prune_inactive
      expect(engine.to_h[:constructions_count]).to eq(1)
      expect(engine.constructions_by_domain(domain: 'nature')).to include(c1)
      expect(engine.constructions_by_domain(domain: 'd')).not_to include(c2)
    end

    it 'does not remove constructions with activation above 0.05' do
      engine.create_construction(**construction_params)
      engine.prune_inactive
      expect(engine.to_h[:constructions_count]).to eq(1)
    end
  end

  describe '#to_h' do
    it 'returns counts' do
      engine.create_construction(**construction_params)
      engine.create_construal(**construal_params)
      h = engine.to_h
      expect(h[:constructions_count]).to eq(1)
      expect(h[:construals_count]).to eq(1)
      expect(h[:entrenched_count]).to eq(0)
    end
  end

  describe 'entrenchment via repeated use' do
    it 'tracks a construction becoming entrenched after 5 uses from default activation' do
      c = engine.create_construction(form: 'be', meaning: 'existence', expression_type: :relational, domain: 'core')
      expect(c.entrenched?).to be false
      5.times { engine.use_construction(construction_id: c.id) }
      expect(c.entrenched?).to be true
      expect(engine.entrenched_constructions).to include(c)
    end
  end
end
