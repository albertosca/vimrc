#!/bin/bash

for directory in *
do
  (cd $directory && echo "$directory" && eval 'git pull')
done
