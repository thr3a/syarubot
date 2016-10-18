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
        # 駅名しりとりスタート
        when /駅名しりとり/
          user = User.find_or_initialize_by(id: tweet.user.id)
          if user.new_record?
            user.scname = tweet.user.username
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
        else
          user = User.find_or_initialize_by(id: tweet.user.id)
          if user.new_record?
            user.scname = tweet.user.username
            user.name = tweet.user.name
            user.save!
          end
          TwitterBot.new(message: "われにはよく分からないのだ♪作者に伝えておくのだ♪", scname: user.scname, reply_to: tweet.id).tweet
        end
      end
    end
  end
  
  desc ""
  task debug: :environment do
    TwitterBot.new(message: '寒い冬には雪見だいふくが一番').tweet
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
end