# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveGrammar::Helpers::Constants do
  subject(:mod) { described_class }

  it 'freezes CONSTRUAL_OPERATIONS' do
    expect(mod::CONSTRUAL_OPERATIONS).to be_frozen
    expect(mod::CONSTRUAL_OPERATIONS).to eq(%i[perspective prominence specificity scope dynamicity])
  end

  it 'freezes PROMINENCE_TYPES' do
    expect(mod::PROMINENCE_TYPES).to be_frozen
    expect(mod::PROMINENCE_TYPES).to eq(%i[figure ground])
  end

  it 'freezes SPECIFICITY_LEVELS' do
    expect(mod::SPECIFICITY_LEVELS).to eq(%i[schematic intermediate detailed])
  end

  it 'freezes SCOPE_LEVELS' do
    expect(mod::SCOPE_LEVELS).to eq(%i[immediate local global])
  end

  it 'freezes EXPRESSION_TYPES' do
    expect(mod::EXPRESSION_TYPES).to eq(%i[nominal relational clausal])
  end

  describe 'ACTIVATION_LABELS' do
    it 'maps 0.9 to :entrenched' do
      label = mod::ACTIVATION_LABELS.find { |range, _| range.cover?(0.9) }&.last
      expect(label).to eq(:entrenched)
    end

    it 'maps 0.7 to :conventional' do
      label = mod::ACTIVATION_LABELS.find { |range, _| range.cover?(0.7) }&.last
      expect(label).to eq(:conventional)
    end

    it 'maps 0.5 to :familiar' do
      label = mod::ACTIVATION_LABELS.find { |range, _| range.cover?(0.5) }&.last
      expect(label).to eq(:familiar)
    end

    it 'maps 0.3 to :novel' do
      label = mod::ACTIVATION_LABELS.find { |range, _| range.cover?(0.3) }&.last
      expect(label).to eq(:novel)
    end

    it 'maps 0.1 to :ad_hoc' do
      label = mod::ACTIVATION_LABELS.find { |range, _| range.cover?(0.1) }&.last
      expect(label).to eq(:ad_hoc)
    end
  end

  it 'sets numeric limits' do
    expect(mod::MAX_CONSTRUCTIONS).to eq(200)
    expect(mod::MAX_CONSTRUALS).to eq(500)
    expect(mod::MAX_HISTORY).to eq(500)
  end

  it 'sets activation constants' do
    expect(mod::DEFAULT_ACTIVATION).to eq(0.3)
    expect(mod::ACTIVATION_BOOST).to eq(0.1)
    expect(mod::ACTIVATION_DECAY).to eq(0.02)
    expect(mod::ENTRENCHMENT_THRESHOLD).to eq(0.8)
  end
end
