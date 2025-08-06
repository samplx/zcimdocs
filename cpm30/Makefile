
# a simple Makefile to compile the sources to a PDF

RM		=	rm --force
TYPST   =   typst

FONTS_DIR = ../fonts
COMMON_DIR = ..

PDF_FILES  = \
	cpm30-command-summary.pdf	\
	cpm30-programmers-manual.pdf \
	cpm30-system-guide.pdf \
	cpm30-users-guide.pdf

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

