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
end
