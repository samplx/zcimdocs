
# a simple Makefile to compile the sources to a PDF

SUBDIRS	=	\
	asm 	\
	cpm13 	\
	cpm14 	\
	cpm20 	\
	cpm22	\
	cpm30	\
	ddt		\
	ed		\
	link80	\
	mac80	\
	pascal	\
	zcim

all:	$(SUBDIRS)
	for d in $(SUBDIRS); do $(MAKE) -C $$d; done


clean:	$(SUBDIRS)
	for d in $(SUBDIRS); do $(MAKE) -C $$d clean; done
