class TwitterBot
  include ActiveModel::Model
  attr_accessor :message, :reply_to, :scname
  validates :message, presence: true
  
  def tweet
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = Rails.application.secrets.consumer_key
      config.consumer_secret     = Rails.application.secrets.consumer_secret
      config.access_token        = Rails.application.secrets.access_token
      config.access_token_secret = Rails.application.secrets.access_token_secret
    end
    if self.valid?
      begin
        if @reply_to
          @client.update!("@#{@scname} #{@message}", in_reply_to_status_id: @reply_to)
        else
          @client.update!(@message)
        end
        if @client.user.name == Rails.application.config.name['dead']
          self.change_profile 'alive'
        end
      rescue Twitter::Error::DuplicateStatus
        @message << ' ' + ('_' * rand(1..5))
        retry
      rescue Twitter::Error::Forbidden => e
        p e.class
        p e.message
        self.change_profile 'dead'
      rescue => e
        # TODO: later
        p e.class
      end
    end
  end
  
  def get_timeline
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = Rails.application.secrets.consumer_key
      config.consumer_secret     = Rails.application.secrets.consumer_secret
      config.access_token        = Rails.application.secrets.access_token
      config.access_token_secret = Rails.application.secrets.access_token_secret
    end
    tweets = client.home_timeline({count:200})
    tweets.delete_if{|t| t.text.match(/^RT |^@/) || !t.source.match(/twitter/i)}
    return tweets
  end
  
  def change_profile status
    icon = open(Rails.public_path.join("#{status}.png"))
    @client.update_profile name: Rails.application.config.name[status]
    @client.update_profile_image icon
  end
end