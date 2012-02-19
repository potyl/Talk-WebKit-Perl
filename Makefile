downloads/webkit-perl.pdf: index.html
	xvfb-run --server-args="-screen 0 1280x800x24" deckjs2pdf --pause 1000 --width 1280 --height 800 $< $@


.PHONY: all
all: downloads/webkit-perl.pdf


.PHONY: clean
clean:
	@rm -f downloads/webkit-perl.pdf
