#!/bin/bash
# 用法：./feature-rebase-dev.sh feat-xxx

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

echo "▶ 计算 fork-point（$FEATURE ← $MASTER）"
FORK_POINT=$(git merge-base "$FEATURE" "origin/$MASTER")

echo "▶ 基于 dev 重放特性提交"
git rebase --onto "origin/$DEV" "$FORK_POINT" "$FEATURE"

echo "✅ 特性分支已对齐 dev（仅代码层面）"
