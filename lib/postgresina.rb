require 'pg'

module Postgresina
  autoload :Connection, 'postgresina/connection'
  autoload :Model, 'postgresina/model'

  module Query
    autoload :Base, 'postgresina/query/base'
    autoload :Select, 'postgresina/query/select'
  end

end
