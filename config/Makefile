include .config

ifeq ($(ENABLE_SSL), y)
	NGX_TARGETS += openssl
endif

ifeq ($(ENABLE_LUAJIT), y)
	NGX_TARGETS += luajit
	NGX_TARGETS += lua-modules
endif

ifeq ($(ENABLE_ZLIB_NG), y)
	NGX_CFG += --with-zlib=$(BUILDDIR/zlib-ng)
	NGX_CFG += --with-zlib-opt='-msse4.2 -mpclmul -O3 -static'
	NGX_TARGETS += zlib-ng.src
endif

ifeq ($(ENABLE_TCP_FASTOPEN), y)
	NGX_CC_OPTS += -DTCP_FASTOPEN=23
endif

ifeq ($(ENABLE_DEBUG), y)
	NGX_CFG += --with-debug
	# TODO: what else can we debug?
endif

ifeq ($(ENABLE_IPV6), y)
	NGX_CFG += --with-ipv6
endif

ifeq ($(NGX_WITH_SELECT), y)
	NGX_CFG += --with-select_module
else
	NGX_CFG += --without-select_module
endif

ifeq ($(NGX_WITH_POLL), y)
	NGX_CFG += --with-poll_module
else
	NGX_CFG += --without-poll_module
endif

ifeq ($(NGX_WITH_THREADS), y)
	NGX_CFG += --with-threads
endif

ifeq ($(NGX_WITH_FILE_AIO), y)
	NGX_CFG += --with-file-aio
endif

ifeq ($(NGX_PREFIX), '')
	NGX_PREFIX=/opt/nginx
endif

NGX_CFG += --prefix=$(NGX_PREFIX)

ifeq ($(NGX_WITH_PCRE), y)
	NGX_CFG += --with-pcre=$(BUILDDIR)/pcre
	NGX_TARGETS += pcre.src
else
	NGX_CFG += --without-pcre
endif

ifeq ($(NGX_WITH_PCRE_JIT), y)
	NGX_CFG += --with-pcre-jit
endif

ifeq ($(NGX_WITH_HTTP_SSL_MODULE), y)
	NGX_CFG += --with-http_ssl_module
endif

ifneq ($(NGX_WITH_HTTP), y)
	NGX_CFG += --without-http
endif

ifneq ($(NGX_WITH_HTTP_CACHE), y)
	NGX_CFG += --without-http-cache
endif

ifeq ($(NGX_WITH_HTTP_V2_MODULE), y)
	NGX_CFG += --with-http_v2_module
endif

ifeq ($(NGX_WITH_HTTP_REALIP_MODULE), y)
	NGX_CFG += --with-http_realip_module
endif

ifeq ($(NGX_WITH_HTTP_ADDITION_MODULE), y)
	NGX_CFG += --with-http_addition_module
endif

ifeq ($(NGX_WITH_HTTP_XSLT_MODULE), y)
	NGX_CFG += --with-http_xslt_module
endif

ifeq ($(NGX_WITH_HTTP_IMAGE_FILTER_MODULE), y)
	NGX_CFG += --with-http_image_filter_module
endif

ifeq ($(NGX_WITH_HTTP_GEOIP_MODULE), y)
	NGX_CFG += --with-http_geoip_module
endif

ifeq ($(NGX_WITH_HTTP_SUB_MODULE), y)
	NGX_CFG += --with-http_sub_module
endif

ifeq ($(NGX_WITH_HTTP_DAV_MODULE), y)
	NGX_CFG += --with-http_dav_module
endif

ifeq ($(NGX_WITH_HTTP_FLV_MODULE), y)
	NGX_CFG += --with-http_flv_module
endif

ifeq ($(NGX_WITH_HTTP_MP4_MODULE), y)
	NGX_CFG += --with-http_mp4_module
endif

ifeq ($(NGX_WITH_HTTP_AUTH_REQUEST_MODULE), y)
	NGX_CFG += --with-http_auth_request_module
