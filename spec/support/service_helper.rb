module ServiceHelper
  def service_result
    service_object.call
  end

  def service_object
    described_class.new(**params)
  end

  def json_response
    JSON.parse(response.body)
  end
end
