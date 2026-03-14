# frozen_string_literal: true

require 'legion/extensions/cognitive_grammar/helpers/constants'
require 'legion/extensions/cognitive_grammar/helpers/construction'
require 'legion/extensions/cognitive_grammar/helpers/construal'
require 'legion/extensions/cognitive_grammar/helpers/grammar_engine'
require 'legion/extensions/cognitive_grammar/runners/cognitive_grammar'

module Legion
  module Extensions
    module CognitiveGrammar
      class Client
        include Runners::CognitiveGrammar

        def initialize(**)
          @engine = Helpers::GrammarEngine.new
        end

        private

        attr_reader :engine
      end
    end
  end
end
