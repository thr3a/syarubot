class TwitterBot
  include ActiveModel::Model
  attr_accessor :message, :reply_to, :scname
  validates :message, presence: true
  
  def tweet
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = Rails.application.secrets.consumer_key
      config.consumer_secret     = Rails.application.secrets.consumer_secret
      config.access_token        = Rails.application.secrets.access_token
      config.access_token_secret = Rails.application.secrets.access_token_secret
    end
    if self.valid?
      begin
        
        if self.reply_to
          client.update!("@#{self.scname} #{self.message}", in_reply_to_status_id: self.reply_to)
        else
          client.update!(self.message)
        end
        
      rescue Twitter::Error::DuplicateStatus
        self.message << ' ' + ('_' * rand(1..5))
        retry
      rescue => e
        p e.class
      end
    end
  end
end