#!/usr/bin/env bash
set -e

FEATURE_BRANCH=$1
DEV_BRANCH=main

if [ -z "$FEATURE_BRANCH" ]; then
  echo "❌ 请指定特性分支名"
  echo "👉 用法: ./feature-to-dev.sh feat-x"
  exit 1
fi

echo "🔄 同步特性分支 [$FEATURE_BRANCH] 到 [$DEV_BRANCH] 基线"

git fetch origin

# 切到特性分支
git checkout $FEATURE_BRANCH

# 可选：rebase dev（用于本地联调 & 冲突预演）
echo "⚙️ rebase $DEV_BRANCH（仅用于联调）"
git rebase origin/$DEV_BRANCH || {
  echo "❌ rebase 冲突，请解决后继续"
  exit 1
}

# 切到 dev 并保持最新
git checkout $DEV_BRANCH
git pull origin $DEV_BRANCH

# 合并特性分支（dev 接受所有特性）
git merge $FEATURE_BRANCH

echo "✅ 已合并到 dev（联调分支）"
