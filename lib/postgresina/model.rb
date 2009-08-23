require 'digest/sha1'

class Postgresina::Model

  # marshal crazy parameters for find, all, etc.

  class << self

    def connection
      @connection ||= Postgresina::Connection.connection
    end

    def find(id)
      statement = "#{self}-#{id}"
      begin
        connection.exec_prepared(statement, [{:value => id}])
      rescue PGError
        puts statement
        connection.prepare(statement, "SELECT * FROM #{self.to_s.downcase}s WHERE id=$1")
        connection.exec_prepared(statement, [{:value => id}])
      end
    end

  end

end