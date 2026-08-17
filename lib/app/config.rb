require "dotenv"
require "fileutils"
class AppConfig
  ROOT = File.expand_path("../..", __dir__)
  ENV_FILE = File.join(ROOT, ".env")

  def self.load
    Dotenv.load(ENV_FILE)
  end

  def self.set(key, val)
    FileUtils.touch(ENV_FILE)
    lines = File.readlines(ENV_FILE)
    found = false
    lines.map! do |line|
      if line.start_with?("#{key}=")
        found = true
        "#{key}=#{val}"
      else 
        line
      end
    end
    lines << "#{key}=#{val}\n" unless found
    File.write(ENV_FILE, lines.join)
    ENV[key] = val
  end
end