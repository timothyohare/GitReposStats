#!/bin/bash
eval `ssh-agent -s`
ssh-add

export GITHUB_BASE_URL=$1
export GITHUB_ORG=$2
export GITHUB_TOKEN=$3

curl "https://$GITHUB_BASE_URL/api/v3/orgs/$GITHUB_ORG/repos?access_token=$GITHUB_TOKEN&page=1&per_page=100" |
  grep -e 'clone_url*' |
  cut -d \" -f 4  |
  sed 's/https:\/\//git@/'  |
  sed 's/$GITHUB_BASE_URL\//$GITHUB_BASE_URL:/' |
  xargs -L1 git clone
 
 
# Count the number of Typescript SLOC
echo "Typescript SLOC"
( find ./ -name '*.ts' -print0 | xargs -0 cat ) | wc -l
echo "Typescript SLOC, different method"
find . -name '*.ts' | xargs wc -l | grep total
 
# Count of Typescript files
echo "Count of Typescript files"
( find ./ -name '*.ts' -print ) | wc -l
 
# add up the number of commits
echo "Number of commits:"
 ( find ./ -maxdepth 1 -type d  -exec git --git-dir={}/.git --work-tree=$PWD/{} rev-list --count HEAD \; ) | sort -n | awk '{ sum += $1 } END { print sum }'
 
# find commit authors, print out a de-dupped list of authors. Also print out how many repositories they have committed to.
echo "Commit authors and count of repositories commited against:"
find ./ -maxdepth 1 -type d  -exec git --git-dir={}/.git --work-tree=$PWD/{} rev-parse HEAD \; -exec git --git-dir={}/.git --work-tree=$PWD/{} shortlog --summary --numbered --email  \; \
| awk '{print $2 $3 $4}' | sort | uniq -c
