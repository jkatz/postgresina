module Postgresina

  module Query

    class Query

      class QueryError < RuntimeError; end

      class <<self

        def and(*args)
          [:and, args]
        end

        def or(*args)
          [:or, args]
        end

      end

    private

      def parse_conjunctions(conjunctions)
        sql = ''
        conjunction, statements = conjunctions
        case conjunction
        when :and
          sql += '('
          list = []
          statements.each do |statement|
            case statement
            when String
              list << statement
            when Array
              list << parse_conjunctions(statement)
            end
          end
          sql += list.join(' AND ')
          sql += ')'
        when :or
          sql += '('
          list = []
          statements.each do |statement|
            case statement
            when String
              list << statement
            when Array
              list << parse_conjunctions(statement)
            end
          end
          sql += list.join(' OR ')
          sql += ')'
        end
      end

    end

  end

end