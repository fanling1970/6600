#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# 应用自定义配置
cp $GITHUB_WORKSPACE/.config .config

# 彻底移除passwall相关配置
sed -i '/CONFIG_PACKAGE_luci-app-passwall/d' .config
sed -i '/CONFIG_PACKAGE_luci-i18n-passwall/d' .config
sed -i '/CONFIG_PACKAGE_passwall/d' .config

# 从feeds中移除passwall包
./scripts/feeds uninstall luci-app-passwall
./scripts/feeds uninstall luci-i18n-passwall-zh-cn

# 确保SSL库选择正确
echo "CONFIG_LIBUSTREAM_MBEDTLS=y" >> .config
echo "# CONFIG_LIBUSTREAM_OPENSSL is not set" >> .config

# 确保SSR配置不被覆盖
echo "CONFIG_PACKAGE_shadowsocksr-libev-ssr-local=y" >> .config
echo "CONFIG_PACKAGE_shadowsocksr-libev-ssr-redir=y" >> .config
echo "CONFIG_PACKAGE_shadowsocksr-libev-ssr-server=y" >> .config
echo "CONFIG_PACKAGE_luci-app-ssr-plus=y" >> .config
echo "CONFIG_PACKAGE_luci-i18n-ssr-plus-zh-cn=y" >> .config
echo "CONFIG_PACKAGE_shadowsocksr-libev-alt=y" >> .config
echo "CONFIG_PACKAGE_simple-obfs=y" >> .config
echo "CONFIG_PACKAGE_v2ray-plugin=y" >> .config

# 确保无线WiFi配置
echo "CONFIG_PACKAGE_kmod-ath10k=y" >> .config
echo "CONFIG_PACKAGE_kmod-ath10k-ct=y" >> .config
echo "CONFIG_PACKAGE_ath10k-firmware-qca4019=y" >> .config
echo "CONFIG_PACKAGE_iw=y" >> .config
echo "CONFIG_PACKAGE_iwinfo=y" >> .config
echo "CONFIG_PACKAGE_wpad-openssl=y" >> .config
echo "CONFIG_PACKAGE_luci-app-wireless=y" >> .config
echo "CONFIG_PACKAGE_luci-i18n-wireless-zh-cn=y" >> .config

# 确保TurboACC配置
echo "CONFIG_PACKAGE_luci-app-turboacc=y" >> .config
echo "CONFIG_PACKAGE_luci-i18n-turboacc-zh-cn=y" >> .config

# 启用所有被注释的CONFIG_PACKAGE_配置（修复的正则表达式）
sed -i 's/^# $CONFIG_PACKAGE_.*$/\1/' .config

make defconfig
