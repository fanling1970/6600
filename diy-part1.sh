#!/bin/bash
# ============================================================
# diy-part1.sh - 添加第三方插件源 (在 feeds update 之前执行)
# ============================================================

echo "🔧 [DIY-P1] 开始添加第三方插件源..."

# 添加 SSR+ 插件源
git clone --depth=1 https://github.com/fw876/helloworld.git package/helloworld

# 更新并安装所有 feeds (关键！否则 .config 中的 SSR 选项无效)
./scripts/feeds update -a
./scripts/feeds install -a

echo "✅ [DIY-P1] 已添加 SSR 插件源并完成 feeds 更新安装"
