#!/bin/bash
# ============================================================
# diy-part1.sh - 在 feeds update 之前：加插件源 + 补 DTS
# ============================================================

echo "🔧 [DIY-P1] 开始执行..."

# ---- 1. 第三方插件源 ----
git clone --depth=1 https://github.com/fw876/helloworld.git package/helloworld

# ---- 2. 补 DTS：PCIe + QCN9024 reserved-memory ----
# 按 Lean's LEDE ipq60xx 常见命名，你配合②确认后改这行
DTS="target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq6018_jdcloud_re-cs-02.dts"

if [ -f "$DTS" ]; then
    echo "✅ [DIY-P1] 找到 DTS: $DTS"

    # 确保 pcie0 开启
    sed -i '/pcie0/,/status/{s/status = "disabled";/status = "okay";/}' "$DTS"

    # 补 QCN9024 reserved-memory（没有才追加）
    if ! grep -q "qcn9024_pcie_mem" "$DTS"; then
        # 先找到 &reserved_memory 节点，在它前面插
        sed -i '/&reserved_memory/a\\n\tqcn9024_pcie_mem@50000000 {\n\t\treg = <0x0 0x50000000 0x0 0x100000>;\n\t\tno-map;\n\t};' "$DTS"
        echo "✅ [DIY-P1] 已追加 QCN9024 reserved-memory"
    else
        echo "✅ [DIY-P1] QCN9024 reserved-memory 已存在，跳过"
    fi
else
    echo "⚠️ [DIY-P1] 未找到 DTS: $DTS，跳过 DTS 修补，请检查配合②"
fi

# ---- 3. feeds ----
./scripts/feeds update -a
./scripts/feeds install -a

echo "✅ [DIY-P1] 完成"