endif

ifneq ($(NGX_WITH_HTTP_GZIP_MODULE), y)
	NGX_CFG += --without-http_gzip_module
endif

ifeq ($(NGX_WITH_HTTP_GUNZIP_MODULE), y)
	NGX_CFG += --with-http_gunzip_module
endif

ifeq ($(NGX_WITH_HTTP_GZIP_STATIC_MODULE), y)
	NGX_CFG += --with-http_gzip_static_module
endif

ifeq ($(NGX_WITH_HTTP_RANDOM_INDEX_MODULE), y)
	NGX_CFG += --with-http_random_index_module
endif

ifeq ($(NGX_WITH_HTTP_SECURE_LINK_MODULE), y)
	NGX_CFG += --with-http_secure_link_module
endif

ifeq ($(NGX_WITH_HTTP_DEGRADATION_MODULE), y)
	NGX_CFG += --with-http_degradation_module
endif

ifeq ($(NGX_WITH_HTTP_SLICE_MODULE), y)
	NGX_CFG += --with-http_slice_module
endif

ifeq ($(NGX_WITH_HTTP_STUB_STATUS_MODULE), y)
	NGX_CFG += --with-http_stub_status_module
endif

ifneq ($(NGX_WITH_HTTP_CHARSET_MODULE), y)
	NGX_CFG += --without-http_charset_module
endif

ifneq ($(NGX_WITH_HTTP_SSI_MODULE), y)
	NGX_CFG += --without-http_ssi_module
endif

ifneq ($(NGX_WITH_HTTP_USERID_MODULE), y)
	NGX_CFG += --without-http_userid_module
endif

ifneq ($(NGX_WITH_HTTP_ACCESS_MODULE), y)
	NGX_CFG += --without-http_access_module
endif

ifneq ($(NGX_WITH_HTTP_AUTH_BASIC_MODULE), y)
	NGX_CFG += --without-http_auth_basic_module
endif

ifneq ($(NGX_WITH_HTTP_AUTOINDEX_MODULE), y)
	NGX_CFG += --without-http_autoindex_module
endif

ifneq ($(NGX_WITH_HTTP_GEO_MODULE), y)
	NGX_CFG += --without-http_geo_module
endif

ifneq ($(NGX_WITH_HTTP_MAP_MODULE), y)
	NGX_CFG += --without-http_map_module
endif

ifneq ($(NGX_WITH_HTTP_SPLIT_CLIENTS_MODULE), y)
	NGX_CFG += --without-http_split_clients_module
endif

ifneq ($(NGX_WITH_HTTP_REFERER_MODULE), y)
	NGX_CFG += --without-http_referer_module
endif

ifneq ($(NGX_WITH_HTTP_REWRITE_MODULE), y)
	NGX_CFG += --without-http_rewrite_module
endif

ifneq ($(NGX_WITH_HTTP_PROXY_MODULE), y)
	NGX_CFG += --without-http_proxy_module
endif

ifneq ($(NGX_WITH_HTTP_FASTCGI_MODULE), y)
	NGX_CFG += --without-http_fastcgi_module
endif

ifneq ($(NGX_WITH_HTTP_UWSGI_MODULE), y)
	NGX_CFG += --without-http_uwsgi_module
endif

ifneq ($(NGX_WITH_HTTP_SCGI_MODULE), y)
	NGX_CFG += --without-http_scgi_module
endif

ifneq ($(NGX_WITH_HTTP_MEMCACHED_MODULE), y)
	NGX_CFG += --without-http_memcached_module
endif

ifneq ($(NGX_WITH_HTTP_LIMIT_CONN_MODULE), y)
	NGX_CFG += --without-http_limit_conn_module
endif

ifneq ($(NGX_WITH_HTTP_LIMIT_REQ_MODULE), y)
	NGX_CFG += --without-http_limit_req_module
endif

