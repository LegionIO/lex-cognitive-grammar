# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveGrammar do
  it 'has a version' do
    expect(Legion::Extensions::CognitiveGrammar::VERSION).to eq('0.1.0')
  end

  it 'defines CONSTRUAL_OPERATIONS' do
    expect(Legion::Extensions::CognitiveGrammar::Helpers::Constants::CONSTRUAL_OPERATIONS).to be_frozen
    expect(Legion::Extensions::CognitiveGrammar::Helpers::Constants::CONSTRUAL_OPERATIONS).to include(:perspective, :prominence, :specificity, :scope,
                                                                                                      :dynamicity)
  end

  it 'defines EXPRESSION_TYPES' do
    expect(Legion::Extensions::CognitiveGrammar::Helpers::Constants::EXPRESSION_TYPES).to include(:nominal, :relational, :clausal)
  end
end
