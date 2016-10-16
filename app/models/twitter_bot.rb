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
      rescue Twitter::Error::DuplicateStatus
        @message << ' ' + ('_' * rand(1..5))
        retry
      rescue Twitter::Error::Forbidden => e
        p e.class
        p e.message
        icon = open(Rails.public_path.join('dead.png'))
        @client.update_profile name: 'シャルロッテ@リンク停止中…'
        @client.update_profile_image icon
      rescue => e
        # TODO: later
        p e.class
      end
    end
  end
end