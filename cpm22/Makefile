
# a simple Makefile to compile the sources to a PDF

RM		=	rm --force
TYPST   =   typst

FONTS_DIR = ../fonts
COMMON_DIR = ..

PDF_FILES  = \
	cpm22-manual.pdf \
	cpm22-alteration-guide.pdf	\
	cpm22-features-and-facilities.pdf \
	cpm22-interface-guide.pdf

TYP_SOURCE_FILES = ${PDF_FILES:.pdf=.typ}

ZCIM_LIBRARY = \
	zcim-library.typ

BDOS_COMMON = \
	bdos-common.typ

PDF_STANDARD	= a-2b

all:    ${PDF_FILES}

${PDF_FILES}:	%.pdf: %.typ ${COMMON_DIR}/${ZCIM_LIBRARY} ${COMMON_DIR}/${BDOS_COMMON}
	${TYPST} compile \
		--root ${COMMON_DIR} \
		--font-path ${FONTS_DIR} \
		--pdf-standard ${PDF_STANDARD} \
			$< $@

clean:
	${RM} ${PDF_FILES}

clobber: clean

.PHONY: all clean clobber

