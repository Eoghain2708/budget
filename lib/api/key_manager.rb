require "tty-prompt"
require "fileutils"
require_relative "../app/config"
require_relative "../errors/invalid_broker_error"

module Budget
  module API
    # To be initialised: Budget::API::KeyManager.new.configure(broker) - KeyManager::ALLOWED_BROKERS for options
    class KeyManager
      ALLOWED_BROKERS = [:trading212]
      
      def initialize
        @prompt = TTY::Prompt.new
      end

      # @param broker [Symbol] - The broker for which the configuration will be saved
      def configure(broker)
        Budget::Errors::InvalidBrokerError.check_and_throw(broker)
        case broker
        when :trading212 then configure_for_trading212
        end
      end

      private

      def configure_for_trading212
        api_key = @prompt.ask("Enter your API key")
        secret_key = @prompt.mask("Enter your secret key")
        unless api_key.length > 0 && secret_key.length > 0
          puts "Invalid credentials."
          return
        end
        AppConfig.set("212_API_KEY", api_key)
        AppConfig.set("212_SECRET_KEY", secret_key)
        puts "Credentials set!"
      end
    end
  end
end