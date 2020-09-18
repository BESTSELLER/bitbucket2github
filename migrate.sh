#!/bin/bash

CURRENT_DIR=$(pwd)

REPO_NAME="pipectl"

export GITHUB_TOKEN="<insert github token here"
export GITHUB_TEAM="Engineering-Services"
export GH_REPO="BESTSELLER/$REPO_NAME"

# Create repo in Github
mkdir /tmp/repos && /tmp/repos
gh repo create $GH_REPO --private --team $GITHUB_TEAM -y
cd $CURRENT_DIR

# Clone old repo
git clone --mirror git@bitbucket.org:bestsellerit/$REPO_NAME.git ./repo



cd repo
git remote add new-origin git@github.com:$GH_REPO.git
git push new-origin --mirror
cd $CURRENT_DIR

# Cleanup
rm -rf ./repo
rm -rf /tmp/repos