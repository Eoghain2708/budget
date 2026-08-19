require "net/http"
require "securerandom"
require "uri"
require "json"

module Budget
  module API
    class EToro

      V1_URI = URI("https://public-api.etoro.com/api/v1")
      V2_URI = URI("https://public-api.etoro.com/api/v2")
      

      def initialize
        @api_key = ENV.fetch("ETORO_API_KEY")
        @secret_key = ENV.fetch("ETORO_SECRET_KEY")
      end

      def summary
        get("balances?displayCurrency=GBP")
      end

      def positions
        get("trading/info/instrument-breakdown", uri: :v2)
      end


      def get(path, uri: :v1)
        uri = define_uri(uri)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Get.new("#{uri}/#{path}")
        request["x-request-id"] = SecureRandom.uuid
        request["x-api-key"] = @api_key
        request["x-user-key"] = @secret_key 
        res = http.request(request)
        JSON.parse(res.body)
      end

      private

      def define_uri(uri)
        if uri == :v1
          return V1_URI
        end

        if uri == :v2 
          return V2_URI
        end

        nil
      end


    end
  end
end