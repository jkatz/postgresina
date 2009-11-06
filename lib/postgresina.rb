require 'pg'

module Postgresina
  autoload :Connection, 'postgresina/connection'
  autoload :Model, 'postgresina/model'

  module Query
    autoload :Query, 'postgresina/query/query'
    autoload :Select, 'postgresina/query/select'
  end

end
