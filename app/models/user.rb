class User < ActiveRecord::Base

  def siritori(user_answer = nil)
    if user_answer
      user_char = user_answer[0]
      stations = Station.where(name_orig: user_answer)
      if stations.blank?
        msg = "われはそんな駅知らないのだ♪#{self.siritori_cnt}回続いたのだ♪また挑戦するのだ♪"
        self.clear_siritori_session
        return msg
      end
      
      list = []
      stations.each do |station|
        list.concat(station.hogehoge)
      end
      stations = stations.where("name_kana REGEXP ?", list.uniq.map{|e|"^#{e}"}.join('|'))
      if stations.blank?
        msg = "なんか違うのだ♪#{self.siritori_cnt}回続いたのだ♪また挑戦するのだ♪"
        self.clear_siritori_session
        return msg
      end
      
      station = stations.first
      if station.name_kana[-1] == 'ん'
        msg = "最後が「ん」なのだ♪#{self.siritori_cnt}回続いたのだ♪また挑戦するのだ♪"
        self.clear_siritori_session
        return msg
      end
      bot_answer = Station.get_random(station.name_kana[-1])
      
      if bot_answer.nil?
        msg = "ぐぬぬ、われの負けなのだ…すごいのだ、#{self.siritori_cnt}回続いたのだ♪"
        self.clear_siritori_session
        return msg
      end
      
      self.update siritori_word: bot_answer.name_kana[-1]
      self.increment(:siritori_cnt)
      self.increment(:max_siritori_cnt)
      "#{station.name_orig}駅は知ってるのだ♪次はわれの番、#{bot_answer.name}駅（#{bot_answer.name_kana}）なのだ♪次は「#{self.siritori_word}」なのだ♪"
    else
      bot_answer = Station.get_random
      self.update siritori_word: bot_answer.name_kana[-1], siritori_cnt: 1
      "われは駅名しりとり駅得意なのだ♪ まずはわれの番、#{bot_answer.name}駅(#{bot_answer.name_kana})なのだ!つぎは「#{self.siritori_word}」なのだ♪"
    end
  end
  
  def clear_siritori_session
    self.update(siritori_word: nil, siritori_cnt: 0)
  end
end
