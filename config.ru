#encoding: UTF-8

require "rubygems"
require "tweetstream"
require "em-http-request"
require "httparty"
require "simple_oauth"
require "json"
require "uri"
require "logger"

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
COTATIONS = { count: 0 }
BIT_AVERAGE_URL = "https://api.bitcoinaverage.com/all" #bitcoinaverage.com API endpoint
LOGGER = Logger.new('ruby-process.log')
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

LOGGER.info "[STARTING] rack..."
run lambda { |env| [200, {'Content-Type'=>'text/plain'}, StringIO.new("#{COTATIONS[:count]} conversions so far")] }

Thread.new do
LOGGER.info "[STARTING] bot..."
@client.userstream() do |status|
    LOGGER.info "[NEW TWEET] #{status.text}"

    retweet = status.retweet?
    reply_to_me = status.in_reply_to_user_id == ACCOUNT_ID
    contains_currency = status.text =~ currency_regex
    contains_amount = status.text =~ bit_regex

    LOGGER.info retweet
    LOGGER.info reply_to_me
    LOGGER.info contains_currency
    LOGGER.info contains_amount
    
    # check if stream is not a retweet and is valid
    if !retweet && reply_to_me && contains_amount && contains_currency
        LOGGER.info "[PROCESSING] #{status.text}"
        bit_amount = status.text[bit_regex].to_f # grabs the amount on the tweet
        currency = status.text[currency_regex][1..-1] # takes the "#" out
        p bit_amount
        p currency

        # bloquing cotation update
       	operation = proc {
        	def cotations_updated?
              COTATIONS[:timestamp] && (Time.now - COTATIONS[:timestamp]) < 10
            end
          
          
            if !cotations_updated?
                LOGGER.info "Will fetch new cotations"
                response = HTTParty.get(BIT_AVERAGE_URL)
                COTATIONS[:data] = JSON.parse response.body
                COTATIONS[:timestamp] = Time.now
                LOGGER.info "Cotations fetched: #{COTATIONS}"
            end

            def final_amount(amount, currency)
                LOGGER.info "Will compute final_amount"
                if COTATIONS[:data][currency]
	            	COTATIONS[:data][currency]["averages"]["last"] * amount
                else
                    -1
                end
        	end

            result = final_amount(bit_amount, currency)
            result = result.round(2)
            LOGGER.info "Should return #{result}"
        	result
        }

            callback = proc { |this_amount|
                if COTATIONS[:data][currency]
			        reply = "#{bit_amount} bitcoins in #{currency} is #{this_amount}"
                else
                    reply = "Currency #{currency} not found :("
                 end
        #create the reply tweet
        LOGGER.info reply
        
        tweet = {
            "status" => "@#{status.user.screen_name} " + reply,
            "in_reply_to_status_id" => status.id.to_s
            }
        LOGGER.info tweet
        
		authorization = SimpleOAuth::Header.new(:post, twurl.to_s, tweet, OAUTH)
        
        http = EventMachine::HttpRequest.new(twurl.to_s).post({
            	:head => {"Authorization" => authorization},
            	:body => tweet
        })
        	http.errback {
                LOGGER.info "[ERROR] errback"
          }
        	http.callback {
               if http.response_header.status.to_i == 200
                COTATIONS[:count] += 1
                 LOGGER.info "[HTTP_OK] #{http.response_header.status}"
               else
                 LOGGER.info "[HTTP_ERROR] #{http.response_header.status}"
               end
          }
        }
        
        EventMachine.defer(operation, callback)
    end
end
end

