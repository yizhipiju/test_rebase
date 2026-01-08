#!/usr/bin/env bash
set -e

FEATURE_BRANCH=$1
MASTER_BRANCH=master
DEV_BRANCH=main

if [ -z "$FEATURE_BRANCH" ]; then
  echo "❌ 请指定特性分支名"
  echo "👉 用法: ./feature-release-to-master.sh feat-x"
  exit 1
fi

echo "🚀 发布特性 [$FEATURE_BRANCH] → [$MASTER_BRANCH]"
echo "🧼 将使用 rebase --onto 保留仅当前特性提交"

git fetch origin

# 1️⃣ 切到特性分支
git checkout $FEATURE_BRANCH

# 2️⃣ 强制剥离 dev 基线，仅保留当前特性
echo "🔪 剥离 dev 基线，回归 master"
git rebase --onto origin/$MASTER_BRANCH origin/$DEV_BRANCH

# 3️⃣ 切到 master 并保持最新
git checkout $MASTER_BRANCH
git pull origin $MASTER_BRANCH

# 4️⃣ 合并特性分支
git merge $FEATURE_BRANCH

echo "🎉 发布完成：$FEATURE_BRANCH 已合并到 $MASTER_BRANCH"
