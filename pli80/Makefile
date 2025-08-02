
# a simple Makefile to compile the sources to a PDF

CP		=	cp --preserve=timestamps
RM		=	rm -f
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

# create a local copy to work-around typst sandbox
${ZCIM_LIBRARY}:	${COMMON_DIR}/${ZCIM_LIBRARY}
	${RM} ${ZCIM_LIBRARY}
	${CP} ${COMMON_DIR}/${ZCIM_LIBRARY} ${ZCIM_LIBRARY}

${PDF_FILES}:	%.pdf: %.typ
	${TYPST} compile \
		--font-path ${FONTS_DIR} \
		--pdf-standard ${PDF_STANDARD} \
			$< $@

clean:
	${RM} ${PDF_FILES} ${ZCIM_LIBRARY}

clobber: clean

.PHONY: all clean clobber

