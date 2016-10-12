all: luajit lua-cjson lua-cmsgpack nginx

DEPSDIR=$(CURDIR)/dependencies
BUILDDIR=$(CURDIR)/build
PATCHDIR=$(CURDIR)/patches

LUADIR=$(BUILDDIR)/luajit/src

export LUAJIT_LIB=$(LUADIR)
export LUAJIT_INC=$(LUADIR)
#export LUA_INCLUDE_DIR=$(LUAJIT_INC)

LUAJIT_CFLAGS += -DLUAJIT_CJSON
LUAJIT_CFLAGS += -DLUAJIT_CMSGPACK
#	--with-http_ssl_module \

NGINX_LD_OPTS += -L$(LUADIR) -lluajit-5.1
NGINX_LD_OPTS += -Wl,-z,relro -Wl,-E

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
	--with-sha1-asm \
	--with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=generic -DTCP_FASTOPEN=23'

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
	$(eval NGINX_CONF_OPTS += --with-ld-opt='$(NGINX_LD_OPTS)')
	echo $(NGINX_CONF_OPTS)
	@cd $(BUILDDIR)/nginx && ./auto/configure $(NGINX_CONF_OPTS)
	$(MAKE) -C $(BUILDDIR)/nginx

clean:
	rm -rf $(BUILDDIR)/*
