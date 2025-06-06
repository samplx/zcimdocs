
# a simple Makefile to compile the sources to a PDF

TYPST   =   typst

FONTS_DIR = ../fonts
MAKE_DEPENDENCIES = make.depend

SOURCE  = cpm22-manual.typ

PDF     = cpm22-manual.pdf
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

