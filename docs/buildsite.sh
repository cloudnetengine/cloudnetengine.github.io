#!/bin/bash

# The script is automatically build CloudNetEngine GitHub web site
# from master branch to gh-pages branch.
# The repo's "GitHub Pages" setting needs to be set by using 'gh-pages'
# as the GitHub Pages site source.
#
# The script needs to be executed under this repo's root directory,
# i.e. `docs/buildsite.sh`.
set -x

apt-get update
apt-get -y install git rsync python3-sphinx

pwd ls -lah
export SOURCE_DATE_EPOCH=$(git log -1 --pretty=%ct)
 
##############
# BUILD DOCS #
##############
 
# Python Sphinx, configured with source/conf.py
# See https://www.sphinx-doc.org/
make clean
make html

#######################
# Update GitHub Pages #
#######################

git config --global user.name "junxiaocne"
git config --global user.email "jun.xiao@cloudnetengine.com"
 
docroot=`mktemp -d`
rsync -av "build/html/" "${docroot}/"
 
pushd "${docroot}"

git init
git remote add deploy "git@github.com:cloudnetengine/cloudnetengine.github.io.git"
git checkout -b gh-pages
 
# Adds .nojekyll file to the root to signal to GitHub that  
# directories that start with an underscore (_) can remain
touch .nojekyll
 
# Add README
cat > README.md <<EOF
# README for the CloudNetEngine GitHub Pages Branch
This branch is simply a cache for the website served from https://cloudnetengine.github.io
and is not intended to be viewed on github.com.
EOF
 
# Copy the resulting html pages built from Sphinx to the gh-pages branch 
git add .
 
# Make a commit with changes and any new files
msg="Updating Docs for commit ${GITHUB_SHA} made on `date -d"@${SOURCE_DATE_EPOCH}" --iso-8601=seconds` from ${GITHUB_REF} by ${GITHUB_ACTOR}"
git commit -am "${msg}"
 
# overwrite the contents of the gh-pages branch on our github.com repo
git push deploy gh-pages --force
 
popd # return to main repo sandbox root
 
# exit cleanly
exit 0
