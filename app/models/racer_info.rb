class RacerInfo
  include Mongoid::Document
  
  field :racer_id, as: :_id
  field :_id, default:->{ racer_id }
  field :fn, as: :first_name, type: String
  field :ln, as: :last_name, type: String
  field :g, as: :gender, type: String
  field :yr, as: :birth_year, type: Integer
  field :res, as: :residence, type: Address

  validates_presence_of :first_name, :last_name
  validates :gender, presence: true, inclusion: { in: [ "M", "F" ] } 
  validates :birth_year, presence: true, numericality: { less_than: Date.today.year }

  embedded_in :parent, polymorphic: true

  #def city
  #  self.residence ? self.residence.city : nil
  #end

  #def city= name
  #  object = self.residence || Address.new
  #  object.city = name
  #  self.residence = object
  #end

  #hacerlo dinámicamente para las diferentes propiedades. Usaremos object.send(accion, valor) para invocar los métodos 
  #(ej: residence.send(city)), residence.send("city=", valor)
  ["city", "state"].each do |action|
    define_method("#{action}") do
      self.residence ? self.residence.send("#{action}") : nil
    end
    define_method("#{action}=") do |name|
      object = self.residence ||= Address.new
      object.send("#{action}=", name)
      self.residence = object
    end
  end
end
