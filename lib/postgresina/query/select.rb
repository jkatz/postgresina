module Postgresina

  module Query

    class Select < Base

      def initialize
        @joins = []
        @where = []
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
        sql = "("
        sql += "SELECT *"
        sql += " FROM #{@from}" if @from
        sql += prepare_joins if @joins.any?
        sql += " WHERE #{@where.join(' AND ' )}" if @where.any?
        sql += " ORDER BY #{@order_by}" if @order_by
        sql += " LIMIT #{@limit}" if @limit
        sql += " OFFSET #{@offset}" if @offset
        sql += ")"
        sql
      end

      def where(condition)
        @where << condition
        self
      end

    private

      def add_join(type, table, conditions)
        @joins << { :table => table, :type => type, :conditions => conditions }
        self
      end

      def prepare_joins
        sql = ''
        @joins.each { |join| sql += " #{join[:type]} #{join[:table]} ON #{join[:conditions]}" }
        sql
      end

    end

  end

end