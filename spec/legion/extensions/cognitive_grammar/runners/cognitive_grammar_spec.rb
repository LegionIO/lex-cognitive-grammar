# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveGrammar::Runners::CognitiveGrammar do
  subject(:runner) do
    Class.new do
      include Legion::Extensions::CognitiveGrammar::Runners::CognitiveGrammar

      def engine
        @engine ||= Legion::Extensions::CognitiveGrammar::Helpers::GrammarEngine.new
      end
    end.new
  end

  let(:construction_params) do
    { form: 'she runs', meaning: 'agent motion predication', expression_type: :clausal, domain: 'motion' }
  end

  describe '#create_grammar_construction' do
    it 'returns a hash with construction data' do
      result = runner.create_grammar_construction(**construction_params)
      expect(result).to include(:id, :form, :meaning, :expression_type, :activation, :usage_count)
    end

    it 'includes the provided form' do
      result = runner.create_grammar_construction(**construction_params)
      expect(result[:form]).to eq('she runs')
    end

    it 'starts with default activation' do
      result = runner.create_grammar_construction(**construction_params)
      expect(result[:activation]).to eq(0.3)
    end
  end

  describe '#create_grammar_construal' do
    it 'returns a hash with construal data' do
      result = runner.create_grammar_construal(
        scene: 'bird on branch', perspective: 'worm-eye', figure: 'bird', ground: 'branch'
      )
      expect(result).to include(:id, :scene, :perspective, :figure, :ground, :specificity, :scope, :dynamicity)
    end

    it 'uses defaults for optional params' do
      result = runner.create_grammar_construal(
        scene: 's', perspective: 'p', figure: 'f', ground: 'g'
      )
      expect(result[:specificity]).to eq(:intermediate)
      expect(result[:scope]).to eq(:local)
      expect(result[:dynamicity]).to eq(0.5)
    end

    it 'respects provided specificity, scope, dynamicity' do
      result = runner.create_grammar_construal(
        scene: 's', perspective: 'p', figure: 'f', ground: 'g',
        specificity: :detailed, scope: :global, dynamicity: 0.9
      )
      expect(result[:specificity]).to eq(:detailed)
      expect(result[:scope]).to eq(:global)
      expect(result[:dynamicity]).to eq(0.9)
    end
  end

  describe '#use_grammar_construction' do
    it 'returns found: false for unknown id' do
      result = runner.use_grammar_construction(construction_id: 'nonexistent')
      expect(result[:found]).to be false
    end

    it 'returns found: true with updated construction' do
      created = runner.create_grammar_construction(**construction_params)
      result  = runner.use_grammar_construction(construction_id: created[:id])
      expect(result[:found]).to be true
      expect(result[:construction][:usage_count]).to eq(1)
    end

    it 'increases activation on use' do
      created = runner.create_grammar_construction(**construction_params)
      result  = runner.use_grammar_construction(construction_id: created[:id])
      expect(result[:construction][:activation]).to be > created[:activation]
    end
  end

  describe '#construals_for_scene_report' do
    it 'returns empty construals for unknown scene' do
      result = runner.construals_for_scene_report(scene: 'unknown')
      expect(result[:count]).to eq(0)
      expect(result[:construals]).to eq([])
    end

    it 'returns matching construals' do
      runner.create_grammar_construal(scene: 'cat on mat', perspective: 'p', figure: 'cat', ground: 'mat')
      result = runner.construals_for_scene_report(scene: 'cat on mat')
      expect(result[:count]).to eq(1)
      expect(result[:construals].first[:figure]).to eq('cat')
    end

    it 'includes the scene in the result' do
      result = runner.construals_for_scene_report(scene: 'test scene')
      expect(result[:scene]).to eq('test scene')
    end
  end

  describe '#entrenched_constructions_report' do
    it 'returns empty when none entrenched' do
      runner.create_grammar_construction(**construction_params)
      result = runner.entrenched_constructions_report
      expect(result[:count]).to eq(0)
    end

    it 'returns entrenched constructions after enough uses' do
      created = runner.create_grammar_construction(**construction_params)
      5.times { runner.use_grammar_construction(construction_id: created[:id]) }
      result = runner.entrenched_constructions_report
      expect(result[:count]).to eq(1)
      expect(result[:constructions].first[:entrenched]).to be true
    end
  end

  describe '#constructions_by_domain_report' do
    it 'returns constructions for the given domain' do
      runner.create_grammar_construction(**construction_params) # domain: 'motion'
      runner.create_grammar_construction(form: 'the', meaning: 'def', expression_type: :nominal, domain: 'grammar')
      result = runner.constructions_by_domain_report(domain: 'motion')
      expect(result[:domain]).to eq('motion')
      expect(result[:count]).to eq(1)
    end
  end

  describe '#most_used_constructions' do
    it 'returns constructions sorted by usage_count' do
      c1 = runner.create_grammar_construction(**construction_params)
      c2 = runner.create_grammar_construction(form: 'the', meaning: 'def', expression_type: :nominal, domain: 'grammar')
      3.times { runner.use_grammar_construction(construction_id: c1[:id]) }
      runner.use_grammar_construction(construction_id: c2[:id])
      result = runner.most_used_constructions(limit: 2)
      expect(result[:constructions].first[:form]).to eq('she runs')
    end

    it 'defaults limit to 5' do
      result = runner.most_used_constructions
      expect(result[:limit]).to eq(5)
    end
  end

  describe '#update_cognitive_grammar' do
    it 'returns stats with pruned count' do
      runner.create_grammar_construction(**construction_params)
      result = runner.update_cognitive_grammar
      expect(result).to include(:pruned, :stats)
      expect(result[:stats]).to include(:constructions_count, :construals_count)
    end

    it 'removes constructions whose activation decays to <= 0.05' do
      # create with very low activation that will decay below threshold after one pass
      c = runner.create_grammar_construction(
        form: 'x', meaning: 'y', expression_type: :nominal, domain: 'd'
      )
      # Manually decay the underlying construction to near-zero
      engine = runner.send(:engine)
      const  = engine.instance_variable_get(:@constructions)[c[:id]]
      const.instance_variable_set(:@activation, 0.05)
      result = runner.update_cognitive_grammar
      expect(result[:pruned]).to be >= 1
    end
  end

  describe '#cognitive_grammar_stats' do
    it 'returns hash with counts' do
      runner.create_grammar_construction(**construction_params)
      runner.create_grammar_construal(scene: 's', perspective: 'p', figure: 'f', ground: 'g')
      stats = runner.cognitive_grammar_stats
      expect(stats[:constructions_count]).to eq(1)
      expect(stats[:construals_count]).to eq(1)
    end
  end

  describe 'activation decay after update_cognitive_grammar' do
    it 'reduces activation of all constructions' do
      created = runner.create_grammar_construction(**construction_params)
      original_activation = created[:activation]
      runner.update_cognitive_grammar
      runner.cognitive_grammar_stats
      # activation should have decreased (decay was applied)
      engine = runner.send(:engine)
      const  = engine.instance_variable_get(:@constructions)[created[:id]]
      expect(const.activation).to be < original_activation
    end
  end
end
