DEPSDIR=$(CURDIR)/dependencies
MODSDIR=$(CURDIR)/lua-modules

BUILDDIR=$(CURDIR)/build
PATCHDIR=$(CURDIR)/patches

LUADIR=$(BUILDDIR)/luajit/src

export LUAJIT_LIB=$(LUADIR)
export LUAJIT_INC=$(LUADIR)

NGX_CC_OPTS += -O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2
NGX_CC_OPTS += -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4
NGX_CC_OPTS += -grecord-gcc-switches -m64 -mtune=generic

NGX_LD_OPTS += -Wl,-z,relro -Wl,-E
NGX_LD_OPTS += -L$(LUADIR)

include config/Makefile

LUA_MODULES += $(foreach m,$(LUA_MODS),$(shell find $(MODSDIR)/$(m) -name "*.lua" -printf "$(m)=%P\n"))

all: nginx

%.src:
	@$(MAKE) $*.tar
	@$(MAKE) $*.patch

%.tar:
	@mkdir -p $(BUILDDIR)
	@cd $(DEPSDIR)/$* ; \
		git archive --format tar --prefix $*/ HEAD | tar x -C $(BUILDDIR)

%.patch:
	@cat $(PATCHDIR)/$*/* 2>/dev/null|patch -p1 -d $(BUILDDIR)/$*

luajit: luajit.src $(LUAJIT_TARGETS)
	@CFLAGS="$(LUAJIT_CFLAGS)" make -C $(LUADIR) libluajit.a
	@ln -sf $(LUADIR)/libluajit.a $(LUADIR)/libluajit-5.1.a

lua-cjson: luajit.src lua-cjson.src
	@OBJS="lua_cjson.o strbuf.o fpconv.o"
	@LUA_INCLUDE_DIR=$(LUADIR) $(MAKE) -C $(BUILDDIR)/$@ $(OBJS)
	@ar rcus $(BUILDDIR)/$@/lib$@.a $(BUILDDIR)/$@/*.o
	$(eval NGX_LD_OPTS += -L$(BUILDDIR)/$@ -lluajit-5.1 -l$@)

lua-cmsgpack: luajit.src lua-cmsgpack.src
	@cd $(BUILDDIR)/$@ ; gcc -I$(LUADIR) -O2 -Wall -std=c99 lua_cmsgpack.c -c
	@ar rcus $(BUILDDIR)/$@/lib$@.a $(BUILDDIR)/$@/*.o
	$(eval NGX_LD_OPTS += -L$(BUILDDIR)/$@ -lluajit-5.1 -l$@)

libucl: luajit.src libucl.src
	@rm -f $(BUILDDIR)/$@/src/libucl.la
	@test -f $(BUILDDIR)/$@/configure || (cd $(BUILDDIR)/$@ ; ./autogen.sh)
	@test -f $(BUILDDIR)/$@/Makefile || (cd $(BUILDDIR)/$@ ; \
		./configure --enable-static --enable-regex)
	@$(MAKE) -C $(BUILDDIR)/$@/src libucl.la
	@cd $(BUILDDIR)/$@/lua ; \
		gcc -O3 -Wall -I../include -I../src -I../uthash -I$(LUADIR) lua_ucl.c -c
	@ar rs $(BUILDDIR)/$@/src/.libs/libucl.a $(BUILDDIR)/$@/lua/lua_ucl.o
	@mv $(BUILDDIR)/$@/src/.libs/libucl.a $(BUILDDIR)/$@/liblua-ucl.a
	$(eval NGX_LD_OPTS += -L$(BUILDDIR)/$@ -lluajit-5.1 -llua-ucl)

openssl: openssl.src $(BUILDDIR)/openssl/libssl.a $(BUILDDIR)/openssl/libcrypto.a
	$(eval NGX_LD_OPTS += -L$(BUILDDIR)/$@ -Wl,--whole-archive -lssl -lcrypto -Wl,--no-whole-archive -ldl)
	$(eval NGX_CC_OPTS += -I$(BUILDDIR)/$@/include)

$(BUILDDIR)/openssl/%.a:
	cd $(BUILDDIR)/openssl && ./config no-shared $(OPENSSL)
	$(MAKE) -C $(BUILDDIR)/openssl

%.lua.build:
	$(eval DIRNAME=$(shell echo $*|cut -f1 -d=))
	$(eval LUANAME=$(shell echo $*|cut -f2 -d=).lua)
	$(eval MODNAME=$(shell echo $(LUANAME)|sed 's|/|_|g'))

	@ln -sf $(MODSDIR)/$(DIRNAME)/$(LUANAME) $(BUILDDIR)/lua-modules/$(MODNAME)
	@luajit -bg $(BUILDDIR)/lua-modules/$(MODNAME) $(BUILDDIR)/lua-modules/$(MODNAME).o

lua-modules.clean:
	@rm -f $(BUILDDIR)/lua-modules/*
	@mkdir -p $(BUILDDIR)/lua-modules

lua-modules: lua-modules.clean $(foreach module,$(LUA_MODULES),$(module).build)
	@ar rcus $(BUILDDIR)/lua-modules/lib$@.a $(BUILDDIR)/$@/*.o
	$(eval NGX_LD_OPTS += -L$(BUILDDIR)/$@ -Wl,--whole-archive -l$@ -Wl,--no-whole-archive)

%config: ;
	@touch $(CURDIR)/.config
	@mkdir -p $(BUILDDIR)/kconfig/lxdialog
	make -f config/kconfig/GNUmakefile TOPDIR=. SRCDIR=config/kconfig BUILDDIR=$(BUILDDIR) CONFIG_= $@

nginx: $(NGX_TARGETS) zlib-ng.src nginx.src
	@cd $(BUILDDIR)/nginx && ./auto/configure $(NGX_CFG) \
		--with-cc-opt='$(NGX_CC_OPTS)' \
		--with-ld-opt='$(NGX_LD_OPTS)'

	$(MAKE) -C $(BUILDDIR)/nginx
	mkdir -p $(BUILDDIR)/bin
	@cp $(BUILDDIR)/$@/objs/$@ $(BUILDDIR)/bin
	@strip $(BUILDDIR)/bin/nginx
	@which upx >/dev/null && upx --best --ultra-brute $(BUILDDIR)/bin/nginx

clean:
	rm -rf $(BUILDDIR)/*

# vim: ts=4 ai
