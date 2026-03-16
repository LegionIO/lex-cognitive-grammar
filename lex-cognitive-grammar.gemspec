# frozen_string_literal: true

require_relative 'lib/legion/extensions/cognitive_grammar/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-cognitive-grammar'
  spec.version       = Legion::Extensions::CognitiveGrammar::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Cognitive Grammar'
  spec.description   = 'Langacker-inspired cognitive grammar engine for LegionIO — construal operations, construction entrenchment, and meaning as construal'
  spec.homepage      = 'https://github.com/LegionIO/lex-cognitive-grammar'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']        = spec.homepage
  spec.metadata['source_code_uri']     = 'https://github.com/LegionIO/lex-cognitive-grammar'
  spec.metadata['documentation_uri']   = 'https://github.com/LegionIO/lex-cognitive-grammar'
  spec.metadata['changelog_uri']       = 'https://github.com/LegionIO/lex-cognitive-grammar'
  spec.metadata['bug_tracker_uri']     = 'https://github.com/LegionIO/lex-cognitive-grammar/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']
  spec.add_development_dependency 'legion-gaia'
end
