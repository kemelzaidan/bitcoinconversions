BitcoinConversions
==================

Se você fala português, leia o [README.pt-br.md](https://github.com/kemelzaidan/bitcoinconversions/blob/master/README.pt-br.md).

Bitcoin Conversions is a twitter bot which replies a twitter mention with a value in bitcoin and a currency, with the actual value in the given fiat currency

## Usage

To use it you just need a Twitter account. Right now, bitconversions just converts Bitcoin to fiat currencies, not the opposite. In order to do so, you must mention [@bitconversions](https://twitter.com/bitconversions) and send a number amount together with a hash tag of the international currency code in capital letters.

To know how much is a half Bitcoin in US dollars is just tweeting:

    @bitconversions 0.5 #USD

You could also ask it in any language:

    @bitconversions how much is 0.5 bitcoins in #USD?

The bot should reply with the answer in just a few seconds. The bot uses [bitcoinaverage.com](https://bitcoinaverage.com) API to retrieve cotations. You can check which is your code in there.

## Contributing

The bot is entirely writter in Ruby. To test it, you just need to clone the repository, install the dependencies with bundler and setup a Redis server. Personally, I use [Docker](http://www.docker.com) for running de development database. After that you just need to create an oauth-keys.rb file in the root directory (there is a oauth-keys.rb.example you can follow) with the oauth keys and Redis access info.

After all of it, everything will hopefully work well! :-)
You can start the server with `bundle exec rackup`

