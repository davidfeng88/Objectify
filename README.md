# Objectify

Inspired by Active Record, Objectify is a Ruby object-relational mapping (ORM) library, which uses SQLite3 as its database. Objectify provides an `SQLObject` base class. When users define a new class (model) that is a subclass of `SQLObject`, a mapping between the model and an existing table in the database is established. Moreover, models can connect with other models by defining **associations**.

## Demo

For demo purposes, a database `geo.db` is provided. To experience Objectify, run the following commands in your terminal:

1. `git clone https://github.com/davidfeng88/Objectify.git`
2. `cd Objectify/`
3. `irb`
4. `load 'geo.rb'`
5. Try the following commands!

```ruby
# all
City.all
# => [#<City:0x00007fa4fd09f5c0 @attributes={:id=>1, :name=>"Beijing", :country_id=>1}>, ...]

# find
Country.find(3)
# => #<Country:0x00007fa4fc1bca58 @attributes={:id=>3, :name=>"United States", :continent_id=>2}>

# first, last, associations
beijing = City.first
# => #<City:0x00007fa4fc2e6af0 @attributes={:id=>1, :name=>"Beijing", :country_id=>1}>
beijing.country
# => #<Country:0x00007fa4fd14f4c0 @attributes={:id=>1, :name=>"China", :continent_id=>1}>
beijing.continent
# => #<Continent:0x00007fa4fd14c068 @attributes={:id=>1, :name=>"Asia"}>

canada = Country.last
# => #<Country:0x00007fa4fc19c118 @attributes={:id=>4, :name=>"Canada", :continent_id=>2}>
canada.continent
# => #<Continent:0x00007fa4fd15cd50 @attributes={:id=>2, :name=>"North America"}>

# where
japan = Country.where(name: "Japan").first
# => #<Country:0x00007fa4fc122660 @attributes={:id=>2, :name=>"Japan", :continent_id=>1}>
kyoto = City.new(name: "kyoto", country_id: japan.id)
# => #<City:0x00007fa4fc2e4188 @attributes={:name=>"kyoto", :country_id=>2}>
kyoto.save
# => 8
City.last
# => #<City:0x00007fa4fd13f930 @attributes={:id=>8, :name=>"kyoto", :country_id=>2}>

kyoto.name = "Kyoto"
# => "Kyoto"
kyoto.save
# => []
City.last
# name updated!
# => #<City:0x00007fa4fd12ec20 @attributes={:id=>8, :name=>"Kyoto", :country_id=>2}>
```

**Note**: Check out [`geo.sql`](./geo.sql) file for the content of the demo database.

## Common Methods

* `::all` returns an array of all instances of the class.

* `::first` and `::last` return first and last instance of the class respectively.

* `::find(id)` returns the instance with the id provided. It returns `nil` if not found.

* `::new(params)` creates a new instance with an optional hash of parameters.

* `#save` saves the changes of the instance in the database. It calls `#insert` or `#update` based on whether the id is `nil` or not.

## Other methods

* `::columns` returns an array of column names (symbols).

* `::table_name` and `::table_name=`: table name getter and setter methods.

## Search

* `::where(params)` takes in a hash of parameters. It returns an empty array if nothing is found. For example:

```ruby
Country.where(name: "Japan") # => an array of Country instances where the name is "Japan"
```

## Association

* Associations are defined in the `.rb` file before `::finalize!`. For example:

```ruby
class Continent < SQLObject
  has_many :countries
  finalize!
end

class Country < SQLObject
  belongs_to :continent
  finalize!
end
```

* Supported associations currently include `has_many`, `belongs_to`, `has_one_through`.

* `has_many` and `belongs_to` takes a required name and an optional hash for `class_name`, `primary_key`, and `foreign_key`.

* `has_one_through` requires three arguments: `name`, `through_name`, `source_name`.  `has_one_through` connects two `belongs_to` associations. For example, in the demo database:
  1. `City` has a `belongs_to` association (`:country`) with `Country`
  2. `Country` has a `belongs_to` association (`:continent`) with `Continent`
  3. I defined a `has_one_through` association (`:continent`) for `City` using the following options:
     * `name`: `:continent`
     * `through_name`: `:country`
     * `source_name`:  `:continent`

## Use Objectify with your own database

You need to create three files (`.sql`, `.db`, and `.rb`) as follows. Refer to [`geo.sql`](./geo.sql) and [`geo.rb`](./geo.rb) files if needed.

1. Write a SQL source file (`.sql`).
2. Run `cat FILENAME.sql | sqlite3 FILENAME.db` to generates the database file (`.db`).
3. Edit the `SQL_FILE` and `DB_FILE` constants in `/lib/db_connection.rb` so that they point to the `.sql` and `.db` files in step 1 and 2.
4. Write a Ruby file (`.rb`) to define the models and set up the associations.
5. In `irb` or `pry`, load the `.rb` file and you are good to go!

## Future Work

1. Write `where` so that it is lazy and stackable. Implement a `Relation` class.
2. Validation methods/validator class.
3. `has_many :through`
    * This should handle both `belongs_to => has_many` and `has_many
      => belongs_to`.
4. Write an `includes` method that does pre-fetching.
5. `joins`
