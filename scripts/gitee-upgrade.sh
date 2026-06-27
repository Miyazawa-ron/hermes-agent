#!/usr/bin/env bash
# ============================================================================
# Hermes Agent 国内升级脚本（Gitee 镜像版）
# 用法: bash <(curl -fsSL https://gitee.com/miyazawaron/hermes-agent/raw/main/scripts/gitee-upgrade.sh)
# ============================================================================
set -euo pipefail

HERMES_HOME="${HERMES_HOME:-$HOME/.hermes/hermes-agent}"
GITEE_URL="https://gitee.com/miyazawaron/hermes-agent.git"
GITHUB_URL="https://github.com/NousResearch/hermes-agent.git"

if [ ! -d "$HERMES_HOME/.git" ]; then
    echo "❌ 未找到 Hermes 安装目录: $HERMES_HOME"
    echo "   请先通过以下命令安装:"
    echo "   curl -fsSL https://gitee.com/miyazawaron/hermes-agent/raw/main/scripts/install.sh | bash"
    exit 1
fi

echo "📦 Hermes 国内升级 (Gitee 镜像)"
echo "================================="
echo "   安装目录: $HERMES_HOME"
echo ""

cd "$HERMES_HOME"

# 保存当前 remote
CURRENT_URL=$(git remote get-url origin 2>/dev/null || echo "")
echo "   当前源: $CURRENT_URL"

# 临时切换到 Gitee 镜像拉取
git remote set-url origin "$GITEE_URL"
echo "   切换到: Gitee 镜像"

# 拉取最新代码
echo ""
echo "⏳ 正在从 Gitee 拉取更新..."
if git pull --ff-only origin main 2>&1; then
    echo ""
    echo "✅ 更新成功！"
else
    echo ""
    echo "⚠️ 拉取失败，尝试完整同步..."
    git fetch origin main
    git reset --hard origin/main
fi

# 恢复原始 remote
git remote set-url origin "$CURRENT_URL"
echo "   已恢复原始源"

# 重新安装依赖
echo ""
echo "⏳ 更新依赖..."
if [ -f "./scripts/install.sh" ]; then
    bash ./scripts/install.sh --upgrade 2>&1 | tail -3
fi

echo ""
echo "🎉 Hermes 升级完成！"
echo "   当前版本: $(git log -1 --format='%h %s' 2>/dev/null || echo '?')"
