#!/bin/bash
# 用法：./merge-feature-to-master.sh feat-xxx

set -e

FEATURE=$1
MASTER=master

if [ -z "$FEATURE" ]; then
  echo "❌ 请传入特性分支名"
  exit 1
fi

echo "▶ 切换到 master"
git checkout "$MASTER"
git fetch origin
git reset --hard "origin/$MASTER"

echo "▶ 检查即将合入的提交"
git log --oneline "origin/$MASTER..$FEATURE"

echo "▶ 合并特性分支"
git merge --no-ff "$FEATURE"

echo "✅ 已安全合并 $FEATURE 到 master"
