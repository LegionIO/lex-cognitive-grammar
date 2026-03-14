# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveGrammar
      module Runners
        module CognitiveGrammar
          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)

          def create_grammar_construction(form:, meaning:, expression_type:, domain:, **)
            construction = engine.create_construction(
              form:            form,
              meaning:         meaning,
              expression_type: expression_type,
              domain:          domain
            )
            Legion::Logging.debug "[cognitive_grammar] created construction form=#{form} type=#{expression_type} domain=#{domain}"
            construction.to_h
          end

          def create_grammar_construal(scene:, perspective:, figure:, ground:, # rubocop:disable Metrics/ParameterLists
                                       specificity: :intermediate, scope: :local,
                                       dynamicity: 0.5, construction_id: nil, **)
            construal = engine.create_construal(
              scene:           scene,
              perspective:     perspective,
              figure:          figure,
              ground:          ground,
              specificity:     specificity,
              scope:           scope,
              dynamicity:      dynamicity,
              construction_id: construction_id
            )
            Legion::Logging.debug "[cognitive_grammar] created construal scene=#{scene} figure=#{figure}"
            construal.to_h
          end

          def use_grammar_construction(construction_id:, **)
            construction = engine.use_construction(construction_id: construction_id)
            return { found: false, construction_id: construction_id } unless construction

            msg = "[cognitive_grammar] used construction id=#{construction_id[0..7]} " \
                  "usage_count=#{construction.usage_count} activation=#{construction.activation.round(3)}"
            Legion::Logging.debug msg
            { found: true, construction: construction.to_h }
          end

          def construals_for_scene_report(scene:, **)
            construals = engine.construals_for_scene(scene: scene)
            Legion::Logging.debug "[cognitive_grammar] construals_for_scene scene=#{scene} count=#{construals.size}"
            { scene: scene, count: construals.size, construals: construals.map(&:to_h) }
          end

          def entrenched_constructions_report(**)
            constructions = engine.entrenched_constructions
            Legion::Logging.debug "[cognitive_grammar] entrenched constructions count=#{constructions.size}"
            { count: constructions.size, constructions: constructions.map(&:to_h) }
          end

          def constructions_by_domain_report(domain:, **)
            constructions = engine.constructions_by_domain(domain: domain)
            Legion::Logging.debug "[cognitive_grammar] constructions_by_domain domain=#{domain} count=#{constructions.size}"
            { domain: domain, count: constructions.size, constructions: constructions.map(&:to_h) }
          end

          def most_used_constructions(limit: 5, **)
            constructions = engine.most_used(limit: limit)
            Legion::Logging.debug "[cognitive_grammar] most_used limit=#{limit} count=#{constructions.size}"
            { limit: limit, count: constructions.size, constructions: constructions.map(&:to_h) }
          end

          def update_cognitive_grammar(**)
            engine.decay_all
            pruned = engine.prune_inactive
            stats  = engine.to_h
            Legion::Logging.debug "[cognitive_grammar] update: pruned=#{pruned} remaining=#{stats[:constructions_count]}"
            { pruned: pruned, stats: stats }
          end

          def cognitive_grammar_stats(**)
            stats = engine.to_h
            Legion::Logging.debug "[cognitive_grammar] stats constructions=#{stats[:constructions_count]} construals=#{stats[:construals_count]}"
            stats
          end

          private

          def engine
            @engine ||= Helpers::GrammarEngine.new
          end
        end
      end
    end
  end
end
