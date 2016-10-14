all: nginx

include Makefile.inc

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

NGX_LD_OPTS += -L$(LUADIR) -lluajit-5.1
NGX_LD_OPTS += -Wl,-z,relro -Wl,-E

LUA_MODULES += $(foreach m,$(LUA_MODS),$(shell find $(MODSDIR)/$(m)/lib -name "*.lua"))

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
	@CFLAGS="$(LUAJIT_CFLAGS)" make -C $(BUILDDIR)/luajit/src libluajit.a
	@ln -sf $(BUILDDIR)/libluajit.a $(BUILDDIR)/libluajit-5.1.a

lua-cjson: luajit.src lua-cjson.src
	@OBJS="lua_cjson.o strbuf.o fpconv.o"
	@LUA_INCLUDE_DIR=$(LUADIR) $(MAKE) -C $(BUILDDIR)/$@ $(OBJS)
	@ar rcus $(BUILDDIR)/$@/lib$@.a $(BUILDDIR)/$@/*.o
	$(eval NGX_LD_OPTS += -L$(BUILDDIR)/$@ -lluajit-5.1 -l$@)

lua-cmsgpack: luajit.src lua-cmsgpack.src
	@mkdir -p $(BUILDDIR)/$@
	@cd $(BUILDDIR)/$@ ; gcc -I$(LUADIR) -O2 -Wall -std=c99 lua_cmsgpack.c -c
	@ar rcus $(BUILDDIR)/$@/lib$@.a $(BUILDDIR)/$@/*.o
	$(eval NGX_LD_OPTS += -L$(BUILDDIR)/$@ -lluajit-5.1 -l$@)

openssl: openssl.src $(BUILDDIR)/openssl/libssl.a $(BUILDDIR)/openssl/libcrypto.a
	$(eval NGX_LD_OPTS += -L$(BUILDDIR)/$@ -Wl,--whole-archive -lssl -lcrypto -Wl,--no-whole-archive -ldl)
	$(eval NGX_CC_OPTS += -I$(BUILDDIR)/$@/include)

$(BUILDDIR)/openssl/%.a:
	cd $(BUILDDIR)/openssl && ./config no-shared $(OPENSSL)
	$(MAKE) -C $(BUILDDIR)/openssl

%.lua.build:
	@mkdir -p $(BUILDDIR)/lua-modules
	$(eval MODNAME=$(shell echo $*|sed 's|.*/lib/\(.*\)|\1|'|sed 's|/|_|g'))
	@ln -sf $*.lua $(BUILDDIR)/lua-modules/$(MODNAME).lua
	@luajit -bg $(BUILDDIR)/lua-modules/$(MODNAME).lua $(BUILDDIR)/lua-modules/$(MODNAME).lua.o

lua-modules: $(foreach module,$(LUA_MODULES),$(module).build)
	@ar rcus $(BUILDDIR)/lua-modules/lib$@.a $(BUILDDIR)/$@/*.o
	$(eval NGX_LD_OPTS += -L$(BUILDDIR)/$@ -Wl,--whole-archive -l$@ -Wl,--no-whole-archive)

nginx: $(NGX_TARGETS) zlib-ng.src nginx.src
	@cd $(BUILDDIR)/nginx && ./auto/configure $(NGX_CFG) \
		--with-cc-opt='$(NGX_CC_OPTS)' \
		--with-ld-opt='$(NGX_LD_OPTS)'

	$(MAKE) -C $(BUILDDIR)/nginx

%config: ;
	 make -f scripts/kconfig/GNUmakefile TOPDIR=. SRCDIR=scripts/kconfig $@

clean:
	rm -rf $(BUILDDIR)/*

# vim: ts=4 ai
