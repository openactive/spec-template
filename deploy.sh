#!/bin/bash
set -e # exit with nonzero exit code if anything fails

# squash messages
git config --global push.default matching

# clear and re-create the out directory
rm -rf out || exit 0;
mkdir out;

# go to the out directory 
cd out

# get existing gh-pages
git clone -b gh-pages "https://${GH_TOKEN}@${GH_REF}"

cd spec-template

# inside this git repo we'll pretend to be a new user
git config user.name "Travis CI"
git config user.email "travis@openactive.org"

# copy the src file in (do not change existing files)
cp ../../index.html index.src.html

# (have for now!) add a date to ensure there's always something to push!
date > timestamp.txt

git add .
git commit -m "Deploy to GitHub Pages - Raw"

echo Pushing to gh-pages

git push --force --quiet "https://${GH_TOKEN}@${GH_REF}"

cd ../..

# wait for gh-pages to refresh (note anyone accessing the file during this time will get the dynamic version)
sleep 10

# clear and re-create the out directory
rm -rf out || exit 0;
mkdir out;

# go to the out directory and create a *new* Git repo
cd out
git init

# inside this git repo we'll pretend to be a new user
git config user.name "Travis CI"
git config user.email "travis@openactive.org"

# compile using spec-generator
echo Fetching from spec-generator
curl "https://labs.w3.org/spec-generator/?type=respec&url=http://openactive.github.io/spec-template/index.src.html" > index.html;

# The first and only commit to this new Git repo contains all the
# files present with the commit message "Deploy to GitHub Pages".
git add .
git commit -m "Deploy to GitHub Pages - Static"

# Force push from the current repo's master branch to the remote
# repo's gh-pages branch. (All previous history on the gh-pages branch
# will be lost, since we are overwriting it.) We redirect any output to
# /dev/null to hide any sensitive credential data that might otherwise be exposed.
git push --force --quiet "https://${GH_TOKEN}@${GH_REF}" master:gh-pages > /dev/null 2>&1

cd ..

