require_relative 'lib/sql_object'

DBConnection.reset

class Continent < SQLObject
  has_many :countries
  finalize!
end

class Country < SQLObject
  belongs_to :continent
  has_many :cities
  finalize!
end

class City < SQLObject
  belongs_to :country
  has_one_through :continent, :country, :continent
  finalize!
end
