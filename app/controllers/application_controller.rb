class ApplicationController < ActionController::API
  rescue_from Idempotency::CacheHit, with: :idempotency_cache_hit
  rescue_from Idempotency::KeyError do
    render json: { error: "Idempotency-Key header is a string with at most 100 characters" }, status: :unprocessable_content
  end
  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: e.message, status: :not_found
  end

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
    @idempotency_key ||= begin
      key_read = request.headers["Idempotency-Key"]

      raise Idempotency::KeyError if key_read.is_a?(String) && key_read.length > 100

      key_read
    end
  end
end
