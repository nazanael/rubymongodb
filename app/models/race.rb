class Race
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :n, as: :name, type: String
  field :date, type: Date
  field :loc, as: :location, type: Address
  field :next_bib, type:Integer, default: 0
  
  scope :upcoming, ->{ where(:date.gte => Date.current) }
  scope :past, ->{ where(:date.lt => Date.current) }
  
  embeds_many :events, as: :parent, class_name: 'Event', order: [:order.asc]
  has_many :entrants, foreign_key: "race._id", dependent: :delete, order:[:secs.asc, :bib.asc] #go to entrants through raceref

  DEFAULT_EVENTS = 
  {"swim"=>{:order=>0, :name=>"swim", :distance=>1.0, :units=>"miles"},
	"t1"=> {:order=>1, :name=>"t1"},
	"bike"=>{:order=>2, :name=>"bike", :distance=>25.0, :units=>"miles"},
	"t2"=> {:order=>3, :name=>"t2"},
	"run"=> {:order=>4, :name=>"run", :distance=>10.0, :units=>"kilometers"}}

  def next_bib
    self[:next_bib] += 1
    self.save
    self[:next_bib]
  end
  
  def get_group racer
    if racer && racer.birth_year && racer.gender
      quotient = (date.year - racer.birth_year)/10
      min_age = quotient * 10
      max_age = ((quotient+1)*10)-1
      gender = racer.gender
      name = min_age >= 60 ? "masters #{gender}" : "#{min_age} to #{max_age} (#{gender})"
      Placing.demongoize(:name => name) 
    end
  end

  def create_entrant racer
    entrant = Entrant.new
    entrant.build_race(self.attributes.symbolize_keys.slice(:_id, :n, :date))
    #gets RacerInfo from Racer and builds new racer for entrant
    entrant.build_racer(racer.info.attributes)
    entrant.group = get_group(racer)
    events.each { |event| entrant.send("#{event.name}=", event)}
    if entrant.validate
      entrant.bib = next_bib
      entrant.save
    end
    entrant
  end

  def self.upcoming_available_to racer
    upcoming_race_ids_for_racer = racer.races.upcoming.pluck(:race).map {|r| r[:_id]}
    Race.upcoming.where(:_id => {:$nin => upcoming_race_ids_for_racer})
  end

	#def swim
	#	event=events.select {|event| "swim"==event.name}.first
	#	event||=events.build(DEFAULT_EVENTS["swim"])
	#end
	#def swim_order
	#	swim.order
	#end
	#def swim_distance
	#	swim.distance
	#end
	#def swim_units
	#	swim.units
	#end
	#Hecho donámicamente:

  DEFAULT_EVENTS.keys.each do |name|
  	define_method("#{name}") do
  		event=events.select {|event| name==event.name}.first #si swim, coge evento con nombre "swim"
  		event ||= events.build(DEFAULT_EVENTS["#{name}"]) #lo coge o lo crea si no existe. asi al hacer .swim, cogerá el evento swim, bike cogera el bike, etc
  	end
  	["order", "distance", "units"].each do |prop|
  		define_method("#{name}_#{prop}") do #crea métodos swim_order, swim_distance, bike_order, bike_distance, etc
  			event = self.send("#{name}").send("#{prop}") #devuelve swim.distance, bike.distance, etc (usando el getter creado antes)
  		end
  		define_method("#{name}_#{prop}=") do |value| #define metodos swim_order=, bike_distance=, etc
  			event= self.send("#{name}").send("#{prop}=", value) #swim.order=value, bike.order=value, etc.
  		end
  	end
  end

  ["city", "state"].each do |action|
	  define_method("#{action}") do
	  self.location ? self.location.send("#{action}") : nil
	end
	define_method("#{action}=") do |name|
	  object=self.location ||= Address.new
	  object.send("#{action}=", name)
	  self.location=object
	end
  end

  def self.default
  	#cogera cada key (swim, bike, run, etc) y pasará por el método que hemos creado para crear los eventos
  	# (events.build(...)), así creará una nueva race con los eventos por defecto
  	Race.new do |race|
  		DEFAULT_EVENTS.keys.each {|leg| race.send("#{leg}")} 
  	end
  end
end
