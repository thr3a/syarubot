namespace :bot do
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  desc "TODO"
  task start: :environment do
    client_stream = Twitter::Streaming::Client.new do |config|
      config.consumer_key        = Rails.application.secrets.consumer_key
      config.consumer_secret     = Rails.application.secrets.consumer_secret
      config.access_token        = Rails.application.secrets.access_token
      config.access_token_secret = Rails.application.secrets.access_token_secret
    end
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = Rails.application.secrets.consumer_key
      config.consumer_secret     = Rails.application.secrets.consumer_secret
      config.access_token        = Rails.application.secrets.access_token
      config.access_token_secret = Rails.application.secrets.access_token_secret
    end
    client_stream.user do |tweet|
      next unless tweet.is_a?(Twitter::Tweet)
      # リプライ
      if match = tweet.text.match(/^@#{Rails.application.secrets.own_name} (.+)/)
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
          user.reply(tweet.id)
        # 駅名しりとり返答
        when /駅$/
          if(user = User.find_by(id: tweet.user.id))
            user.siritori(match[1].strip.match(/(.+)駅$/)[1])
            user.reply(tweet.id)
          end
        end
      end
    end
  end
end