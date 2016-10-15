class Station < StationBase
  
  def self.get_random(char = nil)
    s = Station.where("name_kana NOT LIKE ? AND name_kana NOT LIKE ?", "%ん", "%ー")
    s = s.where("name_kana LIKE ?", "#{char}%") if char
    s.order('RAND()').last
  end
  
  def hogehoge
    char = self.name_kana[0]
    converted_char = char.gsub(/ゃ|ゅ|ょ|っ/, 'ゃ'=>'や', 'ゅ'=>'ゆ', 'ょ'=>'よ', 'っ'=> 'つ').to_nfd.split('')[0]
    [char, converted_char]
  end
  
  def self.get_random_tester(char = nil)
    s = Station.where("name_kana NOT LIKE ?", "%ん")
    s = s.where("name_kana LIKE ?", "#{char}%") if char
    s.order('RAND()').last
  end
end