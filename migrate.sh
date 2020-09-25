#!/bin/bash

export CURRENT_DIR=$(pwd)
export GITHUB_TOKEN="<insert github token here>"
export GITHUB_TEAM="bestone"


REPOS=bestone-bi2-vendor-ui

for REPO_NAME in $(echo $REPOS | sed "s/,/ /g")
do
  echo "$REPO_NAME"

  GH_REPO="BESTSELLER/$REPO_NAME"

  # Create repo in Github
  mkdir /tmp/repos && cd /tmp/repos
  gh repo create $GH_REPO --private --team $GITHUB_TEAM -y
  curl --request PUT \
    --url https://api.github.com/orgs/BESTSELLER/teams/$GITHUB_TEAM/repos/$GH_REPO \
    --header 'accept: application/vnd.github.v3+json' \
    --header 'authorization: token '$GITHUB_TOKEN \
    --data '{"permission":"admin"}'

  # Clone old repo
  git clone --mirror git@bitbucket.org:bestsellerit/$REPO_NAME.git $CURRENT_DIR/repo

  # Push to Github
  cd $CURRENT_DIR/repo
  git remote add new-origin git@github.com:$GH_REPO.git
  git push new-origin --mirror
  cd $CURRENT_DIR

  # Cleanup
  rm -rf ./repo
  rm -rf /tmp/repos
done
