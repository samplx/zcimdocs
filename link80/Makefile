
# a simple Makefile to compile the sources to a PDF

TYPST   =   typst

FONTS_DIR = ../fonts
MAKE_DEPENDENCIES = make.depend

SOURCE  = link80-manual.typ

PDF     = link80-manual.pdf
PDF_STANDARD	= a-2b

all:    $(PDF)

$(PDF):	$(SOURCE)
	$(TYPST) compile \
		--font-path $(FONTS_DIR) \
		--make-deps $(MAKE_DEPENDENCIES) \
		--pdf-standard $(PDF_STANDARD) \
			$(SOURCE) $(PDF)

-include $(MAKE_DEPENDENCIES)

clean:
	$(RM) $(PDF)

