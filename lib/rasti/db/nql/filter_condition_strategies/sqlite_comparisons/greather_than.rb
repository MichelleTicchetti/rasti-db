module Rasti
  module DB
    module NQL
      module FilterConditionStrategies
        module SQLiteComparisons
          class GreatherThan < Base
            class << self

              def for_array(attribute, arguments)
                raise TypedComparisonNotSupported.new '>', 'array'
              end

              private

              def common_filter_method(attribute, argument)
                attribute > argument
              end

            end
          end
        end
      end
    end
  end
end