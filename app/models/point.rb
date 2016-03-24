class Point
	attr_accessor :longitude, :latitude

	def initialize(lng, lat)
    	@longitude = lng
    	@latitude = lat
  	end

	def mongoize
		{:type => self.class.to_s,:coordinates => [@longitude, @latitude]}
	end

	def self.demongoize(params)
		Point.new(params[:coordinates][0], params[:coordinates][1]) if params
	end

	def self.mongoize(object) 
      case object
      when Point then object.mongoize
      when Hash then 
        if object[:type] #in GeoJSON Point format
          Point.new(object[:coordinates][0], object[:coordinates][1]).mongoize
        else       #in legacy format
          Point.new(object[:lng], object[:lat]).mongoize
        end
        else object
      end
    end

    def self.evolve(object)
      case object
        when Point then object.mongoize
      else object
      end
    end
end