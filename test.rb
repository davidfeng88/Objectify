require_relative 'lib/sql_object'

DBConnection.reset

class Conference < SQLObject
  self.finalize!
end

class Team < SQLObject
  self.finalize!
end

class Player < SQLObject
  self.finalize!
end
