#!/bin/bash
# ============================================================
# diy-part1.sh - 在 feeds update 之前：加插件源 + 补 DTS
# ============================================================

echo "🔧 [DIY-P1] 开始执行..."

# ---- 1. 第三方插件源 ----
git clone --depth=1 https://github.com/fw876/helloworld.git package/helloworld

# ---- 2. 补 DTS：PCIe1(20000000) + QCN9024 reserved-memory ----
DTS="target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq6010-re-cs-02.dts"
DTSI="target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq6018-512m.dtsi"

if [ -f "$DTS" ]; then
    echo "✅ [DIY-P1] 找到 DTS: $DTS"

    # 2a. pcie1@20000000 开 okay（QCN9024 走这路，of_node 已确认）
    if grep -q '&pcie1' "$DTS"; then
        sed -i '/&pcie1/,/{/{:a;N;/\}/!ba;s/status = "disabled";/status = "okay";/}' "$DTS"
        echo "✅ [DIY-P1] pcie1 已设为 okay（QCN9024 走 20000000）"
    else
        echo "⚠️ [DIY-P1] DTS 中没找到 &pcie1，刷完看 dmesg | grep ath11k_pci"
    fi

    # 2b. QCN9024 reserved-memory @0x51000000（避 512m.dtsi 里 0x50000000 的占用）
    # 优先追到 DTS 本体，其次追 dtsi
    if ! grep -q "qcn9024_pcie_mem" "$DTS"; then
        if grep -q "&reserved_memory" "$DTS"; then
            sed -i '/&reserved_memory/a\\tqcn9024_pcie_mem: qcn9024_pcie_mem@51000000 {\n\t\treg = <0x0 0x51000000 0x0 0x100000>;\n\t\tno-map;\n\t};' "$DTS"
            echo "✅ [DIY-P1] DTS 内追加 QCN9024 reserved-memory @0x51000000"
        elif grep -q "&reserved_memory" "$DTSI"; then
            sed -i '/&reserved_memory/a\\tqcn9024_pcie_mem: qcn9024_pcie_mem@51000000 {\n\t\treg = <0x0 0x51000000 0x0 0x100000>;\n\t\tno-map;\n\t};' "$DTSI"
            echo "✅ [DIY-P1] ipq6018-512m.dtsi 内追加 QCN9024 reserved-memory @0x51000000"
        else
            echo "⚠️ [DIY-P1] 没找到 &reserved_memory 节点，reserved-memory 未补，刷完看 dmesg"
        fi
    else
        echo "✅ [DIY-P1] QCN9024 reserved-memory 已存在，跳过"
    fi
else
    echo "❌ [DIY-P1] DTS 不存在: $DTS，检查 coolsnowwolf/lede 分支"
fi

# ---- 3. feeds ----
./scripts/feeds update -a
./scripts/feeds install -a

echo "✅ [DIY-P1] 完成"
