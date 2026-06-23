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

echo "✅ [DIY-P2] 预处理完成，即将执行 make defconfig"
