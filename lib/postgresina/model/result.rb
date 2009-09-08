class Postgresina::Model::Result
  include Enumerable

  def initialize(klass, result)
    @result = result
    @klass = klass
    @data = Array.new(@result.num_tuples)
  end

  def [](index)
    reify!(index)
  end

  def each
    raise LocalJumpError, 'no block given' unless block_given?
    @data.each_index { |i| yield(reify!(i)) }
    self
  end

  def empty?
    @data.empty?
  end

  def first
    reify!(0)
  end

  def last
    reify!(@data.empty? ? 0 : @data.length - 1)
  end

  def length
    @data.length
  end

private

  def reify!(index)
    return nil if @data.empty?
    @data[index] ||= @klass.new(@result[index])
  end

end