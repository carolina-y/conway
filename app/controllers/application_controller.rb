class ApplicationController < ActionController::API
  rescue_from Idempotency::CacheHit, with: :idempotency_cache_hit

  def idempotency_write(status, value)
    return unless idempotency_key.present?

    $redis.set(idempotency_key, { status: status, result: value }.to_json, ex: 24.hours.to_i)
  end

  def idempotency_read
    return unless idempotency_key.present?

    cache = $redis.get(idempotency_key)
    if cache.present?
      parsed_cache = JSON.parse(cache)

      raise Idempotency::CacheHit.new(parsed_cache["status"].to_sym, parsed_cache["result"])
    end
  end

  def idempotency_cache_hit(exception)
    render json: exception.result, status: exception.status
  end

  def idempotency_key
    @idempotency_key ||= request.headers["Idempotency-Key"]
  end
end
