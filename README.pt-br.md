BitcoinConversions
=================

BitcoinConversions é um robô do Twitter que responde a menção com um valor em bitcoin e uma moeda, com a conversão na moeda fornecida.

Uso
===

Para usá-lo você só precisa de uma conta no Twitter. Até agora, o [@bitconversions](https://twitter.com/bitconversions) converte apenas Bitcoin para outras moedas, não o contrário. A fim de fazer isso, você deve mencionar @bitconversions e enviar uma quantidade numérica juntamente com uma hash tag com o código internacional da moeda com 3 letras maiúsculas.

Para saber quanto é meio Bitcoin em dólares norte-americanos, basta twittar:

    @bitconversions 0,5 #USD

Você também pode pedir em linguagem natural em qualquer idioma:

    @bitconversions quanto é 0,5 bitcoins em #USD?

O robô deve responder com a conversão em apenas alguns segundos. Ele usa a API do [bitcoinaverage.com](http://bitcoinaverage.com) para encontrar as cotações. Você pode verificar qual é o seu código por lá.

Contribuindo
===========

O robô é inteiramente escrito em Ruby. Para testá-lo, você só precisa clonar o repositório, instalar as dependências com o bundler e configurar um servidor Redis. Pessoalmente, uso o Docker para a execução de banco de dados de desenvolvimento. Depois disso, você só precisa criar um arquivo oauth-keys.rb no diretório raiz (há um arquivo oauth-keys.rb.example que você pode seguir) com as chaves de acesso do OAuth e as informações de conexão com o Redis.

Depois de disso, espera-se que tudo funcione bem! :-) Você pode iniciar o servidor com `bundle exec rackup`
