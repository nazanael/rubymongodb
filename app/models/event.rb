class Event
  include Mongoid::Document
  field :o, as: :order, type: Integer
  field :n, as: :name, type: String
  field :d, as: :distance, type: Float
  field :u, as: :units, type: String
  
  validates_presence_of :order, :name  
  
  embedded_in :parent, polymorphic: true, touch: true
  
  def meters
    case units
      when "miles" then distance * 1609.344
      when "kilometers" then distance * 1000
      when "meters" then distance
      when "yards" then distance * 0.9144
    else nil
    end
  end
  
  def miles
    case units
      when "miles" then distance
      when "kilometers" then distance / 1.609344
      when "meters" then distance / 1609.34
      when "yards" then distance * 0.000568182
    else nil
    end
  end
end
