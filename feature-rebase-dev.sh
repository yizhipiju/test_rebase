#!/usr/bin/env bash
set -e

FEATURE_BRANCH=$1
DEV_BRANCH=main

if [ -z "$FEATURE_BRANCH" ]; then
  echo "❌ 请指定特性分支名"
  echo "👉 用法: ./feature-to-dev.sh feat-x"
  exit 1
fi

echo "🚀 将特性分支 [$FEATURE_BRANCH] 合并到 [$DEV_BRANCH]"

git fetch origin

# 切到 dev 并保持最新
git checkout $DEV_BRANCH
git pull origin $DEV_BRANCH

# 合并特性分支（不做 rebase，避免基线污染）
git merge $FEATURE_BRANCH

echo "✅ 已成功合并到 $DEV_BRANCH（用于联调/测试）"
