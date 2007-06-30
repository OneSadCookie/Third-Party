TP_URL = ftp://ftp.ruby-lang.org/pub/ruby/1.8/ruby-1.8.6.tar.bz2
TP_DIR = ruby-1.8.6
TP_LIB = libruby-static.a
TP_EXTRA_CONFIGURE_ARGS = ac_cv_func_setpgrp_void=no
TP_MAKE_TARGETS = all install
TP_PATCH = ruby.patch

export EXTS = digest,openssl,socket,stringio,zlib
export DLDFLAGS = $(CFLAGS)

include $(TP_PACKAGE_MAKEFILE)
