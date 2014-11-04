require "rubygems"
require "tweetstream"
require "em-http-request"
require "simple_oauth"
require "json"
# require "uri"
 
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

# variables 
twurl = "https://api.twitter.com/1.1/statuses/update.json" #twitter API endpoint
# authorization = SimpleOAuth::Header.new(:post, twurl.to_s, tweet, OAUTH)
bit_average_url = "https://api.bitcoinaverage.com/ticker/" #bitcoinaverage.com API endpoint
bit_regex = /\d+(\.|,)?(\d+)?/ #any amount
currency_regex = /#[A-Z]{3}/ # "#" followed by 3 capital letters
bitcoin_cotation = 0
has_cotation = false
cotation_timestamp = ""

# bitcoin average request definition
#def get_value(amount)
#    get_average = EventMachine::HttpRequest.new(bit_average_url.to_s)
    
# user stream connection
@client  = TweetStream::Client.new

puts "[STARTING] bot..."
@client.userstream() do |status|
    puts "[NEW TWEET] #{status.text}"

    retweet = status.retweet?
    reply_to_me = status.in_reply_to_user_id == ACCOUNT_ID
    contains_currency = status.text =~ currency_regex
    contains_amount = status.text =~ bit_regex

    puts retweet
    puts reply_to_me
    puts contains_currency
    puts contains_amount
    
    # check if stream is not a retweet and is valid
    if !retweet && reply_to_me && contains_amount && contains_currency
        puts "[PROCESSING] #{status.text}"
        bit_amount = status.text[bit_regex] # grabs the amount on the tweet
        currency = status.text[currency_regex][1..-1] # takes the "#" out
        p bit_amount
        p currency

        #if has_cotation == false || (cotation_timestamp - Time.now) > 10 # if there was elapsed
        EventMachine.run {
            conversion_url = bit_average_url + currency + "/"
            puts conversion_url
            get_cotation = EventMachine::HttpRequest.new(conversion_url).get

            get_cotation.errback { puts "[ERROR] errback" }
            get_cotation.callback {
                bitcoin_cotation = get_cotation.response
                json = JSON.parse bitcoin_cotation
                
                puts json["24h_avg"]

                EventMachine.stop
            }   
        }
    else
        puts "Nao deveria passar por aqui"
    end
end