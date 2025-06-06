
# a simple Makefile to compile the sources to a PDF

SUBDIRS	=	\
	cpm22	\
	link80	\
	mac80

all:	$(SUBDIRS)
	for d in $(SUBDIRS); do $(MAKE) -C $$d; done


