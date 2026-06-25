#!/bin/bash
# ============================================================
# diy-part2.sh - make defconfig 之前：收尾
# ============================================================

echo "🔧 [DIY-P2] 开始..."

# 1. wireless 换行符清理
if [ -f "files/etc/config/wireless" ]; then
    sed -i 's/\r$//' files/etc/config/wireless
    echo "✅ [DIY-P2] wireless 已清理换行符"
fi

# 2. 删掉 99-wifi hotplug 的 chmod 引用（文件我们已经删了，这步跳过也行，保险留个判断）
if [ -f "files/etc/hotplug.d/net/99-wifi" ]; then
    chmod +x files/etc/hotplug.d/net/99-wifi
    echo "⚠️ [DIY-P2] 99-wifi 仍存在，已赋权（建议删掉此文件）"
else
    echo "✅ [DIY-P2] 99-wifi 已移除，clean"
fi

# 3. 清构建缓存
rm -rf tmp/.config* tmp/info/.files-* build_dir/target-*/linux-ipq60xx/tmp/
echo "✅ [DIY-P2] 缓存已清"

# 4. LAN IP
sed -i 's/192\.168\.[0-9]\{1,3\}\.[0-9]\{1,3\}/192.168.100.1/g' package/base-files/files/bin/config_generate
echo "✅ [DIY-P2] 默认IP 192.168.100.1"

# 5. dnsmasq-delay（你原来那份可留，这里不再重复写，files/ 里已有就行）
if [ -f "files/etc/init.d/dnsmasq-delay" ]; then
    chmod +x files/etc/init.d/dnsmasq-delay
    echo "✅ [DIY-P2] dnsmasq-delay 已确保"
fi

echo "✅ [DIY-P2] 完成，准备 defconfig"
