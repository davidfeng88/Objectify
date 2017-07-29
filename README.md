# Objectify

Inspired by Active Record, Objectify is a Ruby object-relational mapping (ORM) library. It uses SQLite3 as its database. Objectify provides an `SQLObject` base class. When users define a new class (model) that is a subclass of `SQLObject`, a mapping between the model and an existing table in the database is established. Moreover, models can connect with other models by defining **associations**.

Naming convention:
Database table name: snake case, plural, e.g.  `cities`
Model name: CamelCase, singular, e.g. `City`

## Setup
* For demo purposes, a database `geo.db` is provided, which contains the following tables:

`continents`

id | name
-- | ----
1 | "Asia"
2 | "North America"

`countries`

id | name | continent_id
-- | ---- | ------------
1 | "China" | 1
2 | "Japan" | 1
3 | "United States" | 2
4 | "Canada" | 2

`cities`

id | name | country_id
-- | ---- | ------------
1 | "Beijing" | 1
2 | "Shanghai" | 1
3 | "Tokyo" | 2
4 | "New York" | 3
5 | "Chicago" | 3
6 | "Los Angeles" | 3
7 | "Toronto" | 3

* In `/lib/db_connection.rb`, specify the `.sql` and `.db` file (Objectify uses SQLite3).

* Run the following script:
```
require_relative 'lib/sql_object'

DBConnection.reset

class ModelName < SQLObject
  self.finalize!
end
```

* A simple database has been provided for demo purposes. To use it, run `load ‘test.rb’` in Pry.

## Common Methods
* `::all` returns an array of all instances of the class.

* `::first` and `::last` return first and last instance of the class respectively.

* `::find(id)` returns the instance with the id provided. Returns `nil` if not found.

* `#new(params)` creates a new instance with optional params hash.

* `#save` call `#insert` or `#update` based on whether the id is `nil` or not.

## Other methods
* `::columns` returns an array of column names (symbols).

* `::table_name` and `::table_name=`: table name getter and setter methods.

## Search
* `::where(params)` takes in a params hash. Returns an empty array if nothing is found. For example:
```
Team.where(name: "Bulls")
# => an array of Team instances where the name is "Bulls"
```

## Association
* Associations are defined in the model definition before `#finalize!`. For example:
```
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
```

* Currently supported associations include `has_many`, `belongs_to`, `has_one_through`.

* `has_many` and `belongs_to` takes a required name and a optional hash for class_name, primary_key, and foreign_key. If the optional hash is not provided, the information will be inferred from known information.

*  `has_one_through` requires three arguments: name, through_name, source_name.  `has_one_through` connects two `belongs_to` associations.
For example, if `Player` belongs_to `:team` and `Team` belongs_to `:conference`, then we could define `Player` has_one_through (`:conference`, through `:team`, source `:conference`)
