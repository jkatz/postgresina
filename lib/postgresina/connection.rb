class Postgresina::Connection

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

  end

end