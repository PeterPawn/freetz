$(call PKG_INIT_BIN,$(if $(FREETZ_OPENSSL_VERSION_0),0.9.8zh,$(if $(FREETZ_OPENSSL_VERSION_1_LTS),1.0.2j,1.0.1u)))
$(PKG)_LIB_VERSION:=$(call qstrip,$(FREETZ_OPENSSL_SHLIB_VERSION))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_SHA256_0.9.8zh := f1d9f3ed1b85a82ecf80d0e2d389e1fda3fca9a4dba0bf07adbf231e1a5e2fd6
$(PKG)_SOURCE_SHA256_1.0.1u  := 4312b4ca1215b6f2c97007503d80db80d5157f76f8f7d3febbe6b4c56ff26739
$(PKG)_SOURCE_SHA256_1.0.2j  := e7aff292be21c259c6af26469c7a9b3ba26e9abaaffd325e3dccc9785256c431
$(PKG)_SOURCE_SHA256         := $($(PKG)_SOURCE_SHA256_$($(PKG)_VERSION))
$(PKG)_SITE:=http://www.openssl.org/source
$(PKG)_CONDITIONAL_PATCHES+=$($(PKG)_VERSION)

# Makefile is regenerated by configure
$(PKG)_PATCH_POST_CMDS += $(RM) Makefile  Makefile.bak;
$(PKG)_PATCH_POST_CMDS += ln -s Configure configure;

$(PKG)_BINARY_BUILD_DIR := $($(PKG)_DIR)/apps/openssl
$(PKG)_BINARY_TARGET_DIR := $($(PKG)_DEST_DIR)/usr/bin/openssl

$(PKG)_LIBNAMES_SHORT := libssl libcrypto
$(PKG)_LIBNAMES_LONG := $($(PKG)_LIBNAMES_SHORT:%=%.so.$($(PKG)_LIB_VERSION))

$(PKG)_LIBS_BUILD_DIR :=$($(PKG)_LIBNAMES_LONG:%=$($(PKG)_DIR)/%)
$(PKG)_LIBS_STAGING_DIR := $($(PKG)_LIBNAMES_LONG:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)
$(PKG)_LIBS_TARGET_DIR := $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_TARGET_LIBDIR)/%)

$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libcrypto_WITH_EC
$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libcrypto_WITH_RC4
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_VERSION_0
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_VERSION_1
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_VERSION_1_LTS
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SMALL_FOOTPRINT
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_CONFIG_DIR
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENSSL_TRACE

$(PKG)_NO_CIPHERS := no-idea no-md2 no-mdc2 no-rc2 no-rc5 no-sha0 no-smime no-rmd160 no-aes192 no-ripemd no-camellia no-ans1 no-krb5 no-ssl2 no-ssl3
$(PKG)_NO_CIPHERS += $(if $(FREETZ_LIB_libcrypto_WITH_RC4),,no-rc4)

$(PKG)_OPTIONS    := shared no-err no-fips no-hw no-engines no-sse2 no-capieng no-seed
$(PKG)_OPTIONS    += $(if $(FREETZ_LIB_libcrypto_WITH_EC),,no-ec)
$(PKG)_OPTIONS    += $(if $(FREETZ_OPENSSL_VERSION_0),no-perlasm)
$(PKG)_OPTIONS    += $(if $(or $(FREETZ_OPENSSL_VERSION_0),$(FREETZ_OPENSSL_VERSION_1)),no-cms)
$(PKG)_OPTIONS    += $(if $(or $(FREETZ_OPENSSL_VERSION_1),$(FREETZ_OPENSSL_VERSION_1_LTS)),no-ec_nistp_64_gcc_128 no-sctp no-srp no-store no-whirlpool)
$(PKG)_OPTIONS    += $(if $(FREETZ_PACKAGE_OPENSSL_TRACE),enable-ssl-trace)

$(PKG)_CONFIGURE_DEFOPTS := n
$(PKG)_CONFIGURE_OPTIONS += linux-freetz-$(if $(FREETZ_TARGET_ARCH_BE),be,le)$(if $(FREETZ_OPENSSL_VERSION_0),,-asm)
$(PKG)_CONFIGURE_OPTIONS += --prefix=/usr
$(PKG)_CONFIGURE_OPTIONS += --openssldir=$(FREETZ_OPENSSL_CONFIG_DIR)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_OPENSSL_SMALL_FOOTPRINT),-DOPENSSL_SMALL_FOOTPRINT)
$(PKG)_CONFIGURE_OPTIONS += $(OPENSSL_NO_CIPHERS)
$(PKG)_CONFIGURE_OPTIONS += $(OPENSSL_OPTIONS)

$(PKG)_MAKE_FLAGS += -C $(OPENSSL_DIR)
$(PKG)_MAKE_FLAGS += MAKEDEPPROG="$(TARGET_CC)"
$(PKG)_MAKE_FLAGS += CC="$(TARGET_CC)"
$(PKG)_MAKE_FLAGS += AR="$(TARGET_AR) r"
$(PKG)_MAKE_FLAGS += RANLIB="$(TARGET_RANLIB)"
$(PKG)_MAKE_FLAGS += NM="$(TARGET_NM)"
$(PKG)_MAKE_FLAGS += FREETZ_MOD_OPTIMIZATION_FLAGS="$(TARGET_CFLAGS) -ffunction-sections -fdata-sections"
$(PKG)_MAKE_FLAGS += SHARED_LDFLAGS=""
$(PKG)_MAKE_FLAGS += INSTALL_PREFIX="$(TARGET_TOOLCHAIN_STAGING_DIR)"
$(PKG)_MAKE_FLAGS += CROSS_COMPILE=1

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY_BUILD_DIR) $($(PKG)_LIBS_BUILD_DIR): $($(PKG)_DIR)/.configured
#	OpenSSL's "make depend" looks for installed headers before its own,
#	so remove installed stuff from the staging dir first.
#	Remove installed libs also from freetz' packages dir to ensure
#	that it doesn't contain files from previous builds (0.9.8 to/from 1.0.x switch).
	$(MAKE) openssl-clean-staging openssl-uninstall
	for target in depend all; do \
		$(SUBMAKE1) $(OPENSSL_MAKE_FLAGS) $$target; \
	done

$($(PKG)_LIBS_STAGING_DIR): $($(PKG)_LIBS_BUILD_DIR)
	$(SUBMAKE) $(OPENSSL_MAKE_FLAGS) install
	$(call PKG_FIX_LIBTOOL_LA,prefix) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/{libcrypto,libssl,openssl}.pc

$($(PKG)_BINARY_TARGET_DIR): $($(PKG)_BINARY_BUILD_DIR)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_TARGET_LIBDIR)/%: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_LIBS_STAGING_DIR)

$(pkg)-precompiled: $($(PKG)_BINARY_TARGET_DIR) $($(PKG)_LIBS_TARGET_DIR)

$(pkg)-clean: $(pkg)-clean-staging
	-$(SUBMAKE) $(OPENSSL_MAKE_FLAGS) clean

$(pkg)-clean-staging:
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/openssl* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/{libssl,libcrypto}* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/{libssl,libcrypto,openssl}* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/openssl

$(pkg)-uninstall:
	$(RM) $(OPENSSL_BINARY_TARGET_DIR) $(OPENSSL_TARGET_LIBDIR)/{libssl,libcrypto}*.so*

$(call PKG_ADD_LIB,libcrypto)
$(PKG_FINISH)
