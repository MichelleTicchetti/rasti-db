module Rasti
  module DB
    module ComputedFields
      class Relation

        def initialize(value:, relation:, type:, fields:, foreign_key:)
          @value = value
          @relation = relation
          @type = type
          @fields = fields
          @foreign_key = foreign_key
        end

        def apply_to(dataset, name)
          dataset.join_table(type, query_to(name), foreign_key => :id)
        end

        private

        attr_reader :value, :relation, :type, :fields, :foreign_key

        def query_to(name)
          relation.select_append(value.as(:value), *fields)
                  .group(foreign_key)
                  .as(name)
        end

      end
    end
  end
end