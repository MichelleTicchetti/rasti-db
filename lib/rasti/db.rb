require 'sequel'
require 'consty'
require 'time'
require 'timing'
require 'treetop'
require 'hierarchical_graph'
require 'class_config'
require 'hash_ext'
require 'multi_require'

module Rasti
  module DB
    
    extend MultiRequire
    extend ClassConfig

    require_relative 'db/query'
    require_relative_pattern  'db/relations/*'
    require_relative_pattern  'db/type_converters/postgres_types/*'
    require_relative_pattern  'db/**/*'

    attr_config :type_converters, []
    attr_config :nql_array_strategy, NQL::ArrayStrategies::NoneStrategy

    def self.to_db(db, collection_name, attribute_name, value)
      type_converters.inject(value) do |result, type_converter|
        type_converter.to_db db, collection_name, attribute_name, result
      end
    end

    def self.from_db(value)
      type_converters.inject(value) do |result, type_converter|
        type_converter.from_db result
      end
    end

  end
end