
# a simple Makefile to compile the sources to a PDF

CP		=	cp --preserve=timestamps
RM		=	rm --force
TYPST   =   typst

FONTS_DIR = ../fonts
COMMON_DIR = ..

PDF_FILES  = \
	bdos-spec.pdf	\
	zcim-design.pdf \
	zcim-overview.pdf

TYP_SOURCE_FILES = ${PDF_FILES:.pdf=.typ}

ZCIM_LIBRARY = \
	zcim-library.typ

BDOS_COMMON = \
	bdos-common.typ

PDF_STANDARD	= a-2b

all:    ${PDF_FILES}

# create a local copy to work-around typst sandbox
${ZCIM_LIBRARY}:	${COMMON_DIR}/${ZCIM_LIBRARY}
	${RM} ${ZCIM_LIBRARY}
	${CP} ${COMMON_DIR}/${ZCIM_LIBRARY} ${ZCIM_LIBRARY}

${BDOS_COMMON}:		${COMMON_DIR}/${BDOS_COMMON}
	${RM} ${BDOS_COMMON}
	${CP} ${COMMON_DIR}/${BDOS_COMMON} ${BDOS_COMMON}

${PDF_FILES}:	%.pdf: %.typ ${ZCIM_LIBRARY} ${BDOS_COMMON}
	${TYPST} compile \
		--font-path ${FONTS_DIR} \
		--pdf-standard ${PDF_STANDARD} \
			$< $@

clean:
	${RM} ${PDF_FILES} ${ZCIM_LIBRARY}

clobber: clean

.PHONY: all clean clobber

