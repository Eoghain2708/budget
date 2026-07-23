require "optparse"

module OptionWizard
  
  # @param argv [Array<String>]
  # @return [Hash<Symbol, String>]
  def self.parse_transaction_opts(argv)
    params = {}
    OptionParser.new do |opts|
      opts.on('--date STRING', String)
      opts.on('--merchant STRING', String)
      opts.on('--category STRING', String)
      opts.on('--nature SYMBOL', String)
    end.parse!(into: params)
    pp params
    params
  end

  # @param argv [Array<String>]
  # @return [Hash<Symbol, String>]
  def self.parse_transaction_delete_and_edit_opts(argv)
    params = {}
    OptionParser.new do |opts|
      opts.on('--to STRING', String)
    end.parse!(into: params)
    params
  end

  def self.parse_preset_nature_opts(argv)
    opts = parse_transaction_opts(argv)
    opts.delete(:nature) if opts[:nature]
    opts
  end

  # @param argv [Array<String>]
  # @return [Hash<String, Boolean>]
  def self.parse_summary_opts(argv)
    params = {}
    OptionParser.new do |opts|
      opts.on('--short')
    end.parse!(into: params)
    params
  end
end