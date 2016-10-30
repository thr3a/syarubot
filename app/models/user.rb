class User < ActiveRecord::Base
  attr_accessor :message, :user_pass_flag
  
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
    if self.game_type == 'hard_siritori'
      bot_answer = Station.get_random_hard
      self.update siritori_word: bot_answer.name_kana[-1], siritori_cnt: 1
      self.message = "われは駅名し（ﾄﾞｶｯ　シーナ「ふふふ、マスターの相手はわたしよ。せっかくだし漢字2文字に限定するわ。まずは #{bot_answer.name}駅(#{bot_answer.name_kana})だから「#{self.siritori_word}」よ。何問答えられるかしら…"
    else
      bot_answer = Station.get_random
      self.update siritori_word: bot_answer.name_kana[-1], siritori_cnt: 1
      self.message = "われは駅名しりとり駅得意なのだ♪ まずはわれの番、#{bot_answer.name}駅(#{bot_answer.name_kana})なのだ!つぎは「#{self.siritori_word}」なのだ♪「東京駅」のように答えるのだ♪"
    end
    
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
  
  def five_bomber(user_answer)
    if self.check_five_bomber_question(user_answer)
      if self.game_count+1 == 10
        self.message = "ゲームクリアおめでとうなのだ♪流石われのマスターなのだ♪"
        self.update(game_type: nil, quiz_type: nil, game_condition: nil, game_count: 0, game_pass_count:0)
        return
      end
      self.set_five_bomber_question
      self.update game_count: self.game_count+1, quiz_type: self.quiz_type, game_condition: self.game_condition
      if self.game_count == 6
        self.message = "すごいのだ♪ここからは少し難しくなるのだ♪では第#{self.game_count}問、#{self.message}"
      elsif self.game_count == 9
        self.message = "すごいのだ♪ついに最終問題、#{self.message}"
      else
        self.message = "すごいのだ♪では第#{self.game_count}問、#{self.message}"
      end
    else
      self.message = "なんか違うっぽいのだ♪#{self.game_count-1}回続いたのだ♪また挑戦するのだ♪"
      self.update(game_type: nil, quiz_type: nil, game_condition: nil, game_count:0, game_pass_count: 0)
    end
  end
  
  def initialize_five_bomber
    self.set_five_bomber_question
    self.update game_type: 'five_bomber', game_count: 1, quiz_type: self.quiz_type, game_condition: self.game_condition
    self.message = "全１０問ファイトなのだ♪では第#{self.game_count}問、"+ self.message+"「○○駅 ○○駅 ○○駅」のようにスペースで区切ってリプライなのだ♪"
  end
  
  def set_five_bomber_question
    quiz_types_lv1 = [
      {name: 'len', condition: [2,3]},
      {name: 'minlen', condition: 4},
      {name: 'word', condition: %w"東 西 南 北"},
      {name: 'zone' },
      # [{name: 'yamanote'}] # 75
    ]
    quiz_types_lv2 = [
      {name: 'len', condition: [1,4,5]},
      {name: 'minlen', condition: 6},
      {name: 'word', condition: %w"本 山 川"},
      {name: 'lastword', condition: %w"ー" },
      {name: 'pref'}
    ]
    quiz_types = (self.game_count < 5) ? quiz_types_lv1 : quiz_types_lv2
    if self.game_condition.present?
      quiz_types.delete(self.game_condition) # 前回のquiz_typeを除外
    end
    quiz_type = quiz_types.sample
    case quiz_type[:name]
    when 'len'
      self.game_condition = quiz_type[:condition].sample
      self.message = "#{self.game_condition}文字の駅を３つ答えるのだ♪"
    when 'minlen'
      self.game_condition = quiz_type[:condition]
      self.message = "#{self.game_condition}文字以上の駅を3つ答えるのだ♪"
    when 'word'
      self.game_condition = quiz_type[:condition].sample
      self.message = "名前に「#{self.game_condition}」が入る駅を3つ答えるのだ♪"
    when 'zone'
      zone = [
        {label:'東日本(~中部地方まで)',pref_ids:'1..23'},
        {label:'西日本(近畿地方以降)',pref_ids:'24..47'},
        {label:'東北地方',pref_ids:'2..7'},
        {label:'関東地方',pref_ids:'8..14'},
        {label:'中部地方',pref_ids:'15..23'},
        {label:'近畿(関西)地方',pref_ids:'24..30'},
        {label:'中国地方',pref_ids:'31..35'},
        {label:'四国地方',pref_ids:'36..39'},
        {label:'九州地方',pref_ids:'40..46'}
      ].sample
      self.game_condition = zone[:pref_ids]
      self.message = "#{zone[:label]}にある駅を３つ答えるのだ♪"
    # when 'yamanote'
    #   self.message = "JR山手線の駅を３つ答えるのだ♪"
    when 'pref'
      pref = Pref.all.sample
      self.game_condition = pref.id
      self.message = "#{pref.name}にある駅を３つ答えるのだ♪"
    when 'lastword'
      self.game_condition = quiz_type[:condition].sample
      self.message = "最後が「#{self.game_condition}」で終わる駅を3つ答えるのだ♪"
    end
    self.quiz_type = quiz_type[:name]
  end
  
  def check_five_bomber_question(user_answer)
    return true if self.user_pass_flag
    user_answer = user_answer.gsub(/　/,' ').split(' ').map{|s|s.gsub(/駅$/, '')}
    return false if user_answer.length < 3
    case self.quiz_type
    when 'len'
      stations = Station.where("CHAR_LENGTH(`name_orig`) = ?", self.game_condition.to_i)
    when 'zone'
      range = Range.new(*self.game_condition.split("..").map(&:to_i))
      stations = Station.where(pref_id: range)
    when'pref'
      stations = Station.where(pref_id: self.game_condition)
    when 'word'
      stations = Station.where("`name_orig` LIKE ?", "%#{self.game_condition}%")
    when 'lastword'
      stations = Station.where("`name_orig` LIKE ?", "%#{self.game_condition}")
    when 'minlen'
      stations = Station.where("CHAR_LENGTH(`name_orig`) >= ?", self.game_condition.to_i)
    # when 'yamanote'
    #   stations = StationLine.where(line_id:)("CHAR_LENGTH(`name_orig`) >= ?", self.game_condition.to_i)
    end
    stations = stations.where(name_orig: user_answer)
    if stations.count >= 3 # 同名の駅が存在する場合があるため以上を用いる
      true
    else
      false
    end
  end
end