ifneq ($(NGX_WITH_HTTP_EMPTY_GIF_MODULE), y)
	NGX_CFG += --without-http_empty_gif_module
endif

ifneq ($(NGX_WITH_HTTP_BROWSER_MODULE), y)
	NGX_CFG += --without-http_browser_module
endif

ifneq ($(NGX_WITH_HTTP_UPSTREAM_HASH_MODULE), y)
	NGX_CFG += --without-http_upstream_hash_module
endif

ifneq ($(NGX_WITH_HTTP_UPSTREAM_IP_HASH_MODULE), y)
	NGX_CFG += --without-http_upstream_ip_hash_module
endif

ifneq ($(NGX_WITH_HTTP_UPSTREAM_LEAST_CONN_MODULE), y)
	NGX_CFG += --without-http_upstream_least_conn_module
endif

ifneq ($(iNGX_WITH_HTTP_UPSTREAM_KEEPALIVE_MODULE), y)
	NGX_CFG += --without-http_upstream_keepalive_module
endif

ifneq ($(NGX_WITH_HTTP_UPSTREAM_ZONE_MODULE), y)
	NGX_CFG += --without-http_upstream_zone_module
endif

ifeq ($(NGX_WITH_STREAM), y)
	NGX_CFG += --with-stream
endif

ifeq ($(NGX_WITH_STREAM_SSL_MODULE), y)
	NGX_CFG += --with-stream_ssl_module
endif

ifeq ($(NGX_WITH_STREAM_REALIP_MODULE), y)
	NGX_CFG += --with-stream_realip_module
endif

ifeq ($(NGX_WITH_STREAM_GEOIP_MODULE), y)
	NGX_CFG += --with-stream_geoip_module
endif

ifeq ($(NGX_WITH_STREAM_SSL_PREREAD_MODULE), y)
	NGX_CFG += --with-stream_ssl_preread_module
endif

ifneq ($(NGX_WITH_STREAM_LIMIT_CONN_MODULE), y)
	NGX_CFG += --without-stream_limit_conn_module
endif

ifneq ($(NGX_WITH_STREAM_ACCESS_MODULE), y)
	NGX_CFG += --without-stream_access_module
endif
ifneq ($(NGX_WITH_STREAM_GEO_MODULE), y)
	NGX_CFG += --without-stream_geo_module
endif
ifneq ($(NGX_WITH_STREAM_MAP_MODULE), y)
	NGX_CFG += --without-stream_map_module
endif
ifneq ($(NGX_WITH_STREAM_SPLIT_CLIENTS_MODULE), y)
	NGX_CFG += --without-stream_split_clients_module
endif
ifneq ($(NGX_WITH_STREAM_RETURN_MODULE), y)
	NGX_CFG += --without-stream_return_module
endif
ifneq ($(NGX_WITH_STREAM_UPSTREAM_HASH_MODULE), y)
	NGX_CFG += --without-stream_upstream_hash_module
endif
ifneq ($(NGX_WITH_STREAM_UPSTREAM_LEAST_CONN_MODULE), y)
	NGX_CFG += --without-stream_upstream_least_conn_module
endif
ifneq ($(NGX_WITH_STREAM_UPSTREAM_ZONE_MODULE), y)
	NGX_CFG += --without-stream_upstream_zone_module
endif

# external modules

ifeq ($(NGX_MODULE_LUA_NGINX_MODULE), y)
	NGX_CFG += --add-module=$(DEPSDIR)/lua-nginx-module
endif

ifeq ($(NGX_MODULE_STREAM_LUA_NGINX_MODULE), y)
	NGX_CFG += --add-module=$(DEPSDIR)/stream-lua-nginx-module
endif

ifeq ($(NGX_MODULE_LUA_UPSTREAM_NGINX_MODULE), y)
	NGX_CFG += --add-module=$(DEPSDIR)/lua-upstream-nginx-module
endif

ifeq ($(NGX_MODULE_HEADERS_MORE_NGINX_MODULE), y)
	NGX_CFG += --add-module=$(DEPSDIR)/headers-more-nginx-module
