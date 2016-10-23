namespace :bot do
  if Rails.env.development?
    ActiveRecord::Base.logger = Logger.new(STDOUT)
  end
  if Rails.env.production?
    Process.daemon
  end
  
  desc "start bot"
  task start: :environment do
    TweetStream.configure do |config|
      config.consumer_key       = Rails.application.secrets.consumer_key
      config.consumer_secret    = Rails.application.secrets.consumer_secret
      config.oauth_token        = Rails.application.secrets.access_token
      config.oauth_token_secret = Rails.application.secrets.access_token_secret
      config.auth_method        = :oauth
    end
    TweetStream::Client.new.userstream do |tweet|
      # リプライ
      if match = tweet.text.match(/^@#{Rails.application.secrets.own_name}[ |　|\n]+(.+)/)
        case match[1]
        # ファイブボンバースタート
        when /ファイブボンバー/
          user = User.find_or_initialize_by(id: tweet.user.id)
          if user.new_record?
            user.scname = tweet.user.screen_name
            user.name = tweet.user.name
            user.save!
          end
          user.initialize_five_bomber
          TwitterBot.new(message: user.message, scname: user.scname, reply_to: tweet.id).tweet
        # ファイブボンバー返答
        when /駅 |駅　/
          if(user = User.find_by(id: tweet.user.id))
            user.five_bomber(match[1].strip)
            TwitterBot.new(message: user.message, scname: user.scname, reply_to: tweet.id).tweet
          end
        # 駅名しりとりスタート
        when /駅名しりとり/
          user = User.find_or_initialize_by(id: tweet.user.id)
          if user.new_record?
            user.scname = tweet.user.screen_name
            user.name = tweet.user.name
            user.save!
          end
          user.initialize_siritori
          TwitterBot.new(message: user.message, scname: user.scname, reply_to: tweet.id).tweet
        # 駅名しりとり返答
        when /駅$/
          if(user = User.find_by(id: tweet.user.id))
            user.siritori(match[1].strip.match(/(.+)駅$/)[1])
            TwitterBot.new(message: user.message, scname: user.scname, reply_to: tweet.id).tweet
          end
        # 難読駅名クイズスタート
        when /難読/
          user = User.find_or_initialize_by(id: tweet.user.id)
          if user.new_record?
            user.scname = tweet.user.screen_name
            user.name = tweet.user.name
            user.save!
          end
          user.initialize_nandoku
          TwitterBot.new(message: user.message, scname: user.scname, reply_to: tweet.id).tweet
        # 難読駅名クイズ返答
        when /えき$/
          if(user = User.find_by(id: tweet.user.id))
            user.nandoku(match[1].strip.match(/(.+)えき$/)[1])
            TwitterBot.new(message: user.message, scname: user.scname, reply_to: tweet.id).tweet
          end
        # 例外処理
        else
          TwitterBot.new(message: "われにはよく分からないのだ♪作者に伝えておくのだ♪", scname: tweet.user.screen_name, reply_to: tweet.id).tweet
        end
      # シャルロッテに反応
      elsif tweet.text.match(/^(?!RT |@).*シャルロッテ/)
        TwitterBot.new(message: 'マスター♪なんか呼ばれた気がしたのだ♪', scname: tweet.user.screen_name, reply_to: tweet.id).tweet
      end
    end
  end
  
  desc ""
  task debug: :environment do
    TwitterBot.new(message: "寒い冬には雪見だいふくが一番 #{Time.now.strftime('%N')}").tweet
  end
  
  desc ""
  task sample_stream: :environment do
    TweetStream.configure do |config|
      config.consumer_key       = Rails.application.secrets.consumer_key
      config.consumer_secret    = Rails.application.secrets.consumer_secret
      config.oauth_token        = Rails.application.secrets.access_token
      config.oauth_token_secret = Rails.application.secrets.access_token_secret
      config.auth_method        = :oauth
    end
    TweetStream::Client.new.sample do |status|
      puts "#{status.text}"
    end
  end
  
  desc ""
  task import: :environment do
    require 'csv'
    CSV.foreach(Rails.public_path.join('intro2.csv'), headers: true) do |data|
      station = Station.find_by name: data['name']
      if station.present?
        station.update nandoku_flag: true
      end
    end
  end
  
  desc ""
  task routine: :environment do
    japanese_regex = /\p{Hiragana}|\p{Katakana}|[一-龠々]/
    words = []
    tweets = TwitterBot.new.get_timeline
    # TODO: 結構重いので先にハッシュタグURLを削る
    tweets = tweets.map {|t|t.text}.join(' ')
    nm = Natto::MeCab.new(dicdir: "/usr/local/lib/mecab/dic/mecab-ipadic-neologd")
    nm.parse(tweets) do |n|
      next unless(n.feature.split(',')[0] == '名詞' && n.surface =~ japanese_regex && n.surface.length > 1)
      words << n.surface
    end
    word = words.sample
    # TODO: セリフのバリエーションをもう少し
    TwitterBot.new(message: "わぁ～#{word}なのだ～♪　われは#{word}に目がないのだ♪").tweet
  end
  
  desc "強制的にプロフィールを正常時に戻す"
  task refresh_profile: :environment do
    TwitterBot.new.change_profile('alive')
  end
  
end