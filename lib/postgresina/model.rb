require 'digest/sha1'

class Postgresina::Model

  # marshal crazy parameters for find, all, etc.
  # SELECT * FROM pg_type WHERE typelem

  class << self

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
    end

  private

    def find_one(id)
      statement = "#{@table_name}-find-one"
      bindings = [{:value => id}]
      result = select_prepared(statement, bindings)
      result.any? ? new(result[0]) : nil
    rescue PGError
      sql = "SELECT * FROM #{@table_name} WHERE id=$1"
      prepare(statement, sql)
      result = select_prepared(statement, bindings)
      result.any? ? new(result[0]) : nil
    end

    def find_many(ids)
      sig = Digest::SHA1.hexdigest(Marshal.dump(ids.sort))
      statement = "#{@table_name}-find-many-#{sig}"
      select_prepared(statement)
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

  end

  def initialize(attributes={})
    attributes.each do |k,v|
      instance_variable_set("@#{k}", v)
      self.instance_eval <<-RUBY
        def #{k}; instance_variable_get("@#{k}"); end
        def #{k}=(v); instance_variable_set("@#{k}", v); end
      RUBY
    end
  end

private

end

class Postgresina::ModelError < StandardError; end
class Postgresina::TableNameRequired < Postgresina::ModelError; end

require 'postgresina/model/result'