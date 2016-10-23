class User < ActiveRecord::Base
  attr_accessor :message
  
  def siritori user_answer
    stations = Station.where(name_orig: user_answer)
    if stations.empty?
      self.message = "われはそんな駅知らないのだ♪#{self.siritori_cnt}回続いたのだ♪また挑戦するのだ♪"
      return self.clear_siritori_session
    end
    
    list = [self.siritori_word, self.siritori_word.gsub(/ゃ|ゅ|ょ|っ/, 'ゃ'=>'や', 'ゅ'=>'ゆ', 'ょ'=>'よ', 'っ'=> 'つ').to_nfd.split('')[0]]
    stations = stations.where("name_kana REGEXP ?", list.uniq.map{|e|"^#{e}"}.join('|'))
    if stations.empty?
      self.message = "なんか違うのだ♪#{self.siritori_cnt}回続いたのだ♪また挑戦するのだ♪"
      return self.clear_siritori_session
    end
    
    station = stations[0]
    if station.name_kana[-1] == 'ん'
      self.message = "最後が「ん」なのだ♪#{self.siritori_cnt}回続いたのだ♪また挑戦するのだ♪"
      return self.clear_siritori_session
    end
    
    bot_answer = Station.get_random(station.name_kana[-1])
    if bot_answer.nil?
      self.message = "ぐぬぬ、われの負けなのだ…すごいのだ、#{self.siritori_cnt}回続いたのだ♪"
      return self.clear_siritori_session
    end
    
    self.update siritori_word: bot_answer.name_kana[-1]
    self.increment!(:siritori_cnt, 1)
    self.increment!(:max_siritori_cnt, 1)
    self.message = "#{station.name_orig}駅は知ってるのだ♪次はわれの番、#{bot_answer.name}駅（#{bot_answer.name_kana}）なのだ♪次は「#{self.siritori_word}」なのだ♪"
  end
  
  def initialize_siritori
    bot_answer = Station.get_random
    self.update siritori_word: bot_answer.name_kana[-1], siritori_cnt: 1
    self.message = "われは駅名しりとり駅得意なのだ♪ まずはわれの番、#{bot_answer.name}駅(#{bot_answer.name_kana})なのだ!つぎは「#{self.siritori_word}」なのだ♪"
  end
  
  def clear_siritori_session
    self.update(siritori_word: nil, siritori_cnt: 0)
  end
  
  def nandoku user_answer
    answer = Station.find_by(id: self.nandoku_id, name_kana: user_answer)
    if answer.present?
      self.increment!(:nandoku_cnt, 1)
      question = Station.where(nandoku_flag: true).order('RAND()').last
      self.update nandoku_id: question.id
      self.message = "正解なのだ♪次は#{question.name}駅のよみを答えるのだ♪"
    else
      self.message = "違うっぽいのだ♪#{self.nandoku_cnt}回続いたのだ♪また挑戦するのだ♪"
      self.update(nandoku_id: nil, nandoku_cnt: 0)
    end
  end
  
  def initialize_nandoku
    question = Station.where(nandoku_flag: true).order('RAND()').last
    self.update nandoku_id: question.id, nandoku_cnt: 1
    self.message = "われは駅に詳しいのだ♪まずは #{question.name} 駅なのだ♪「とうきょうえき」のように答えないと反応しないので気をつけるのだ♪"
  end
  
  def five_bomber user_answer
    if self.check_five_bomber_question(user_answer)
      self.set_five_bomber_question
      self.message = "すごいのだ♪次の問題、#{self.message}"
    else
      self.message = "なんか違うっぽいのだ♪また挑戦するのだ♪"
      self.update(quiz_type: nil)
    end
  end
  
  def initialize_five_bomber
    self.set_five_bomber_question
    self.message = "われは駅に詳しいのだ♪では問題、"+ self.message+"「○○駅 ○○駅 ○○駅」のようにスペースで区切ってリプライなのだ♪"
  end
  
  def set_five_bomber_question
    quiz_type = %w"len zone pref char minlen".sample
    case quiz_type
    when 'len'
      len = [2,3].sample
      self.message = "#{len}文字の駅を３つ答えるのだ♪"
      quiz_type += ":#{len}"
    when 'zone'
      zone = [{label:'東日本(~中部地方まで)',pref_ids:'1..23'},{label:'西日本(近畿地方以降)',pref_ids:'24..47'}].sample
      self.message = "#{zone[:label]}にある駅を3つ答えるのだ♪"
      quiz_type += ":#{zone[:pref_ids]}"
    when 'pref'
      pref = Pref.all.sample
      self.message = "#{pref.name}にある駅を3つ答えるのだ♪"
      quiz_type += ":#{pref.id}"
    when 'char'
      char = %w"東 西 南 北".sample
      self.message = "名前に「#{char}」が入る駅を3つ答えるのだ♪"
      quiz_type += ":#{char}"
    when 'minlen'
      len = 4
      self.message = "#{len}文字以上の駅を3つ答えるのだ♪"
      quiz_type += ":#{len}"
    end
    self.update quiz_type: quiz_type
  end
  
  def check_five_bomber_question user_answer
    user_answer = user_answer.gsub(/　/,' ').split(' ').map{|s|s.gsub(/駅$/, '')}
    return false if user_answer.length < 3
    quiz_type, quiz_condition = self.quiz_type.split(':')
    case quiz_type
    when 'len'
      stations = Station.where("CHAR_LENGTH(`name_orig`) = ?", quiz_condition.to_i)
    when 'zone'
      range = Range.new(*quiz_condition.split("..").map(&:to_i))
      stations = Station.where(pref_id: range)
    when'pref'
      stations = Station.where(pref_id: quiz_condition)
    when 'char'
      stations = Station.where("`name_orig` LIKE ?", "%#{quiz_condition}%")
    when 'minlen'
      stations = Station.where("CHAR_LENGTH(`name_orig`) >= ?", quiz_condition.to_i)
    end
    stations = stations.where(name_orig: user_answer)
    if stations.count >= 3
      true
    else
      false
    end
  end
  
  # def cheat_five_bomber_question
  #   quiz_type, quiz_condition = self.quiz_type.split(':')
  #   case quiz_type
  #   when 'len'
  #     stations = Station.where("CHAR_LENGTH(`name_orig`) = ?", quiz_condition)
  #   when 'zone','pref'
  #     stations = Station.where(pref_id: quiz_condition)
  #   when 'char'
  #     stations = Station.where("`name_orig` LIKE ?", "%#{quiz_condition}%")
  #   when 'minlen'
  #     stations = Station.where("CHAR_LENGTH(`name_orig`) > ?", quiz_condition)
  #   end
  #   stations.order('RAND()').last(3).map{|e|e.name_orig+'駅'}.join(' ')
  # end
end
