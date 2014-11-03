require "rubygems"
require "tweetstream"
require "em-http-request"
require "simple_oauth"
require "json"
require "uri"
 
# require the file with the API keys
require "./oauth-keys"

# config oauth
ACCOUNT_ID = OAUTH[:token].split("-").first.to_i
 
TweetStream.configure do |config|
 config.consumer_key       = OAUTH[:consumer_key]
 config.consumer_secret    = OAUTH[:consumer_secret]
 config.oauth_token        = OAUTH[:token]
 config.oauth_token_secret = OAUTH[:token_secret]
 config.auth_method = :oauth
end

# user stream connection
@client  = TweetStream::Client.new
 
puts "[STARTING] bot..."
@client.userstream() do |status| 
  
  puts status.text  # print do texto do tweet
end
