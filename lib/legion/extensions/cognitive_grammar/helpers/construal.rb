# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module CognitiveGrammar
      module Helpers
        class Construal
          include Constants

          attr_reader :id, :scene, :perspective, :figure, :ground, :specificity,
                      :scope, :dynamicity, :construction_id, :created_at

          def initialize(scene:, perspective:, figure:, ground:,
                         specificity: :intermediate, scope: :local,
                         dynamicity: 0.5, construction_id: nil)
            @id              = SecureRandom.uuid
            @scene           = scene
            @perspective     = perspective
            @figure          = figure
            @ground          = ground
            @specificity     = specificity.to_sym
            @scope           = scope.to_sym
            @dynamicity      = dynamicity.clamp(0.0, 1.0)
            @construction_id = construction_id
            @created_at      = Time.now.utc
          end

          def prominent_element
            @figure
          end

          def background_element
            @ground
          end

          def detailed?
            @specificity == :detailed
          end

          def global_scope?
            @scope == :global
          end

          def to_h
            {
              id:              @id,
              scene:           @scene,
              perspective:     @perspective,
              figure:          @figure,
              ground:          @ground,
              specificity:     @specificity,
              scope:           @scope,
              dynamicity:      @dynamicity,
              construction_id: @construction_id,
              created_at:      @created_at
            }
          end
        end
      end
    end
  end
end
