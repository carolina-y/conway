class Idempotency::CacheHit < StandardError
  attr_reader :status, :result

  def initialize(status, result)
    @status = status
    @result = result
  end
end
