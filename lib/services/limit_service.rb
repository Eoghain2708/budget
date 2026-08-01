class LimitService
  
  # @param limits [LimitRepository]
  def initialize(limits)
    raise ArgumentError, "Limit Repository must be supplied" unless limits 
    self.limits = limits
    
  end
  
end