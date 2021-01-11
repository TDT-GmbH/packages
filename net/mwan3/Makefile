#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mwan3
PKG_VERSION:=2.10.6
PKG_RELEASE:=1
PKG_MAINTAINER:=Florian Eckert <fe@dev.tdt.de>, \
		Aaron Goodman <aaronjg@alumni.stanford.edu>
PKG_LICENSE:=GPL-2.0
PKG_CONFIG_DEPENDS:=CONFIG_IPV6

include $(INCLUDE_DIR)/package.mk

define Package/mwan3
   SECTION:=net
   CATEGORY:=Network
   SUBMENU:=Routing and Redirection
   DEPENDS:= \
     +ip \
     +ipset \
     +iptables \
     +iptables-mod-conntrack-extra \
     +iptables-mod-ipopt \
     +jshn
   TITLE:=Multiwan hotplug script with connection tracking support
   MAINTAINER:=Florian Eckert <fe@dev.tdt.de>
   PKGARCH:=all
endef

define Package/mwan3/description
Hotplug script which makes configuration of multiple WAN interfaces simple
and manageable. With loadbalancing/failover support for up to 250 wan
interfaces, connection tracking and an easy to manage traffic ruleset.
endef


define Package/ledtrig-mwan3-iface
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  DEPENDS:=+mwan3
  TITLE:=Mwan3 iface LED Trigger
endef

define Package/ledtrig-mwan3-iface/description
This package contains a led-handler for mwan3-iface.
endef


define Package/ledtrig-mwan3-status
  SECTION:=tdt
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  DEPENDS:=+mwan3
  TITLE:=Mwan3 status LED Trigger
endef

define Package/ledtrig-mwan3-status/description
This package contains a led-handler for mwan3-status.
endef


define Package/mwan3/conffiles
/etc/config/mwan3
/etc/mwan3.user
endef

define Package/mwan3/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ] && [ -x /etc/init.d/rpcd ]; then
	/etc/init.d/rpcd restart
fi
exit 0
endef

define Package/mwan3/postrm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ] && [ -x /etc/init.d/rpcd ]; then
	/etc/init.d/rpcd restart
fi
exit 0
endef

define Build/Compile
	$(TARGET_CC) $(CFLAGS) $(LDFLAGS) $(FPIC) \
		-shared \
		-o $(PKG_BUILD_DIR)/libwrap_mwan3_sockopt.so.1.0 \
		$(if $(CONFIG_IPV6),-DCONFIG_IPV6) \
		$(PKG_BUILD_DIR)/sockopt_wrap.c \
		-ldl
endef

define Package/mwan3/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/mwan3 \
		$(1)/etc/config/

	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DATA) ./files/etc/hotplug.d/iface/15-mwan3 \
		$(1)/etc/hotplug.d/iface/
	$(INSTALL_DATA) ./files/etc/hotplug.d/iface/16-mwan3-user \
		$(1)/etc/hotplug.d/iface/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/mwan3 \
		$(1)/etc/init.d/

	$(INSTALL_DIR) $(1)/lib/mwan3
	$(INSTALL_DATA) ./files/lib/mwan3/common.sh \
		$(1)/lib/mwan3/
	$(INSTALL_DATA) ./files/lib/mwan3/mwan3.sh \
		$(1)/lib/mwan3/

	$(INSTALL_DIR) $(1)/usr/libexec/rpcd
	$(INSTALL_BIN) ./files/usr/libexec/rpcd/mwan3 \
		$(1)/usr/libexec/rpcd/

	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/usr/sbin/mwan3 \
		$(1)/usr/sbin/
	$(INSTALL_BIN) ./files/usr/sbin/mwan3rtmon \
		$(1)/usr/sbin/
	$(INSTALL_BIN) ./files/usr/sbin/mwan3track \
		$(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_BIN) ./files/etc/mwan3.user \
		$(1)/etc/

	$(CP) $(PKG_BUILD_DIR)/libwrap_mwan3_sockopt.so.1.0 $(1)/lib/mwan3/

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DATA) ./files/etc/uci-defaults/mwan3-migrate-flush_conntrack \
		$(1)/etc/uci-defaults/
endef


define Package/ledtrig-mwan3-iface/install
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) ./files/etc/hotplug.d/iface/led-mwan3-iface \
	$(1)/etc/hotplug.d/iface/17-led-mwan3-iface

	$(INSTALL_DIR) $(1)/lib/mwan3
	$(INSTALL_DATA) ./files/lib/mwan3/led-mwan3-iface.sh \
	$(1)/lib/mwan3

	$(INSTALL_DIR) $(1)/usr/libexec/led-trigger
	$(INSTALL_BIN) ./files/usr/libexec/led-trigger/mwan3-iface \
	$(1)/usr/libexec/led-trigger
endef


define Package/ledtrig-mwan3-status/install
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) ./files/etc/hotplug.d/iface/led-mwan3-status \
	$(1)/etc/hotplug.d/iface/17-led-mwan3-status

	$(INSTALL_DIR) $(1)/lib/mwan3
	$(INSTALL_DATA) ./files/lib/mwan3/led-mwan3-status.sh \
	$(1)/lib/mwan3

	$(INSTALL_DIR) $(1)/usr/libexec/led-trigger
	$(INSTALL_BIN) ./files/usr/libexec/led-trigger/mwan3_status \
	$(1)/usr/libexec/led-trigger
endef

$(eval $(call BuildPackage,mwan3))
$(eval $(call BuildPackage,ledtrig-mwan3-iface))
$(eval $(call BuildPackage,ledtrig-mwan3-status))
