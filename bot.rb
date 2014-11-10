#encoding: UTF-8

require "rubygems"
require "tweetstream"
require "em-http-request"
require "httparty"
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

# functions
COTATIONS = {}
BIT_AVERAGE_URL = "https://api.bitcoinaverage.com/all" #bitcoinaverage.com API endpoint

def final_amount(amount, currency)
  COTATIONS[:data][currency]["averages"]["last"] * amount
end

def update_cotations
  return if cotations_updated?
  
  puts "Will fetch new cotations"
  response = HTTParty.get(BIT_AVERAGE_URL)
  COTATIONS[:data] = JSON.parse response.body
  COTATIONS[:timestamp] = Time.now
  puts "Cotations fetched"
  return COTATIONS
end

def cotations_updated?
  COTATIONS[:timestamp] && (Time.now - COTATIONS[:timestamp]) < 10
end

#def fetch_cotations
#  response = HTTParty.get(BIT_AVERAGE_URL)
#  COTATIONS[:data] = JSON.parse response.body
#  COTATIONS[:timestamp] = Time.now
#end

# variables
twurl = URI.parse("https://api.twitter.com/1.1/statuses/update.json")
bit_regex = /\d+(\.|,)?(\d+)?/ #any amount
currency_regex = /#[A-Z]{3}/ # "#" followed by 3 capital letters
bitcoin_cotation = 0
has_cotation = false
cotation_timestamp = ""

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
        bit_amount = status.text[bit_regex].to_f # grabs the amount on the tweet
        currency = status.text[currency_regex][1..-1] # takes the "#" out
        #p bit_amount
        #p currency

        # bloquing cotation update
       	operation = proc {
        	update_cotations              
        }

        callback = proc {
        	this_amount = final_amount(bit_amount, currency)              
        }
				
        EventMachine.defer(operation, callback)
        
        #create the reply tweet
        @reply = "#{bit_amount} bitcoins in #{currency} is #{this_amount}"
        puts reply
        
        puts "got out of the defer"
        tweet = {
            "status" => "@#{status.user.screen_name} " + reply,
            "in_reply_to_status_id" => status.id.to_s
            }
        puts tweet
        
				authorization = SimpleOAuth::Header.new(:post, twurl.to_s, tweet, OAUTH)
        
        http = EventMachine::HttpRequest.new(twurl.to_s).post({
            	:head => {"Authorization" => authorization},
            	:body => tweet
        })
        	http.errback {
                puts "[ERROR] errback"
          }
        	http.callback {
               if http.response_header.status.to_i == 200
                 puts "[HTTP_OK] #{http.response_header.status}"
               else
                 puts "[HTTP_ERROR] #{http.response_header.status}"
               end
          }

        
#        #if has_cotation == false || (cotation_timestamp - Time.now) > 10 # if there was elapsed
#        EventMachine.run {
#            conversion_url = bit_average_url + currency + "/"
#            puts conversion_url
#            # gets the bitcoin cotation at bitcoinaverage.com API
#            get_cotation = EventMachine::HttpRequest.new(conversion_url).get
# 
#            get_cotation.errback { puts "[ERROR] errback" }
#            get_cotation.callback {
#                json = JSON.parse get_cotation.response
#                bitcoin_cotation = json["last"]
#                has_cotation = true
#                cotation_timestamp = json["timestamp"]
#                final_amount = bitcoin_cotation * bit_amount
# 
#                http.
#                
#                EventMachine.stop
#            }
#        }
#        puts "estou fora da EventMachine"
#    else
#        puts "Nao deveria passar por aqui"
    end
end