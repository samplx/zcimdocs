
# a simple Makefile to compile the sources to a PDF

RM		=	rm --force
TYPST   =   typst

FONTS_DIR = ../fonts
COMMON_DIR = ..

PDF_FILES  = \
	pli80-applications-guide.pdf	\
	pli80-language-manual.pdf \
	pli80-programmers-guide.pdf \
	pli80-reference-manual.pdf

TYP_SOURCE_FILES = ${PDF_FILES:.pdf=.typ}

ZCIM_LIBRARY = \
	zcim-library.typ

PDF_STANDARD	= a-2b

all:    ${PDF_FILES}  ${ZCIM_LIBRARY}

${PDF_FILES}:	%.pdf: %.typ ${COMMON_DIR}/${ZCIM_LIBRARY}
	${TYPST} compile \
		--root ${COMMON_DIR} \
		--font-path ${FONTS_DIR} \
		--pdf-standard ${PDF_STANDARD} \
			$< $@

clean:
	${RM} ${PDF_FILES}

clobber: clean

.PHONY: all clean clobber

