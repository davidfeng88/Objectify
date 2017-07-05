require_relative 'lib/sql_object'

DBConnection.reset

class Conference < SQLObject
  has_many :teams
  finalize!
end

class Team < SQLObject
  belongs_to :conference
  has_many :players
  finalize!
end

class Player < SQLObject
  belongs_to :team
  has_one_through :conference, :team, :conference
  finalize!
end
