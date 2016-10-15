class StationBase < ActiveRecord::Base
  self.abstract_class = true
  establish_connection(:station)
end
