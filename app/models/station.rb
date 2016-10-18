class Station < StationBase
  
  def self.get_random(char = nil)
    s = Station.where("name_kana NOT LIKE ? AND name_kana NOT LIKE ?", "%ん", "%ー")
    s = s.where("name_kana LIKE ?", "#{char}%") if char
    s.order('RAND()').last
  end
end