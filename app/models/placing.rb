class Placing
	attr_accessor :name, :place

  def initialize(name, place)
  	@name = name
  	@place = place
  end

  def mongoize
  	{:name => @name, :place => @place}
  end

  def self.mongoize(object) 
      case object
      when Placing then object.mongoize
      when Hash then 
          Placing.new(object[:name], object[:place]).mongoize
      else object
      end
    end

  def self.demongoize(params)
  	Placing.new(params[:name], params[:place]) if params
  end

  def self.evolve(object)
    case object
      when Placing then object.mongoize
    else object
    end
  end

  def self.evolve(object)
    case object
      when Placing then object.mongoize
    else object
    end
  end
end