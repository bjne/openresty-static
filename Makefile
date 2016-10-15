DEPSDIR=$(CURDIR)/dependencies
LUA_MODSDIR=$(CURDIR)/lua-modules
NGX_MODSDIR=$(CURDIR)/ngx-modules

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

space := $(eval) $(eval)

all: nginx

%.submodule: ; @git submodule --quiet update --init $* || exit 0

%.src: %.patch ;

%.patch: %.tar
	$(eval M = $(shell basename $*))
	@cat $(PATCHDIR)/$(M)/* 2>/dev/null|patch -p1 -d $(BUILDDIR)/$(M)

%.tar: %.submodule
	$(eval M = $(shell basename $*))
	@mkdir -p $(BUILDDIR)
	@cd $* ; git archive --format tar --prefix $(M)/ HEAD | tar x -C $(BUILDDIR)

luajit: dependencies/luajit.src $(LUAJIT_TARGETS)
	@CFLAGS="$(LUAJIT_CFLAGS)" make -C $(LUADIR) libluajit.a
	@ln -sf $(LUADIR)/libluajit.a $(LUADIR)/libluajit-5.1.a

lua-cjson: dependencies/luajit.src lua-modules/lua-cjson.src
	@OBJS="lua_cjson.o strbuf.o fpconv.o"
	@LUA_INCLUDE_DIR=$(LUADIR) $(MAKE) -C $(BUILDDIR)/$@ $(OBJS)
	@ar rcus $(BUILDDIR)/$@/lib$@.a $(BUILDDIR)/$@/*.o
	$(eval NGX_LD_OPTS += -L$(BUILDDIR)/$@ -lluajit-5.1 -l$@)

lua-cmsgpack: dependencies/luajit.src lua-modules/lua-cmsgpack.src
	@cd $(BUILDDIR)/$@ ; gcc -I$(LUADIR) -O2 -Wall -std=c99 lua_cmsgpack.c -c
	@ar rcus $(BUILDDIR)/$@/lib$@.a $(BUILDDIR)/$@/*.o
	$(eval NGX_LD_OPTS += -L$(BUILDDIR)/$@ -lluajit-5.1 -l$@)

libucl: dependencies/luajit.src lua-modules/libucl.src
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

openssl: dependencies/openssl.src $(BUILDDIR)/openssl/libssl.a $(BUILDDIR)/openssl/libcrypto.a
	$(eval NGX_LD_OPTS += -L$(BUILDDIR)/$@ \
		-Wl,--whole-archive -lssl -lcrypto -Wl,--no-whole-archive -ldl)
	$(eval NGX_CC_OPTS += -I$(BUILDDIR)/$@/include)

$(BUILDDIR)/openssl/%.a:
	cd $(BUILDDIR)/openssl && ./config no-shared $(OPENSSL)
	$(MAKE) -C $(BUILDDIR)/openssl

%.lua.build:
	$(eval D=$(shell echo $*|cut -f1 -d=))
	$(eval L=$(shell echo $*|cut -f2 -d=).lua)
	$(eval M=$(shell echo $(L)|sed 's|/|_|g'))

	@ln -sf $(LUA_MODSDIR)/$(D)/$(L) $(BUILDDIR)/lua-modules/$(M)
	@luajit -bg $(BUILDDIR)/lua-modules/$(M) $(BUILDDIR)/lua-modules/$(M).o

lua-mods: $(foreach m,$(LUA_MODS),lua-modules/$(shell echo $(m)|cut -f1 -d/).submodule)
	$(eval LUA_SUBMODULES += $(foreach m,$(LUA_MODULES),\
		$(shell echo lua-modules/$(m)|cut -f1 -d=|cut -f1-2 -d/).submodule\
	))

	$(eval LUA_MODULES += $(foreach m,$(LUA_MODS),\
		$(shell find $(LUA_MODSDIR)/$(m) -name "*.lua" -printf "$(m)=%P\n")\
	))

lua-modules.clean:
	@rm -f $(BUILDDIR)/lua-modules/*
	@mkdir -p $(BUILDDIR)/lua-modules

lua-modules.build: $(addsuffix .build, $(LUA_MODULES))

lua-modules: lua-modules.clean lua-mods $(LUA_SUBMODULES)
	@$(MAKE) $@.build LUA_MODULES="$(LUA_MODULES)"
	@ar rcus $(BUILDDIR)/lua-modules/lib$@.a $(BUILDDIR)/$@/*.o
	$(eval NGX_LD_OPTS += -L$(BUILDDIR)/$@ -Wl,--whole-archive -l$@ -Wl,--no-whole-archive)

%config: ;
	@touch $(CURDIR)/.config
	@mkdir -p $(BUILDDIR)/kconfig/lxdialog
	make -f config/kconfig/GNUmakefile TOPDIR=. SRCDIR=config/kconfig BUILDDIR=$(BUILDDIR) CONFIG_= $@

nginx: $(NGX_TARGETS) dependencies/nginx.src $(addsuffix .submodule, $(NGX_SUBMODULES))
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

version about: ;@git submodule status|cut -f2- -d/|sort
%.version: ;@git submodule status|cut -f2- -d/|grep "^$* "|sed 's/^$* (\(.*\))/\1/'

submodule_status: ;
	$(eval SUBMODULES = \n$(shell git submodule --quiet foreach 'echo $${path}'))

%.print_status:
	$(eval N = $(shell echo $*|cut -f2 -d/))
	$(eval C = $(shell cd $* && git rev-parse HEAD))
	$(eval C = $(shell cd $* && git describe --tags --always $(C)))

	$(eval B = $(shell cd $* && git branch|tail -1|sed 's/^[* ]*//'))
	$(eval U = $(shell cd $* && git rev-parse refs/heads/$(B)))
	$(eval U = $(shell cd $* && git describe --tags --always $(U)))

	@test "$(C)" = "$(U)" \
		&& (printf "= %-35.35s %-20.20s\n" $N $C) \
		|| (printf "+ %-35.35s %-20.20s %-20.20s\n" $N $C $U)

%.status: submodule_status;
	@$(eval D = $(shell echo -e \
		'$(subst $(space),\n,$(SUBMODULES))'|grep -e '\(^\|/\)$*$$'))

	@test -n "$D" || { echo "ERROR: Submodule $* not found" ; exit 1; }
	@$(MAKE) --no-print-directory $(D).print_status

status: $(shell git submodule --quiet foreach 'echo $${path}.status')

# vim: ts=4 ai
