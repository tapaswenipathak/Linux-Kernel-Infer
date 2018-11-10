#!/usr/bin/env bash

for branch in $(git rev-list --all)
do
  if (git ls-tree -r --name-only $branch | grep "$1")
  then
     echo $branch
  fi
done
