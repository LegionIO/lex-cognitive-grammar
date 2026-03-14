# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveGrammar::Helpers::Construal do
  subject(:construal) do
    described_class.new(
      scene:       'cat on mat',
      perspective: 'observer',
      figure:      'cat',
      ground:      'mat'
    )
  end

  describe '#initialize' do
    it 'assigns a UUID id' do
      expect(construal.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'stores scene, perspective, figure, ground' do
      expect(construal.scene).to eq('cat on mat')
      expect(construal.perspective).to eq('observer')
      expect(construal.figure).to eq('cat')
      expect(construal.ground).to eq('mat')
    end

    it 'defaults specificity to :intermediate' do
      expect(construal.specificity).to eq(:intermediate)
    end

    it 'defaults scope to :local' do
      expect(construal.scope).to eq(:local)
    end

    it 'defaults dynamicity to 0.5' do
      expect(construal.dynamicity).to eq(0.5)
    end

    it 'defaults construction_id to nil' do
      expect(construal.construction_id).to be_nil
    end

    it 'sets created_at' do
      expect(construal.created_at).to be_a(Time)
    end

    it 'accepts optional construction_id' do
      c = described_class.new(
        scene: 's', perspective: 'p', figure: 'f', ground: 'g',
        construction_id: 'abc-123'
      )
      expect(c.construction_id).to eq('abc-123')
    end

    it 'clamps dynamicity to 0..1' do
      c = described_class.new(scene: 's', perspective: 'p', figure: 'f', ground: 'g', dynamicity: 1.5)
      expect(c.dynamicity).to eq(1.0)
    end

    it 'symbolizes specificity' do
      c = described_class.new(scene: 's', perspective: 'p', figure: 'f', ground: 'g', specificity: 'detailed')
      expect(c.specificity).to eq(:detailed)
    end

    it 'symbolizes scope' do
      c = described_class.new(scene: 's', perspective: 'p', figure: 'f', ground: 'g', scope: 'global')
      expect(c.scope).to eq(:global)
    end
  end

  describe '#prominent_element' do
    it 'returns the figure' do
      expect(construal.prominent_element).to eq('cat')
    end
  end

  describe '#background_element' do
    it 'returns the ground' do
      expect(construal.background_element).to eq('mat')
    end
  end

  describe '#detailed?' do
    it 'returns false for default :intermediate specificity' do
      expect(construal.detailed?).to be false
    end

    it 'returns true when specificity is :detailed' do
      c = described_class.new(scene: 's', perspective: 'p', figure: 'f', ground: 'g', specificity: :detailed)
      expect(c.detailed?).to be true
    end

    it 'returns false for :schematic' do
      c = described_class.new(scene: 's', perspective: 'p', figure: 'f', ground: 'g', specificity: :schematic)
      expect(c.detailed?).to be false
    end
  end

  describe '#global_scope?' do
    it 'returns false for default :local scope' do
      expect(construal.global_scope?).to be false
    end

    it 'returns true when scope is :global' do
      c = described_class.new(scene: 's', perspective: 'p', figure: 'f', ground: 'g', scope: :global)
      expect(c.global_scope?).to be true
    end
  end

  describe '#to_h' do
    it 'includes all expected keys' do
      h = construal.to_h
      expect(h).to include(:id, :scene, :perspective, :figure, :ground, :specificity, :scope, :dynamicity, :construction_id, :created_at)
    end

    it 'reflects assigned values' do
      h = construal.to_h
      expect(h[:scene]).to eq('cat on mat')
      expect(h[:figure]).to eq('cat')
      expect(h[:ground]).to eq('mat')
      expect(h[:specificity]).to eq(:intermediate)
      expect(h[:scope]).to eq(:local)
    end
  end
end
