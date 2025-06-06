
TYPST   =   typst

FONTS_DIR = ../fonts
MAKE_DEPENDENCIES = make.depend

SOURCE  = mac80-manual.typ

PDF     = mac80-manual.pdf
PDF_STANDARD	= a-2b

SAMPLES = \
    fig01-sample.asm	\
    fig02a.asm	\
    fig02b.asm	\
    fig03a.asm	\
    fig03b.asm	\
    fig04.asm	\
    fig05.asm	\
    fig06.asm	\
    fig07.asm	\
    fig08.asm	\
    fig09.asm	\
    fig10-msglib.lib	\
    fig11.asm	\
    fig12.asm	\
    fig13.asm	\
    fig14.asm	\
    fig15.asm	\
    fig16.asm	\
    fig17.asm	\
    fig18.asm	\
    fig19.asm	\
    fig20.asm	\
    fig21.asm	\
    fig22.asm	\
    fig23.asm	\
    fig24.asm	\
    fig25.asm	\
    fig26-inter.lib	\
    fig27a-treadles.lib	\
    fig27b-buttons.lib	\
    fig28.asm	\
    fig29-inter.lib	\
    fig30.asm	\
    fig31.asm	\
    fig32-stack.lib	\
    fig33.asm	\
    fig34.asm	\
    fig36-dstack.lib	\
    fig37.asm	\
    fig40-simpio.lib	\
    fig41-compare.lib	\
    fig42.asm	\
    fig43-ncompare.lib	\
    fig44.asm	\
    fig45-when.lib	\
    fig46.asm	\
    fig47-dowhile.lib	\
    fig48.asm	\
    fig49-select.lib	\
    fig50.asm	\
    fig51.asm	\
    fig52.asm	\
    fig53-seqio.lib	\
    fig54.asm	\
    fig55.asm	\
    fig56.asm

all:    $(PDF) $(SAMPLES)

$(PDF):	$(SOURCE)
	$(TYPST) compile \
		--font-path $(FONTS_DIR) \
		--make-deps $(MAKE_DEPENDENCIES) \
		--pdf-standard $(PDF_STANDARD) \
			$(SOURCE) $(PDF)

-include $(MAKE_DEPENDENCIES)

clean:
	$(RM) $(PDF)

