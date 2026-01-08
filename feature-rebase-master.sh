#!/bin/bash
# 用法：./feature-rebase-master.sh feat-xxx

set -e

FEATURE=$1
DEV=dev
MASTER=master

if [ -z "$FEATURE" ]; then
  echo "❌ 请传入特性分支名"
  exit 1
fi

echo "▶ 切换到特性分支：$FEATURE"
git checkout "$FEATURE"

echo "▶ 同步远程"
git fetch origin

echo "▶ 计算 fork-point（$FEATURE ← $DEV）"
FORK_POINT=$(git merge-base "$FEATURE" "origin/$DEV")

echo "▶ 基于 master 重放特性提交"
git rebase --onto "origin/$MASTER" "$FORK_POINT" "$FEATURE"

echo "▶ 校验：只应看到 $FEATURE 的提交"
git log --oneline "origin/$MASTER..$FEATURE"

echo "✅ 特性分支已安全回归 master 基线"
