# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module CognitiveGrammar
      module Helpers
        class Construction
          include Constants

          attr_reader :id, :form, :meaning, :expression_type, :usage_count, :domain, :created_at
          attr_accessor :activation

          def initialize(form:, meaning:, expression_type:, domain:, activation: DEFAULT_ACTIVATION)
            @id              = SecureRandom.uuid
            @form            = form
            @meaning         = meaning
            @expression_type = expression_type.to_sym
            @activation      = activation.clamp(0.0, 1.0)
            @usage_count     = 0
            @domain          = domain
            @created_at      = Time.now.utc
          end

          def use!
            @usage_count += 1
            @activation = [@activation + ACTIVATION_BOOST, 1.0].min.round(10)
            self
          end

          def decay!
            @activation = [@activation - ACTIVATION_DECAY, 0.0].max
            self
          end

          def entrenched?
            @activation >= ENTRENCHMENT_THRESHOLD
          end

          def activation_label
            match = ACTIVATION_LABELS.find { |range, _| range.cover?(@activation) }
            match ? match.last : :ad_hoc
          end

          def to_h
            {
              id:               @id,
              form:             @form,
              meaning:          @meaning,
              expression_type:  @expression_type,
              activation:       @activation,
              usage_count:      @usage_count,
              domain:           @domain,
              entrenched:       entrenched?,
              activation_label: activation_label,
              created_at:       @created_at
            }
          end
        end
      end
    end
  end
end
