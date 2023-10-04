require_relative '../lib/04_associatable2'
# Schema info
# name string not null
# owner_id int 
class Cat < SQLObject
    belongs_to :human, foreign_key: :owner_id
    has_one_through :owners_house, :human, :house

    finalize!
end