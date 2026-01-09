#!/usr/bin/env bash
set -e

FEATURE_BRANCH=$1
MASTER_BRANCH=master
DEV_BRANCH=main

if [ -z "$FEATURE_BRANCH" ]; then
  echo "❌ 请指定特性分支名"
  echo "👉 用法: ./feature-rebase-master.sh feat-x"
  exit 1
fi

echo "🚀 发布特性 [$FEATURE_BRANCH] → [$MASTER_BRANCH]"

git fetch origin

# 备份分支，防止出错可恢复
BACKUP_BRANCH="${FEATURE_BRANCH}-release-backup-$(date +%Y%m%d%H%M%S)"
git branch $BACKUP_BRANCH $FEATURE_BRANCH
echo "📦 已备份到 $BACKUP_BRANCH"

# 切到特性分支
git checkout $FEATURE_BRANCH

# 检查特性分支是否包含 dev 的代码
if git merge-base --is-ancestor origin/$DEV_BRANCH $FEATURE_BRANCH; then
  # 特性分支包含 dev 代码，需要用 --onto 剥离
  echo "🔍 检测到特性分支包含 $DEV_BRANCH 的代码"
  echo "🔪 使用 rebase --onto 剥离，仅保留当前特性提交"
  git rebase --onto origin/$MASTER_BRANCH origin/$DEV_BRANCH $FEATURE_BRANCH
else
  # 特性分支干净，直接 rebase master
  echo "✅ 特性分支干净，直接 rebase $MASTER_BRANCH"
  git rebase origin/$MASTER_BRANCH
fi

# 切到 master 并保持最新
git checkout $MASTER_BRANCH
git pull origin $MASTER_BRANCH

git merge $FEATURE_BRANCH

echo ""
echo "🎉 发布完成：$FEATURE_BRANCH 已合并到 $MASTER_BRANCH"
echo "👉 如需回退: git reset --hard HEAD~1 或 git reset --hard $BACKUP_BRANCH"
