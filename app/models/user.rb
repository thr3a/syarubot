class User < ActiveRecord::Base

  # TODO: 数字の大文字小文字　ヶのゆれ
  def siritori(user_answer = nil)
    if user_answer
      user_char = user_answer[0]
      stations = Station.where(name_orig: user_answer)
      if stations.blank?
        self.clear_siritori
        return "われはそんな駅知らないのだ♪われの勝ちなのだ♪また挑戦するのだ♪"
      end
      
      list = []
      stations.each do |station|
        list.concat(station.hogehoge)
      end
      stations = stations.where("name_kana REGEXP ?", list.uniq.map{|e|"^#{e}"}.join('|'))
      if stations.blank?
        self.clear_siritori
        return "なんか違うのだ♪われの勝ちなのだ♪また挑戦するのだ♪"
      end
      
      station = stations.first
      if station.name_kana[-1] == 'ん'
        self.clear_siritori
        return "最後が「ん」なのだ♪われの勝ちなのだ♪また挑戦するのだ♪"
      end
      bot_answer = Station.get_random(station.name_kana[-1])
      
      if bot_answer.nil?
        p station.name_kana
        self.clear_siritori
        return "make"
      end
      
      self.update siritori_word: bot_answer.name_kana[-1]
      "#{station.name_orig}駅は知ってるのだ♪次はわれの番、#{bot_answer.name}駅（#{bot_answer.name_kana}）なのだ♪次は「#{self.siritori_word}」なのだ♪"
    else
      bot_answer = Station.get_random
      self.update siritori_word: bot_answer.name_kana[-1]
      "われは駅名しりとり駅得意なのだ♪ まずはわれの番、#{bot_answer.name}駅(#{bot_answer.name_kana})なのだ!つぎは「#{self.siritori_word}」なのだ♪"
    end
  end
  
  def clear_siritori
    self.update(siritori_word: nil)
  end
end
