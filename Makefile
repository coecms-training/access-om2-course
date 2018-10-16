URL=http://lab.hakim.se/reveal-js
REPO=https://github.com/hakimel/reveal.js/archive/master.zip
THEME=smallsky
FLAGS=-s \
	  -f rst -t revealjs \
	  --slide-level=2 \
	  -V revealjs-url=./reveal.js \
	  -V theme=${THEME} \
	  -V slideNumber=true \
	  --template=default.revealjs \
	  --no-highlight

DATE=$(shell date)

all: index.html reveal.js commit install

reveal.js:
	wget -N ${REPO}
	unzip master.zip
	mv reveal.js-master reveal.js
	cp smallsky.css reveal.js/css/theme/
	git add reveal.js/css/theme/smallsky.css

index.html: payu.rst
	pandoc ${FLAGS} $^ -o $@

commit: 
	git commit -a -m 'Automatic build on ${DATE}'

install: 
	git push

clean:
	rm -f index.html 
