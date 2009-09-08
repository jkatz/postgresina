require 'time'

class Postgresina::Connection

  TYPES = {}
  TYPE_MAP = {
    '_bool' => lambda { |x|
        case x
        when 'TRUE', 't', 'true', 'y', 'yes', '1'
          true
        when 'FALSE', 'f', 'false', 'f', 'no', '0'
          false
        end
      },
    '_int4' => lambda { |x| x.to_i },
    '_text' => lambda { |x| x.to_s },
    '_timestamp' => lambda { |x| Time.parse(x) },
    '_varchar' => lambda { |x| x.to_s }
  }

  class << self

    # options are like the hash of options passed to PGconn.new
    #
    # +:host+ - server hostname
    # +:hostaddr+ - server address (avoids hostname lookup, overrides +host+)
    # +:port+ - server port number
    # +:dbname+ - connecting database name
    # +:user+ - login user name
    # +:password+ - login password
    # +:connect_timeout+ - maximum time to wait for connection to succeed
    # +:options+ - backend options
    # +:tty+ - (ignored in newer versions of PostgreSQL)
    # +:sslmode+ - (disable|allow|prefer|require)
    # +:krbsrvname+ - kerberos service name
    # +:gsslib+ - GSS library to use for GSSAPI authentication
    # +:service+ - service name to use for additional parameters
    def connect(options={})
      @connection = PGconn.new(options)
      load_default_types
      @connection
    end

    # returns an instance of PGconn
    def connection
      @connection
    end

    # true if connected, false if not
    def connected?
      !!(@connection && @connection.status == PGconn::CONNECTION_OK)
    rescue PGError
      false
    end

  private

    def load_default_types
      results = connection.exec("SELECT typname, typelem FROM pg_type WHERE typname ~ '^_'")
      results.each { |result| TYPES[result['typelem'].to_i] = result['typname'] }
      TYPES.freeze
    end

  end

end