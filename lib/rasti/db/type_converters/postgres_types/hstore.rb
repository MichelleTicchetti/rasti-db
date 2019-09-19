module Rasti
  module DB
    module TypeConverters
      module PostgresTypes
        class HStore

          class << self

            def column_type_regex
              /^hstore$/
            end

            def to_db(value, sub_type)
              Sequel.hstore value
            end

            def db_classes
              [Sequel::Postgres::HStore]
            end

            def from_db(object)
              object.to_h
            end

          end

        end
      end
    end
  end
end