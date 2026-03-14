# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveGrammar
      module Helpers
        class GrammarEngine
          include Constants

          def initialize
            @constructions = {}
            @construals    = {}
          end

          def create_construction(form:, meaning:, expression_type:, domain:, activation: DEFAULT_ACTIVATION)
            prune_constructions_if_needed
            construction = Construction.new(
              form:            form,
              meaning:         meaning,
              expression_type: expression_type,
              domain:          domain,
              activation:      activation
            )
            @constructions[construction.id] = construction
            construction
          end

          def create_construal(scene:, perspective:, figure:, ground:,
                               specificity: :intermediate, scope: :local,
                               dynamicity: 0.5, construction_id: nil)
            prune_construals_if_needed
            construal = Construal.new(
              scene:           scene,
              perspective:     perspective,
              figure:          figure,
              ground:          ground,
              specificity:     specificity,
              scope:           scope,
              dynamicity:      dynamicity,
              construction_id: construction_id
            )
            @construals[construal.id] = construal
            construal
          end

          def use_construction(construction_id:)
            construction = @constructions[construction_id]
            return nil unless construction

            construction.use!
          end

          def construals_for_scene(scene:)
            @construals.values.select { |c| c.scene == scene }
          end

          def entrenched_constructions
            @constructions.values.select(&:entrenched?)
          end

          def constructions_by_domain(domain:)
            @constructions.values.select { |c| c.domain == domain }
          end

          def constructions_by_type(expression_type:)
            type = expression_type.to_sym
            @constructions.values.select { |c| c.expression_type == type }
          end

          def most_used(limit: 5)
            @constructions.values.sort_by { |c| -c.usage_count }.first(limit)
          end

          def most_activated(limit: 5)
            @constructions.values.sort_by { |c| -c.activation }.first(limit)
          end

          def decay_all
            @constructions.each_value(&:decay!)
          end

          def prune_inactive
            before = @constructions.size
            @constructions.delete_if { |_, c| c.activation <= 0.05 }
            before - @constructions.size
          end

          def to_h
            {
              constructions_count: @constructions.size,
              construals_count:    @construals.size,
              entrenched_count:    entrenched_constructions.size
            }
          end

          private

          def prune_constructions_if_needed
            return if @constructions.size < MAX_CONSTRUCTIONS

            oldest = @constructions.values.min_by(&:activation)
            @constructions.delete(oldest.id) if oldest
          end

          def prune_construals_if_needed
            return if @construals.size < MAX_CONSTRUALS

            oldest = @construals.values.min_by(&:created_at)
            @construals.delete(oldest.id) if oldest
          end
        end
      end
    end
  end
end
