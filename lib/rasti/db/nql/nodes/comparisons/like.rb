module Rasti
  module DB
    module NQL
      module Nodes
        module Comparisons
          class Like < Base

            def to_filter
              Sequel.ilike(left.to_filter, right.value)
            end

          end
        end
      end
    end
  end
end