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
        # 難読駅名クイズ返答
        when /難読.*登録/
          station = match[1].strip.match(/^(.+?)駅/)[1]
          if target = Station.find_by(name_orig: station)
            if target.nandoku_flag
              message = "どうやらその駅はすでに登録済なのだ♪ 他にあればわれに教えてほしいのだ♪"
            else
              target.update(nandoku_flag: true)
              message = "難読駅名クイズに登録したのだ♪ 他にもあればわれに教えてほしいのだ♪"
            end
          else
            message = "われはそんな駅知らないのだ♪ 他にあればわれに教えてほしいのだ♪"
          end
          TwitterBot.new(message: message, scname: tweet.user.screen_name, reply_to: tweet.id).tweet
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
        # パス
        when /パス$/
          if(user = User.find_by(id: tweet.user.id))
            if user.game_pass_count < 2
              user.use_pass_flag = true
              user.increment!(:game_pass_count, 1)
              case user.game_type
              when 'five_bomber'
                user.five_bomber('')
              when 'nandoku'
                user.nandoku('')
              when 'siritori'
                user.siritori('')
              end
              TwitterBot.new(message: user.message, scname: user.scname, reply_to: tweet.id).tweet
            else
              TwitterBot.new(message: 'もうパスは使えないのだ♪リセットしたい場合は、またリプしてくれれば１から遊べるのだ♪', scname: user.scname, reply_to: tweet.id).tweet
            end
          end
        # へるぷ
        when /使い方.*教えて/
          message = '
・「駅名しりとり」われとしりとり勝負なのだ♪
・「難読駅名クイズ」読めそうで読めない駅名クイズなのだ♪
・「ファイブボンバー」条件にあう駅を３つ答えるのだ♪

詳しくはURL先を見るのだ♪ https://thr3a.github.io/post/help/'
          TwitterBot.new(message: message, scname: tweet.user.screen_name, reply_to: tweet.id).tweet
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
  
  desc "定期ツイート"
  task routine: :environment do
    exclude_regex = '[^\p{Hiragana}\p{Katakana}一-龠々ー]' # 残したい文字の否定
    words = []
    nm = Natto::MeCab.new(dicdir: Rails.application.config.mecab_dic_path)
    tweets = TwitterBot.new.get_timeline
    tweets = tweets.map {|t|t.text.gsub(/#{exclude_regex}/, '')}.join(' ')
    case rand(3) # whenの最大値+1
    when 0
      nm.parse(tweets) do |n|
        next unless(n.feature.split(',')[0] == '名詞' && n.surface.length > 1)
        words << n.surface
      end
      word = words.sample
      message = "わぁ～#{word}なのだ～♪　われは#{word}に目がないのだ♪"
    when 1
      result = Ikku::Reviewer.new.search(tweets)
      return if result.blank?
      haiku = result.map{|e|e.phrases.map(&:join).join(' ')}
      message = "ここで一句、 #{haiku.sample} なのだ〜♪"
    when 2
      nm.parse(tweets) do |n|
        next unless(n.feature.split(',')[2] == '地域')
        words << n.surface
      end
      word = words.sample
      message = "今度シーナさんと一緒に#{word}へ予定なのだ♪楽しみなのだ♪"
    end
    TwitterBot.new(message: message).tweet
  end
  
  desc "告知ツイート confg/schedule.rb参照"
  task notice: :environment do
    list = [
      "われの問題に答えられなかったら「パス」とリプするのだ♪",
      "「使い方教えて」とリプするとわれが案内するのだ♪ https://thr3a.github.io/post/help/",
      "われに難読駅を教えるとクイズに出題されるのだ♪ 詳しくは https://thr3a.github.io/post/2016/11/03/add-nandoku-question/"
    ]
    TwitterBot.new(message: "【定期】 #{list.sample} #{Time.now.strftime('%F %R')}").tweet
  end
end
