# lex-cognitive-grammar

Cognitive grammar construction network for brain-modeled agentic AI in the LegionIO ecosystem.

## What It Does

Models the mental grammar through which meaning is assembled. Constructions are symbolic form-meaning units that activate with use and decay when dormant. Construals represent specific applications of constructions to scenes using cognitive operations (profiling, figure-ground, scope, perspective). Each use of a construction strengthens its activation via Exponential Moving Average. Once activation crosses the entrenchment threshold (0.8), the construction becomes automatic. A periodic decay pass prunes underused constructions from the network.

## Usage

```ruby
require 'legion/extensions/cognitive_grammar'

client = Legion::Extensions::CognitiveGrammar::Client.new

# Create a form-meaning construction
result = client.create_grammar_construction(
  name: 'caused_motion',
  form: '[Agent VERB Theme Path]',
  meaning: 'agent causes theme to move along path',
  domain: :motion
)
construction_id = result[:construction_id]

# Apply it to a scene (construal)
client.create_grammar_construal(
  construction_id: construction_id,
  scene: 'pushing the idea forward',
  operation: :figure_ground,
  prominence: :trajector
)

# Record a use — updates EMA activation
client.use_grammar_construction(construction_id: construction_id)
# => { success: true, before: 0.3, after: 0.37, entrenched: false }

# Check which constructions are entrenched
client.entrenched_constructions_report(limit: 10)
# => { success: true, constructions: [...] }

# Periodic decay maintenance
client.update_cognitive_grammar
# => { success: true, decayed: 1 }
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
