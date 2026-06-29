# 添加 SSR+ / PassWall 等代理插件源
git clone --depth=1 https://github.com/fw876/helloworld.git package/helloworld

# 如果还需要 luci-app-ssr-plus 界面
git clone --depth=1 https://github.com/small-5/luci-app-adblock-plus package/luci-app-adblock-plus 2>/dev/null || true

echo "✅ [DIY-P1] 已添加 SSR 插件源"
