#!/bin/sh

#
# Prepare a Diff
#
rm -f ./diff2html.sh
wget https://gist.github.com/stopyoukid/5888146/raw/2100dfae6131a59250d33819754d204fed9c7f20/diff2html.sh
chmod +x ./diff2html.sh
git diff $GIT_PREVIOUS_COMMIT $GIT_COMMIT | ./diff2html.sh > diff.html # Generate a diff

#
# Prepare NodeJS Environment
#
#http://nodejs.org/dist/v0.8.14/node-v0.8.14-linux-x64.tar.gz
node_version=v0.10.18
file_name=node-$node_version-linux-x64
if [ ! -e $file_name ]
then
    wget http://nodejs.org/dist/$node_version/$file_name.tar.gz
    tar xf $file_name.tar.gz
fi
export PATH=$PWD/$file_name/bin:$PATH

npm install
./node_modules/grunt-cli/bin/grunt cloudbees
