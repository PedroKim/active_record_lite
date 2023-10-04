require_relative '../lib/04_associatable2'
# Schema info
# fname string not null
# lname string not null
# house_id int
class Human < SQLObject
    self.table_name = 'humans'
    
    has_many :cats, foreign_key: :owner_id
    belongs_to :house

    finalize!
end