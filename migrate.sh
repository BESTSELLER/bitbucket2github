#!/bin/bash
CURRENT_DIR=$(pwd)
REPOS=$@
error_count=0
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color


if [ "$BITBUCKET_OWNER" = "" ]; then
  echo -e "${RED}Missing Bitbucket owner !${NC}"
  echo -e "${BLUE}Add BITBUCKET_OWNER as an environment variable\n${NC}"
  error_count=$((error_count+1))
fi

if [ "$GITHUB_TOKEN" = "" ]; then
  echo -e "${RED}Missing github token !${NC}"
  echo -e "${BLUE}Add GITHUB_TOKEN as an environment variable\n${NC}"
  error_count=$((error_count+1))
fi

if [ "$GITHUB_TEAM" = "" ]; then
  echo -e "${RED}Missing github team name !${NC}"
  echo -e "${BLUE}Add GITHUB_TEAM as an environment variable\n${NC}"
  error_count=$((error_count+1))
fi

if [ "$GITHUB_ORG" = "" ]; then
  echo -e "${RED}Missing github organization name !${NC}"
  echo -e "${BLUE}Add GITHUB_ORG as an environment variable\n${NC}"
  error_count=$((error_count+1))
fi

if [ "$REPOS" = "" ]; then
  echo -e "${RED}No arguments was given !${NC}"
  error_count=$((error_count+1))
fi

if [ $error_count -gt 0 ]; then
  exit $error_count
fi


for REPO_NAME in $REPOS
do
  echo "$REPO_NAME"

  GH_REPO="$GITHUB_ORG/$REPO_NAME"

  # Create repo in Github
  mkdir /tmp/repos && cd /tmp/repos
  gh repo create $GH_REPO --private --team $GITHUB_TEAM -y
  curl --request PUT \
    --url https://api.github.com/orgs/$GITHUB_ORG/teams/$GITHUB_TEAM/repos/$GH_REPO \
    --header 'accept: application/vnd.github.v3+json' \
    --header 'authorization: token '$GITHUB_TOKEN \
    --data '{"permission":"admin"}'

  # Clone old repo
  git clone --mirror git@bitbucket.org:$BITBUCKET_OWNER/$REPO_NAME.git $CURRENT_DIR/repo

  # Push to Github
  cd $CURRENT_DIR/repo
  git remote add new-origin git@github.com:$GH_REPO.git
  git push new-origin --mirror
  cd $CURRENT_DIR

  # Cleanup
  rm -rf ./repo
  rm -rf /tmp/repos
done
