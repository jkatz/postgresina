require 'digest/sha1'

class Postgresina::Model

  # marshal crazy parameters for find, all, etc.

  class << self

    def column_types
      @column_types ||= {}
    end

    def connection
      @connection ||= Postgresina::Connection.connection
    end

    def find(ids)
      raise Postgresina::TableNameRequired unless @table_name && !@table_name.empty?
      case ids
      when Array: find_many(ids)
      else
        find_one(ids)
      end
    end

    def prepare(statement, sql)
      puts "Creating statement: #{statement}"
      connection.prepare(statement, sql)
    end

    def select_prepared(statement, bindings=[])
      connection.exec_prepared(statement, bindings)
    end

    def table_name(name)
      @table_name = name.to_s
      set_column_types!
      @table_name
    end

  private

    def find_one(id)
      statement = "#{@table_name}-find-one"
      bindings = [{:value => id}]
      result = select_prepared(statement, bindings)
      result.any? ? new(result[0], result) : nil
    rescue PGError
      sql = "SELECT * FROM #{@table_name} WHERE id=$1"
      prepare(statement, sql)
      result = select_prepared(statement, bindings)
      result.any? ? new(result[0], result) : nil
    end

    def find_many(ids)
      sig = Digest::SHA1.hexdigest(Marshal.dump(ids.sort))
      statement = "#{@table_name}-find-many-#{sig}"
      results = select_prepared(statement)
      Result.new(self, results)
    rescue PGError
      sql = <<-SQL
        SELECT *
        FROM #{@table_name}
        WHERE id IN (#{connection.escape_string(ids.join(','))})
      SQL
      prepare(statement, sql)
      results = select_prepared(statement)
      Result.new(self, results)
    end

    # initializes the column types in order to perform the appropriate conversions
    def set_column_types!
      result = connection.exec("SELECT * FROM #{@table_name} LIMIT 1")
      (0...result.num_fields).each do |i|
        column_name = result.fields[i]
        column_types[column_name] = Postgresina::Connection::TYPE_MAP[
          Postgresina::Connection::TYPES[result.ftype(i)]
        ]
        self.class_eval <<-RUBY
          def #{column_name}; instance_variable_get("@#{column_name}"); end
          def #{column_name}=(v); instance_variable_set("@#{column_name}", v); end
        RUBY
      end
    end

  end

  def initialize(attributes={}, result=nil)
    attributes.each do |k,v|
      value = result && v ? self.class.column_types[k].call(v) : v
      instance_variable_set("@#{k}", value)
    end
  end

private

end

class Postgresina::ModelError < StandardError; end
class Postgresina::TableNameRequired < Postgresina::ModelError; end

require 'postgresina/model/result'