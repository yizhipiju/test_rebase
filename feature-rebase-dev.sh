#!/usr/bin/env bash
set -e

FEATURE_BRANCH=$1
DEV_BRANCH=main

if [ -z "$FEATURE_BRANCH" ]; then
  echo "❌ 请指定特性分支名"
  echo "👉 用法: ./feature-rebase-dev.sh feat-x"
  exit 1
fi

echo "🚀 将特性分支 [$FEATURE_BRANCH] rebase 到 [$DEV_BRANCH]"

git fetch origin

# 切到特性分支
git checkout $FEATURE_BRANCH

# 备份当前分支，防止 rebase 出错可恢复
BACKUP_BRANCH="${FEATURE_BRANCH}-backup-$(date +%Y%m%d%H%M%S)"
git branch $BACKUP_BRANCH
echo "📦 已备份到 $BACKUP_BRANCH"

# rebase dev，获取其他特性的代码（用于联调测试）
echo "🔄 正在 rebase $DEV_BRANCH ..."
git rebase origin/$DEV_BRANCH

echo "✅ rebase 完成，当前分支已包含 $DEV_BRANCH 的最新代码"
echo "👉 可以推送到测试环境进行联调测试"
echo "👉 如需回退: git reset --hard $BACKUP_BRANCH"
