# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveGrammar
      module Helpers
        module Constants
          CONSTRUAL_OPERATIONS = %i[perspective prominence specificity scope dynamicity].freeze
          PROMINENCE_TYPES     = %i[figure ground].freeze
          SPECIFICITY_LEVELS   = %i[schematic intermediate detailed].freeze
          SCOPE_LEVELS         = %i[immediate local global].freeze
          EXPRESSION_TYPES     = %i[nominal relational clausal].freeze

          ACTIVATION_LABELS = {
            (0.8..)     => :entrenched,
            (0.6...0.8) => :conventional,
            (0.4...0.6) => :familiar,
            (0.2...0.4) => :novel,
            (..0.2)     => :ad_hoc
          }.freeze

          MAX_CONSTRUCTIONS   = 200
          MAX_CONSTRUALS      = 500
          MAX_HISTORY         = 500

          DEFAULT_ACTIVATION      = 0.3
          ACTIVATION_BOOST        = 0.1
          ACTIVATION_DECAY        = 0.02
          ENTRENCHMENT_THRESHOLD  = 0.8
        end
      end
    end
  end
end
