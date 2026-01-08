#!/bin/bash

# Usage: ./cherry_pick_to_target.sh <target_branch> [feature_branch]
# 示例: ./cherry_pick_to_target.sh master feature/A
# 如果未指定feature_branch，则使用当前分支。

if [ $# -lt 1 ]; then
    echo "Usage: $0 <target_branch> [feature_branch]"
    exit 1
fi

TARGET_BRANCH=$1
FEATURE_BRANCH=${2:-$(git rev-parse --abbrev-ref HEAD)}

# 确保在干净的工作区
if ! git diff-index --quiet HEAD --; then
    echo "Error: Working directory is not clean. Please commit or stash changes."
    exit 1
fi

# 更新远程分支
git fetch origin

# 找到分歧点（merge base）
MERGE_BASE=$(git merge-base $TARGET_BRANCH $FEATURE_BRANCH)

# 获取要cherry-pick的提交列表（从分歧点之后，按顺序）
COMMITS=$(git rev-list --reverse $MERGE_BASE..$FEATURE_BRANCH)

if [ -z "$COMMITS" ]; then
    echo "No commits to cherry-pick from $FEATURE_BRANCH after merge base."
    exit 0
fi

# 创建一个新分支基于目标分支（安全应用cherry-pick）
NEW_BRANCH="cherry-pick-$FEATURE_BRANCH-to-$TARGET_BRANCH"
git checkout $TARGET_BRANCH
git checkout -b $NEW_BRANCH

# 逐一cherry-pick提交
for COMMIT in $COMMITS; do
    echo "Cherry-picking commit: $COMMIT"
    git cherry-pick $COMMIT
    if [ $? -ne 0 ]; then
        echo "Conflict detected. Resolve manually, then run 'git cherry-pick --continue' and continue the script if needed."
        exit 1  # 暂停脚本，等待手动解决
    fi
done

echo "Cherry-pick completed on new branch: $NEW_BRANCH"
echo "To merge to $TARGET_BRANCH: git checkout $TARGET_BRANCH; git merge $NEW_BRANCH"
echo "If everything is fine, you can push: git push origin $TARGET_BRANCH"