# frozen_string_literal: true

require 'legion/extensions/cognitive_grammar/version'
require 'legion/extensions/cognitive_grammar/helpers/constants'
require 'legion/extensions/cognitive_grammar/helpers/construction'
require 'legion/extensions/cognitive_grammar/helpers/construal'
require 'legion/extensions/cognitive_grammar/helpers/grammar_engine'
require 'legion/extensions/cognitive_grammar/runners/cognitive_grammar'
require 'legion/extensions/cognitive_grammar/client'

module Legion
  module Extensions
    module CognitiveGrammar
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
