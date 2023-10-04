require_relative '../lib/04_associatable2'
# Schema info
# address string not null
class House < SQLObject
    has_many :humans
    
    finalize!
end