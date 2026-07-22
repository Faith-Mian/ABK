#!/usr/bin/env bash
set -euo pipefail

echo "=== ABK Docker 支持模块：启用所有 missing 配置 ==="

DEFCONFIG="${DEFCONFIG:-$KERNEL_ROOT/common/arch/arm64/configs/gki_defconfig}"

if [ ! -f "$DEFCONFIG" ]; then
    echo "错误：未找到 defconfig 文件: $DEFCONFIG"
    exit 1
fi

# 添加配置的辅助函数（幂等）
add_config() {
    local cfg="$1"
    if ! grep -q "^${cfg%=*}=[ym]" "$DEFCONFIG" 2>/dev/null; then
        echo "$cfg" >> "$DEFCONFIG"
        echo "✓ 已添加 $cfg"
    else
        echo "→ $cfg 已存在，跳过"
    fi
}

echo "正在启用 Docker 所需配置..."

# === Generally Necessary ===
add_config "CONFIG_CGROUP_CPUACCT=y"
add_config "CONFIG_CGROUP_DEVICE=y"
add_config "CONFIG_CGROUP_FREEZER=y"
add_config "CONFIG_CGROUP_PIDS=y"
add_config "CONFIG_CPUSETS=y"
add_config "CONFIG_CGROUP_MEMCG=y"
add_config "CONFIG_MEMCG=y"
add_config "CONFIG_MEMCG_SWAP=y"
add_config "CONFIG_CGROUP_BPF=y"

# Namespaces
add_config "CONFIG_USER_NS=y"

# Network
add_config "CONFIG_BRIDGE_NETFILTER=y"
add_config "CONFIG_NETFILTER_XT_MATCH_IPVS=y"
add_config "CONFIG_IP_VS=y"
add_config "CONFIG_IP_VS_NFCT=y"
add_config "CONFIG_IP_VS_PROTO_TCP=y"
add_config "CONFIG_IP_VS_PROTO_UDP=y"
add_config "CONFIG_IP_VS_RR=y"
add_config "CONFIG_VXLAN=y"
add_config "CONFIG_BRIDGE_VLAN_FILTERING=y"

# Storage / Overlay
add_config "CONFIG_OVERLAY_FS=y"
add_config "CONFIG_BTRFS_FS=y"
add_config "CONFIG_BTRFS_FS_POSIX_ACL=y"
add_config "CONFIG_DM_THIN_PROVISIONING=y"
add_config "CONFIG_OVERLAY_FS=y"  # 重复确保

# Optional / 其他常见缺失
add_config "CONFIG_BLK_DEV_THROTTLING=y"
add_config "CONFIG_CGROUP_PERF=y"
add_config "CONFIG_CGROUP_HUGETLB=y"
add_config "CONFIG_NET_CLS_CGROUP=y"
add_config "CONFIG_CFS_BANDWIDTH=y"
add_config "CONFIG_FAIR_GROUP_SCHED=y"
add_config "CONFIG_RT_GROUP_SCHED=y"
add_config "CONFIG_IP_NF_TARGET_REDIRECT=y"
add_config "CONFIG_IP_VS_NFCT=y"
add_config "CONFIG_IP_VS_PROTO_TCP=y"
add_config "CONFIG_IP_VS_PROTO_UDP=y"
add_config "CONFIG_IP_VS_RR=y"
add_config "CONFIG_SECURITY_APPARMOR=y"
add_config "CONFIG_EXT4_FS_POSIX_ACL=y"
add_config "CONFIG_ZFS_FS=y"   # 如果需要 ZFS（可选）
# add_config "CONFIG_USB_CONFIGFS_ECM=y"  # 你之前提到的

# 依赖项（Gadget / 其他）
add_config "CONFIG_USB_GADGET=y"
add_config "CONFIG_USB_CONFIGFS=y"

echo "=== 所有 Docker missing 配置处理完成 ==="
echo "最终 defconfig 预览（最后 20 行）："
tail -n 20 "$DEFCONFIG"
