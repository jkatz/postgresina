class Postgresina::Model::Result

  def initialize(result)
    @result = result
    @data = Array.new(@result.num_tuples)
  end

end