URL=http://lab.hakim.se/reveal-js
REPO=https://github.com/hakimel/reveal.js/archive/master.zip
THEME=sky
FLAGS=-s \
	  -f rst -t revealjs \
	  --slide-level=2 \
	  -V revealjs-url=./reveal.js \
	  -V theme=${THEME} \
	  -V slideNumber=true \
	  --template=default.revealjs \
	  --no-highlight

all: index.html reveal.js

reveal.js:
	wget -N ${REPO}
	unzip master.zip
	mv reveal.js-master reveal.js
	cp nci.css reveal.js/css/theme/

index.html: payu.rst
	pandoc ${FLAGS} $^ -o $@

clean:
	rm -f index.html 
