#!/bin/bash

# Git PS Workflow Function
# Usage: gss [target-branch]
# Default target branch: dev

gitsync() {
  #  set -e  # Exit on any error
    
    # Get target branch from argument or default to 'dev'
    local TARGET_BRANCH=${1:-dev}
    
    # Get current branch name
    local CURRENT_BRANCH=$(git branch --show-current 2>/dev/null)
    
    # Check if we're in a git repository
    if [ -z "$CURRENT_BRANCH" ]; then
        echo "❌ Error: Not in a git repository"
        return 1
    fi
    
    # Check if GitHub CLI is available
    if ! command -v gh &> /dev/null; then
        echo "❌ Error: GitHub CLI (gh) is not installed"
        echo "Install with: brew install gh"
        return 1
    fi
    
    # Check if we're not trying to create PR to the same branch
    if [ "$CURRENT_BRANCH" = "$TARGET_BRANCH" ]; then
        echo "❌ Error: Cannot create PR from $CURRENT_BRANCH branch to $TARGET_BRANCH branch (same branch)"
        return 1
    fi
    
    echo "🚀 Starting git ps workflow for branch: $CURRENT_BRANCH → $TARGET_BRANCH"
    
    # Step 1: Push changes to git
    echo "📤 Step 1: Pushing changes to remote..."
    if ! git push origin "$CURRENT_BRANCH"; then
        echo "❌ Failed to push branch $CURRENT_BRANCH"
        return 1
    fi
    echo "✅ Successfully pushed $CURRENT_BRANCH to remote"
    
    # Step 2: Create PR to target branch
    echo "📋 Step 2: Creating PR to $TARGET_BRANCH branch..."
    # Get the last commit message for PR title
    local COMMIT_MSG=$(git log -1 --pretty=format:"%s")
    local PR_URL
    if ! PR_URL=$(gh pr create --base "$TARGET_BRANCH" --head "$CURRENT_BRANCH" --title "$COMMIT_MSG" --body "Auto-generated PR from git ps workflow"); then
        echo "❌ Failed to create PR"
        return 1
    fi
    echo "✅ Successfully created PR: $PR_URL"
    
    # Extract PR number from URL
    local PR_NUMBER=$(echo "$PR_URL" | grep -o '[0-9]*$')
    
    # Step 3: Merge the PR (without deleting branch)
    echo "🔀 Step 3: Merging PR #$PR_NUMBER..."
    if ! gh pr merge "$PR_NUMBER" --merge; then
        echo "❌ Failed to merge PR #$PR_NUMBER"
        echo "PR created but not merged: $PR_URL"
        return 1
    fi
    echo "✅ Successfully merged PR #$PR_NUMBER"
    
    echo "🎉 git ps workflow completed successfully!"
    echo "📋 Summary:"
    echo "  - Pushed branch: $CURRENT_BRANCH"
    echo "  - Target branch: $TARGET_BRANCH"
    echo "  - Created & merged PR: $PR_URL"
    echo "  - Branch $CURRENT_BRANCH has been kept for future use"
}

# Create shorter alias
alias gss='gitsync'

