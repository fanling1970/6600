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

# 移除可能自动包含的passwall配置
sed -i '/CONFIG_PACKAGE_luci-app-passwall/d' .config
sed -i '/CONFIG_PACKAGE_luci-i18n-passwall/d' .config

# 确保SSL库选择正确
echo "CONFIG_LIBUSTREAM_MBEDTLS=y" >> .config
echo "# CONFIG_LIBUSTREAM_OPENSSL is not set" >> .config

# 修复正则表达式：启用被注释的CONFIG_PACKAGE_配置
sed -i 's/^# $CONFIG_PACKAGE_.*$/\1/' .config

make defconfig
