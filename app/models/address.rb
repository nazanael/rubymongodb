class Address
  
  attr_accessor :city, :state, :location  
  
  def initialize(city=nil, state=nil, loc=nil)
  	@city = city if city
  	@state = state if state
  	@location = loc if loc
  end

  def mongoize
  	{:city => @city, :state => @state, :loc => @location.mongoize}
  end

  def self.mongoize(object) 
      case object
      when Address then object.mongoize
      when Hash then 
          Address.new(object[:city], object[:state], object[:loc]).mongoize
      else object
      end
    end

  def self.demongoize(params)
  	Address.new(params[:city], params[:state], Point.demongoize(params[:loc])) if params
  end

  def self.evolve(object)
    case object
      when Address then object.mongoize
    else object
    end
  end
end