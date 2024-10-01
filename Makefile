SHELL = bash
PWD   = $(shell pwd)
VERS  = $(shell ltxfileinfo -v $(NAME).dtx|sed -e 's/^v//')
LOCAL = $(shell kpsewhich --var-value TEXMFLOCAL)
UTREE = $(shell kpsewhich --var-value TEXMFHOME)
SRCURL= https://github.com/rsms/inter/releases/download/v4.0/Inter-4.0.zip
PKGDIR= $(PWD)/$(NAME)-$(VERS)

all:	$(NAME).pdf
	test -e README.txt && mv README.txt README || exit 0

$(NAME).pdf: $(NAME).dtx download
	pdflatex -shell-escape -recorder -interaction=batchmode $(NAME).dtx >/dev/null
	if [ -f $(NAME).glo ]; then makeindex -q -s gglo.ist -o $(NAME).gls $(NAME).glo; fi
	if [ -f $(NAME).idx ]; then makeindex -q -s gind.ist -o $(NAME).ind $(NAME).idx; fi
	pdflatex --recorder --interaction=nonstopmode $(NAME).dtx > /dev/null
	pdflatex --recorder --interaction=nonstopmode $(NAME).dtx > /dev/null

download:
ifeq (,$(wildcard Inter-4.0.zip))
	wget $(SRCURL)
endif

forcedownload:
	rm -f Inter-4.0.zip
	make download

clean:
	rm -f $(NAME).{aux,fls,glo,gls,hd,idx,ilg,ind,ins,log,out}

distclean: clean
	rm -f $(NAME).{pdf,sty} README

# Builds all the package: "installs" the files to a local folder with the package name
ctan-pkg: all
	mkdir -p $(PKGDIR)/{tex,source,doc}/latex/$(NAME)
	cp $(NAME).dtx $(PKGDIR)/source/latex/$(NAME)
	cp $(NAME).sty $(PKGDIR)/tex/latex/$(NAME)
	cp $(NAME).pdf $(PKGDIR)/doc/latex/$(NAME)
	cp README.md $(PKGDIR)/README.md
	zip -Drq $(NAME)-$(VERS).zip $(PKGDIR)
	rm -rf $(PWD)/$(NAME)

inst: all
	mkdir -p $(UTREE)/{tex,source,doc}/latex/$(NAME)
	cp $(NAME).dtx $(UTREE)/source/latex/$(NAME)
	cp $(NAME).sty $(UTREE)/tex/latex/$(NAME)
	cp $(NAME).pdf $(UTREE)/doc/latex/$(NAME)

install: all
	sudo mkdir -p $(LOCAL)/{tex,source,doc}/latex/$(NAME)
	sudo cp $(NAME).dtx $(LOCAL)/source/latex/$(NAME)
	sudo cp $(NAME).sty $(LOCAL)/tex/latex/$(NAME)
	sudo cp $(NAME).pdf $(LOCAL)/doc/latex/$(NAME)

zip: ctan-pkg
	@echo "Building the ctan-pkg recipe..."

