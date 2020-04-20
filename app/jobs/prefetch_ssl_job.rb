class PrefetchSslJob < ApplicationJob
  queue_as :default

  def perform(url)
    uri = URI(url)
    request = Net::HTTP::Get.new(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.request(request)
  end
end
