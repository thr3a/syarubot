class Station < StationBase
  has_many :station_lines
  has_many :lines, through: :station_lines
  
  def self.get_random(char = nil)
    s = Station.where("name_kana NOT LIKE ? AND name_kana NOT LIKE ?", "%ん", "%ー")
    s = s.where("name_kana LIKE ?", "#{char}%") if char
    s.order('RAND()').last
  end
  
  def self.get_random_hard(char = nil)
    s = Station.where("name_kana NOT LIKE ? AND name_kana NOT LIKE ?", "%ん", "%ー")
    s = s.where(name)
    s = s.where("name_kana LIKE ?", "#{char}%") if char
    s.order('RAND()').last
  end
end