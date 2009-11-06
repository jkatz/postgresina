module Postgresina

  module Query

    class Select < Query

      class SelectError < QueryError; end

      # select.from('users').where('id = 1').and(name = 'bob')
      # select.from('users').where('id = 1').and(name = 'bob')

      def initialize
        @joins = []
      end

      def from(from)
        @from = from
        self
      end

      def join(table, conditions)
        add_join('JOIN', table, conditions)
      end

      def left_outer_join(table, conditions)
        add_join('LEFT OUTER JOIN', table, conditions)
      end

      def limit(limit)
        @limit = limit
        self
      end

      def offset(offset)
        @offset = offset
        self
      end

      def order_by(order)
        @order_by = order
        self
      end

      def to_sql
        sql = "SELECT *"
        sql += " FROM #{@from}" if @from
        sql += prepare_joins if @joins.any?
        sql += prepare_conditions if @where
        sql += " ORDER BY #{@order_by}" if @order_by
        sql += " LIMIT #{@limit}" if @limit
        sql += " OFFSET #{@offset}" if @offset
        sql
      end

      # need to handle:
      # WHERE cond1 AND cond2 AND ...
      # WHERE a IN (SELECT ...)
      # 
      def where(where)
        @where = where
        self
      end

    private

      def add_join(type, table, conditions)
        @joins << { :table => table, :type => type, :conditions => conditions }
        self
      end

      def prepare_conditions
        sql = ''
        case @where
        when String
          sql += " WHERE #{@where}"
        when Array
          sql += " WHERE #{parse_conjunctions(@where)}"
        end
        sql
      end

      def prepare_joins
        sql = ''
        @joins.each { |join| sql += " #{join[:type]} #{join[:table]} ON #{join[:conditions]}" }
        sql
      end

    end

  end

end