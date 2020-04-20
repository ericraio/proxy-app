# frozen_string_literal: true

module ReverseProxy
  def self.excluded_hosts
    %w[app.lvh.me app.ericsbookclub.com]
  end
  class Middleware
    def initialize(application)
      @application = application
    end

    def call(environment)
      Responder.new(@application, environment).response
    end

    class Responder
      attr_reader :app, :env

      def initialize(application, environment, options = {})
        @app = application
        @env = environment
        @options = options
      end

      attr_reader :app, :env, :options

      def response
        if matching_domain?
          setup_request
          handle_response
        else
          app.call(env)
        end
      end

      def matching_domain?
        !ReverseProxy.excluded_hosts.include?(source_request.host) && uri.present?
      end

      def setup_request
        preserve_host
        strip_headers
        set_forwarded_headers
        initialize_http_header
        setup_body
        set_content_length
        set_content_type
      end

      def source_request
        @_source_request ||= Rack::Request.new(env)
      end

      def strip_headers
        return unless options[:stripped_headers]
        options[:stripped_headers].each do |header|
          target_request_headers.delete(header)
        end
      end

      def target_request
        @_target_request ||= build_target_request
      end

      def build_target_request
        Net::HTTP.const_get(request_method).new(uri.to_s)
      end

      def set_forwarded_headers
        return unless options[:x_forwarded_headers]
        target_request_headers["X-Forwarded-Port"] = source_request.port.to_s
        target_request_headers["X-Forwarded-Host"] = source_request.host
        target_request_headers["X-Forwarded-Proto"] = source_request.scheme
      end

      def setup_body
        source_request.body.rewind
        target_request.body_stream = source_request.body
      end

      def target_request_headers
        @_target_request_headers ||= headers
      end

      def initialize_http_header
        target_request.initialize_http_header(target_request_headers)
      end

      def preserve_host
        return unless options[:preserve_host]
        target_request_headers["HOST"] = host_header
      end

      def host_header
        return uri.host if uri.port == uri.default_port
        "#{uri.host}:#{uri.port}"
      end

      def set_content_type
        content_type = source_request.content_type
        target_request.content_type = content_type if content_type
      end

      def set_content_length
        target_request.content_length = source_request.content_length || 0
      end

      def uri
        return @_uri if defined?(@_uri)
        domain = Domain.find_by(host: source_request.host)
        @_uri = domain && URI("http://#{domain.origin}").tap do |uri|
          uri.path   = source_request.fullpath
          uri.scheme ||= source_scheme
          uri.port   ||= source_port if source_port.present?
          uri.query  ||= env["QUERY_STRING"] if env["QUERY_STRING"].present?
        end
      end

      def setup_response_headers
        replace_location_header
      end

      def target_response
        @_target_response ||= begin
                                Rack::HttpStreamingResponse.new(
                                  target_request,
                                  uri.host,
                                  uri.port
                                ).tap do |response|
                                  response.use_ssl = uri.port == 443
                                  response.verify_mode = OpenSSL::SSL::VERIFY_NONE
                                end
                              end
      end

      def handle_response
        [target_response.status, response_headers, target_response.body]
      end

      def response_headers
        @_response_headers ||= build_response_headers
      end

      def build_response_headers
        ["Transfer-Encoding", "Status"].inject(rack_response_headers) do |acc, header|
          acc.delete(header)
          acc
        end
      end

      def rack_response_headers
        Rack::Utils::HeaderHash.new(
          Rack::Proxy.normalize_headers(
            format_headers(target_response.headers)
          )
        )
      end

      def format_headers(headers)
        headers.inject({}) do |acc, (key, val)|
          formated_key = key.split("-").map(&:capitalize).join("-")
          acc[formated_key] = Array(val)
          acc
        end
      end

      def headers
        Rack::Proxy.extract_http_request_headers(source_request.env)
      end

      def request_method
        @request_method ||= env["REQUEST_METHOD"].capitalize
      end

      def source_scheme
        env["rack.url_scheme"]
      end

      def source_port
        @_source_port ||= begin
                            host = env["HTTP_HOST"]
                            if host.include?(":")
                              host.split(":").last.to_i
                            end
                          end
      end
    end
  end
end
