# lex-cognitive-grammar

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-cognitive-grammar`

## Purpose

Models cognitive grammar — the structured mental constructions through which meaning is assembled. Based on Cognitive Linguistics: constructions are symbolic units (form-meaning pairings) stored in a construction grammar network. Construals represent specific applications of constructions to scenes. Each use of a construction strengthens its activation via Exponential Moving Average. Constructions that exceed the entrenchment threshold (0.8) become automatic. A periodic maintenance actor decays unused constructions over time.

## Gem Info

| Field | Value |
|---|---|
| Gem name | `lex-cognitive-grammar` |
| Version | `0.1.0` |
| Namespace | `Legion::Extensions::CognitiveGrammar` |
| Ruby | `>= 3.4` |
| License | MIT |
| GitHub | https://github.com/LegionIO/lex-cognitive-grammar |

## File Structure

```
lib/legion/extensions/cognitive_grammar/
  cognitive_grammar.rb              # Top-level require
  version.rb                        # VERSION = '0.1.0'
  client.rb                         # Client class
  helpers/
    constants.rb                    # Construal operations, prominence types, activation labels, thresholds
    construction.rb                 # Construction value object (form-meaning unit)
    construal.rb                    # Construal value object (specific scene interpretation)
    grammar_engine.rb               # Engine: constructions, construals, activation, decay
  runners/
    cognitive_grammar.rb            # Runner module
```

## Key Constants

| Constant | Value | Meaning |
|---|---|---|
| `CONSTRUAL_OPERATIONS` | array | Mental operations: `profiling`, `trajector_landmark`, `figure_ground`, `scope`, `perspective`, `dynamism` |
| `PROMINENCE_TYPES` | array | `[:trajector, :landmark, :profiled, :active_zone, :reference_point, :base]` |
| `EXPRESSION_TYPES` | array | `[:nominal, :verbal, :clausal, :prepositional, :adjectival, :constructional]` |
| `MAX_CONSTRUCTIONS` | 200 | Construction store cap |
| `MAX_CONSTRUALS` | 500 | Construal history cap |
| `DEFAULT_ACTIVATION` | 0.3 | Starting activation for new constructions |
| `ENTRENCHMENT_THRESHOLD` | 0.8 | Activation above this = entrenched (automatic) |
| `ACTIVATION_LABELS` | hash | `entrenched` (0.8+) through `dormant` |

## Helpers

### `Construction`

A symbolic form-meaning unit in the grammar network.

- `initialize(name:, form:, meaning:, domain:, activation: DEFAULT_ACTIVATION, construction_id: nil)`
- `use!(alpha: 0.2)` — updates activation via EMA; increments use count
- `decay!(rate: 0.01)` — decreases activation
- `entrenched?` — activation >= `ENTRENCHMENT_THRESHOLD`
- `inactive?` — activation below threshold
- `to_h`

### `Construal`

A specific application of a construction to a scene.

- `initialize(construction_id:, scene:, operation:, prominence:, construal_id: nil)`
- `to_h`

### `GrammarEngine`

- `create_construction(name:, form:, meaning:, domain:)` — returns `{ created:, construction_id:, construction: }` or capacity error
- `create_construal(construction_id:, scene:, operation:, prominence:)` — validates construction exists; appends to construal ring buffer
- `use_construction(construction_id:)` — fires EMA update; returns before/after activation + entrenchment state
- `entrenched_constructions(limit: 20)` — sorted by activation descending
- `decay_all(rate: 0.01)` — decays all constructions
- `prune_inactive(threshold: 0.05)` — removes constructions below activation floor
- `constructions_by_domain` — groups by domain
- `most_used(limit: 10)` — sorted by use_count
- `grammar_report` — full stats

## Runners

**Module**: `Legion::Extensions::CognitiveGrammar::Runners::CognitiveGrammar`

| Method | Key Args | Returns |
|---|---|---|
| `create_grammar_construction` | `name:`, `form:`, `meaning:`, `domain:` | `{ success:, construction_id:, construction: }` |
| `create_grammar_construal` | `construction_id:`, `scene:`, `operation:`, `prominence:` | `{ success:, construal_id:, construal: }` |
| `use_grammar_construction` | `construction_id:` | `{ success:, before:, after:, entrenched: }` |
| `construals_for_scene_report` | `scene:` | `{ success:, construals: }` |
| `entrenched_constructions_report` | `limit: 20` | `{ success:, constructions: }` |
| `constructions_by_domain_report` | — | `{ success:, domains: }` |
| `most_used_constructions` | `limit: 10` | `{ success:, constructions: }` |
| `update_cognitive_grammar` | — | `{ success:, decayed: }` — runs decay pass |
| `cognitive_grammar_stats` | — | engine `to_h` |

Private: `grammar_engine` — memoized `GrammarEngine`. Logs via `log_debug` helper.

## Integration Points

- **`lex-tick`**: `update_cognitive_grammar` is the maintenance operation; can be wired into `memory_consolidation` or a dedicated grammar-maintenance phase.
- **`lex-memory`**: Construction activation mirrors memory trace strength. Entrenched constructions could be co-stored as procedural memory traces in lex-memory for cross-extension retrieval.
- **`lex-cognitive-flexibility`**: Switching task sets may require activating constructions appropriate to the new domain. Grammar constructions and task-set rules operate at complementary abstraction levels.

## Development Notes

- `use_construction` updates activation via EMA on each call. Frequent use rapidly entrenches a construction; infrequent use combined with periodic `decay_all` calls keeps the grammar network trimmed.
- `prune_inactive` is destructive — constructions removed cannot be recovered. Call with a conservative threshold.
- `construals_for_scene_report` searches the construal buffer for exact scene string matches.
- In-memory only.

---

**Maintained By**: Matthew Iverson (@Esity)
