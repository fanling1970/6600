#!/bin/bash
# ============================================================
# diy-part2.sh - 编译前预处理 (在 make defconfig 之前执行)
# ============================================================

echo "🔧 [DIY-P2] 开始编译前预处理..."

# 1. 赋予热插拔脚本可执行权限 (关键!)
if [ -f "files/etc/hotplug.d/net/99-wifi" ]; then
    chmod +x files/etc/hotplug.d/net/99-wifi
    echo "✅ [DIY-P2] 已赋予 99-wifi 可执行权限"
else
    echo "⚠️ [DIY-P2] 未找到 files/etc/hotplug.d/net/99-wifi，请检查仓库文件结构"
fi

# 2. 验证 wireless 配置文件是否存在并修复换行符
if [ -f "files/etc/config/wireless" ]; then
    sed -i 's/\r$//' files/etc/config/wireless
    echo "✅ [DIY-P2] wireless 覆盖配置已就位，并已清理Windows换行符"
else
    echo "⚠️ [DIY-P2] 未找到 files/etc/config/wireless，将依赖系统自动生成"
fi

# 3. 清理旧的构建缓存 (避免旧配置污染新编译)
echo "🧹 [DIY-P2] 清理临时构建目录..."
rm -rf tmp/.config* tmp/info/.files-* build_dir/target-*/linux-ipq60xx/tmp/

# 4. 确保 wifi-scripts 被选中 (替代已废弃的 wifi-config)
if grep -q "^CONFIG_PACKAGE_wifi-scripts" .config; then
    sed -i 's/^.*CONFIG_PACKAGE_wifi-scripts.*/CONFIG_PACKAGE_wifi-scripts=y/' .config
else
    echo "CONFIG_PACKAGE_wifi-scripts=y" >> .config
fi
echo "✅ [DIY-P2] wifi-scripts 已确保启用"

# 5. 修改默认LAN口IP为192.168.100.1
sed -i 's/192\.168\.[0-9]\{1,3\}\.[0-9]\{1,3\}/192.168.100.1/g' package/base-files/files/bin/config_generate
echo "✅ [DIY-P2] 已将默认后台IP修改为 192.168.100.1"

# 6. 创建完整的 dnsmasq 延迟启动脚本 (修复原版无实际服务启动的问题)
mkdir -p files/etc/init.d
cat > files/etc/init.d/dnsmasq-delay <<'EOF'
#!/bin/sh /etc/rc.common
START=19
USE_PROCD=1

start_service() {
    # 等待 br-lan 接口完全就绪
    local i=0
    while [ $i -lt 15 ]; do
        if [ -e /sys/class/net/br-lan/operstate ] && \
           [ "$(cat /sys/class/net/br-lan/operstate 2>/dev/null)" = "up" ]; then
            break
        fi
        sleep 1
        i=$((i+1))
    done
    
    # 接口就绪后，重启 dnsmasq 使其绑定正确地址
    /etc/init.d/dnsmasq restart
}

stop_service() {
    :
}
EOF
chmod +x files/etc/init.d/dnsmasq-delay
echo "✅ [DIY-P2] 已创建完整的 dnsmasq 延迟启动脚本"

# 7. 优化 LED 启动逻辑 (修正路径错误)
# OpenWrt 源码中 rc.local 位于 package/base-files/files/etc/rc.local
if [ -f "package/base-files/files/etc/rc.local" ]; then
    sed -i '/led.*boot\|status_led.*timer/d' package/base-files/files/etc/rc.local
    echo "✅ [DIY-P2] 已优化 LED 启动逻辑"
else
    echo "⚠️ [DIY-P2] 未找到 rc.local，跳过 LED 优化"
fi

echo "✅ [DIY-P2] 预处理完成，即将执行 make defconfig"