endif

ifeq ($(NGX_MODULE_ENCRYPTED_SESSION_NGINX_MODULE), y)
	NGX_CFG += --add-module=$(DEPSDIR)/encrypted-session-nginx-module
endif

ifeq ($(NGX_MODULE_ICONV_NGINX_MODULE), y)
	NGX_CFG += --add-module=$(DEPSDIR)/iconv-nginx-module
endif

ifeq ($(NGX_MODULE_NGINX_RTMP_MODULE), y)
	NGX_CFG += --add-module=$(DEPSDIR)/nginx-rtmp-module
endif

ifeq ($(NGX_MODULE_NGX_DEVEL_KIT), y)
	NGX_CFG += --add-module=$(DEPSDIR)/ngx_devel_kit
endif

ifeq ($(NGX_MODULE_SET_MISC_NGINX_MODULE), y)
	NGX_CFG += --add-module=$(DEPSDIR)/set-misc-nginx-module
endif

ifeq ($(NGX_MODULE_NGX_COOLKIT), y)
	NGX_CFG += --add-module=$(DEPSDIR)/ngx_coolkit
endif

ifeq ($(NGX_MODULE_ECHO_NGINX_MODULE), y)
	NGX_CFG += --add-module=$(DEPSDIR)/echo-nginx-module
endif

# lua modules

ifeq ($(LUA_MODULE_CJSON), y)
	LUAJIT_CFLAGS += -DLUAJIT_CJSON
	LUAJIT_TARGETS += lua-cjson
endif

ifeq ($(LUA_MODULE_CMSGPACK), y)
	LUAJIT_CFLAGS += -DLUAJIT_CMSGPACK
	LUAJIT_TARGETS += lua-cmsgpack
endif

ifeq ($(LUA_MODULE_PGMOON), y)
	LUA_MODULES += pgmoon=pgmoon.lua
	LUA_MODULES += pgmoon=pgmoon/socket.lua
	LUA_MODULES += pgmoon=pgmoon/init.lua
	LUA_MODULES += pgmoon=pgmoon/json.lua
	LUA_MODULES += pgmoon=pgmoon/arrays.lua
	LUA_MODULES += pgmoon=pgmoon/crypto.lua
	LUA_MODULES += pgmoon=pgmoon/hstore.lua
endif

ifeq ($(LUA_MODULE_RESTY_CORE), y)
	LUA_MODS += lua-resty-core/lib
endif

ifeq ($(LUA_MODULE_RESTY_DNS), y)
	LUA_MODS += lua-resty-dns/lib
endif

ifeq ($(LUA_MODULE_RESTY_LOCK), y)
	LUA_MODS += lua-resty-lock/lib
endif

ifeq ($(LUA_MODULE_RESTY_LRUCACHE), y)
	LUA_MODS += lua-resty-lrucache/lib
endif

ifeq ($(LUA_MODULE_RESTY_MEMCACHED), y)
	LUA_MODS += lua-resty-memcached/lib
endif

ifeq ($(LUA_MODULE_RESTY_MYSQL), y)
	LUA_MODS += lua-resty-mysql/lib
endif

ifeq ($(LUA_MODULE_RESTY_REDIS), y)
	LUA_MODS += lua-resty-redis/lib
endif

ifeq ($(LUA_MODULE_RESTY_STRING), y)
	LUA_MODS += lua-resty-string/lib
endif

ifeq ($(LUA_MODULE_RESTY_UPLOAD), y)
	LUA_MODS += lua-resty-upload/lib
endif

ifeq ($(LUA_MODULE_RESTY_UPSTREAM_HEALTHCHECK), y)
	LUA_MODS += lua-resty-upstream-healthcheck/lib
endif

ifeq ($(LUA_MODULE_RESTY_WEBSOCKET), y)
	LUA_MODS += lua-resty-websocket/lib
endif
