TP_ALL_PACKAGES = freetype libpng libjpeg ruby libogg libvorbis glew gc
TP_PACKAGES = $(TP_ALL_PACKAGES)

export TP_INSTALL = $(shell echo `pwd`/install)
export TP_PACKAGE_MAKEFILE = $(shell echo `pwd`/Makefile.package)

TP_PACKAGE_BUILD_TARGETS = $(patsubst %,%.build,$(TP_PACKAGES))
TP_PACKAGE_CLEAN_TARGETS = $(patsubst %,%.clean,$(TP_PACKAGES))
TP_PACKAGE_CLEANDL_TARGETS = $(patsubst %,%.cleandl,$(TP_PACKAGES))

all: $(TP_PACKAGE_BUILD_TARGETS)

%.build:
	ruby universal.rb $*

clean: $(TP_PACKAGE_CLEAN_TARGETS)
ifeq ($(words $(TP_PACKAGES)), $(words $(TP_ALL_PACKAGES)))
	rm -rf $(TP_INSTALL)
endif

%.clean:
	$(MAKE) -C $* clean

cleandl: $(TP_PACKAGE_CLEANDL_TARGETS)

%.cleandl:
	$(MAKE) -C $* cleandl
