all: nginx

DEPSDIR=$(CURDIR)/dependencies
BUILDDIR=$(CURDIR)/build
PATCHDIR=$(CURDIR)/patches

LUADIR=$(BUILDDIR)/luajit/src

export LUAJIT_LIB=$(LUADIR)
export LUAJIT_INC=$(LUADIR)

LUAJIT_CFLAGS += -DLUAJIT_CJSON
LUAJIT_CFLAGS += -DLUAJIT_CMSGPACK

NGINX_CC_OPTS += -O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2
NGINX_CC_OPTS += -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4
NGINX_CC_OPTS += -grecord-gcc-switches -m64 -mtune=generic
NGINX_CC_OPTS += -DTCP_FASTOPEN=23

NGINX_LD_OPTS += -L$(LUADIR) -lluajit-5.1
NGINX_LD_OPTS += -Wl,-z,relro -Wl,-E

#	--with-http_ssl_module \

NGINX_CONF_OPTS += \
	--prefix=/opt/nginx \
	--with-ipv6 \
	--with-http_slice_module \
	--with-http_stub_status_module \
	--with-http_realip_module \
	--with-http_auth_request_module \
	--add-module=$(DEPSDIR)/lua-nginx-module \
	--with-pcre=$(BUILDDIR)/pcre \
	--with-pcre-jit \
	--with-http_gzip_static_module \
	--without-http_gzip_module \
	--with-zlib=$(BUILDDIR)/zlib-ng \
	--with-zlib-opt='-msse4.2 -mpclmul -O3 -static' \
	--with-openssl=$(BUILDDIR)/openssl \
	--with-md5=$(BUILDDIR)/openssl \
	--with-sha1=$(BUILDDIR)/openssl \
	--with-md5-asm \
	--with-sha1-asm

%.src:
	@$(MAKE) $*.tar
	@$(MAKE) $*.patch

%.tar:
	mkdir -p $(BUILDDIR)
	@cd $(DEPSDIR)/$* ; \
	git archive --format tar --prefix $*/ HEAD | tar x -C $(BUILDDIR)

%.patch:
	cat $(PATCHDIR)/$*/* | patch -p1 -d $(BUILDDIR)/$*

luajit: luajit.src
	@CFLAGS="$(LUAJIT_CFLAGS)" make -C $(BUILDDIR)/luajit/src libluajit.a
	@cd $(BUILDDIR)/luajit/src ; ln -sf libluajit.a libluajit-5.1.a

lua-cjson: luajit.src lua-cjson.src
	@OBJS="lua_cjson.o strbuf.o fpconv.o"
	@LUA_INCLUDE_DIR=$(LUADIR) $(MAKE) -C $(BUILDDIR)/$@ $(OBJS)
	ar rcus $(BUILDDIR)/$@/lib$@.a $(BUILDDIR)/$@/*.o
	$(eval NGINX_LD_OPTS += -L$(BUILDDIR)/$@ -lluajit-5.1 -l$@)

lua-cmsgpack: luajit.src lua-cmsgpack.src
	@mkdir -p $(BUILDDIR)/$@
	@cd $(BUILDDIR)/$@ ; gcc -I$(LUADIR) -O2 -Wall -std=c99 lua_cmsgpack.c -c
	ar rcus $(BUILDDIR)/$@/lib$@.a $(BUILDDIR)/$@/*.o
	$(eval NGINX_LD_OPTS += -L$(BUILDDIR)/$@ -lluajit-5.1 -l$@)

nginx: luajit lua-cjson lua-cmsgpack pcre.src openssl.src zlib-ng.src nginx.src
	@cd $(BUILDDIR)/nginx && ./auto/configure $(NGINX_CONF_OPTS) \
		--with-cc-opt='$(NGINX_CC_OPTS)' \
		--with-ld-opt='$(NGINX_LD_OPTS)'

	$(MAKE) -C $(BUILDDIR)/nginx

%.lua:
	@mkdir -p $(BUILDDIR)/lua-modules
	$(LUADIR)/luajit -bg $* $(BUILDDIR)/lua-modules/$*.o

lua-modules:
	ar rcus $(BUILDDIR)/lua-modules/lib$@.a $(BUILDDIR)/$@/*.o

clean:
	rm -rf $(BUILDDIR)/*
