require_relative 'resque_helper'

class SendEmail
  extend ResqueHelper
  @queue = 'email_influencer'

  def self.perform(params)
    
  end
end
