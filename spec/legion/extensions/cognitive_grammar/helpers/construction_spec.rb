# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveGrammar::Helpers::Construction do
  subject(:construction) do
    described_class.new(
      form:            'the cat',
      meaning:         'definite feline entity',
      expression_type: :nominal,
      domain:          'linguistics'
    )
  end

  describe '#initialize' do
    it 'assigns a UUID id' do
      expect(construction.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'stores form and meaning' do
      expect(construction.form).to eq('the cat')
      expect(construction.meaning).to eq('definite feline entity')
    end

    it 'symbolizes expression_type' do
      expect(construction.expression_type).to eq(:nominal)
    end

    it 'defaults activation to DEFAULT_ACTIVATION' do
      expect(construction.activation).to eq(0.3)
    end

    it 'starts with zero usage_count' do
      expect(construction.usage_count).to eq(0)
    end

    it 'sets domain' do
      expect(construction.domain).to eq('linguistics')
    end

    it 'sets created_at to a Time' do
      expect(construction.created_at).to be_a(Time)
    end
  end

  describe '#use!' do
    it 'increments usage_count' do
      construction.use!
      expect(construction.usage_count).to eq(1)
    end

    it 'boosts activation by ACTIVATION_BOOST' do
      construction.use!
      expect(construction.activation).to be_within(0.001).of(0.4)
    end

    it 'caps activation at 1.0' do
      c = described_class.new(form: 'x', meaning: 'y', expression_type: :nominal, domain: 'd', activation: 0.95)
      c.use!
      expect(c.activation).to eq(1.0)
    end

    it 'returns self for chaining' do
      expect(construction.use!).to eq(construction)
    end

    it 'accumulates usage on repeated calls' do
      5.times { construction.use! }
      expect(construction.usage_count).to eq(5)
    end
  end

  describe '#decay!' do
    it 'reduces activation by ACTIVATION_DECAY' do
      construction.decay!
      expect(construction.activation).to be_within(0.001).of(0.28)
    end

    it 'floors activation at 0.0' do
      c = described_class.new(form: 'x', meaning: 'y', expression_type: :nominal, domain: 'd', activation: 0.01)
      c.decay!
      expect(c.activation).to eq(0.0)
    end

    it 'returns self for chaining' do
      expect(construction.decay!).to eq(construction)
    end
  end

  describe '#entrenched?' do
    it 'returns false when activation is below threshold' do
      expect(construction.entrenched?).to be false
    end

    it 'returns true when activation reaches ENTRENCHMENT_THRESHOLD' do
      c = described_class.new(form: 'x', meaning: 'y', expression_type: :nominal, domain: 'd', activation: 0.8)
      expect(c.entrenched?).to be true
    end

    it 'returns true when activation exceeds threshold' do
      c = described_class.new(form: 'x', meaning: 'y', expression_type: :nominal, domain: 'd', activation: 0.95)
      expect(c.entrenched?).to be true
    end

    it 'becomes entrenched after enough use! calls' do
      c = described_class.new(form: 'run', meaning: 'motion', expression_type: :relational, domain: 'motion')
      # Start at 0.3, each use! adds 0.1 → need 5 uses to reach 0.8
      5.times { c.use! }
      expect(c.entrenched?).to be true
    end
  end

  describe '#activation_label' do
    it 'returns :ad_hoc for low activation' do
      c = described_class.new(form: 'x', meaning: 'y', expression_type: :nominal, domain: 'd', activation: 0.1)
      expect(c.activation_label).to eq(:ad_hoc)
    end

    it 'returns :novel for activation 0.3' do
      expect(construction.activation_label).to eq(:novel)
    end

    it 'returns :familiar for activation 0.5' do
      c = described_class.new(form: 'x', meaning: 'y', expression_type: :nominal, domain: 'd', activation: 0.5)
      expect(c.activation_label).to eq(:familiar)
    end

    it 'returns :conventional for activation 0.7' do
      c = described_class.new(form: 'x', meaning: 'y', expression_type: :nominal, domain: 'd', activation: 0.7)
      expect(c.activation_label).to eq(:conventional)
    end

    it 'returns :entrenched for activation >= 0.8' do
      c = described_class.new(form: 'x', meaning: 'y', expression_type: :nominal, domain: 'd', activation: 0.8)
      expect(c.activation_label).to eq(:entrenched)
    end
  end

  describe '#to_h' do
    it 'returns a hash with all expected keys' do
      h = construction.to_h
      expect(h).to include(:id, :form, :meaning, :expression_type, :activation, :usage_count, :domain, :entrenched, :activation_label, :created_at)
    end

    it 'reflects current state' do
      construction.use!
      h = construction.to_h
      expect(h[:usage_count]).to eq(1)
      expect(h[:activation]).to be > 0.3
    end

    it 'includes entrenched flag' do
      expect(construction.to_h[:entrenched]).to be false
    end
  end
end
