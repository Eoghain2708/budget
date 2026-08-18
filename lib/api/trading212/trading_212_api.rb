require "net/http"
require "uri"
require "dotenv"
require "json"
require "base64"


module Budget
  module API
    class Trading212
      BASE_URI = URI("https://live.trading212.com/api/v0")
      HISTORY_ENDPOINTS = %w[dividends exports orders transactions]

      HISTORY_ENDPOINTS.each do |endpoint|
        define_method(endpoint) do 
          get("/equity/history/#{endpoint}")
        end
      end

      def initialize()
       @api_key = ENV.fetch("212_API_KEY")
       @api_secret = ENV.fetch("212_SECRET_KEY")
      end

      def summary
        get("/equity/account/summary")
      end

      def positions
        get("/equity/positions")
      end
      


      private

      def get(path)
        request = Net::HTTP::Get.new("#{BASE_URI}#{path}")
        request.basic_auth(
          @api_key,
          @api_secret
        )

        http = Net::HTTP.new(BASE_URI.host, BASE_URI.port)
        http.use_ssl = true
        response = http.request(request)
        JSON.parse(response.body)
      end

      def handle_response(response)
        unless response.success?
          raise "Trading 212 API error #{response.code}: #{response.body}"
          return {}
        end

        response.parsed_response
      end
    end
  end
end