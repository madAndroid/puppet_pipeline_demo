#!/bin/bash

src_dir=$1
repo_dir=$2

if [ $# != '2' ]; then
    echo "incorrect number of arguments provided!"
    echo "please ensure the first arg is the src_dir, the second is the repo_dir"
    exit
fi

cd $repo_dir
rsync --delete -vr $src_dir/ $repo_dir/packages/

for rpm in $(find $repo_dir -type f -name '*rpm'); do
    if [ ! -L $(basename $rpm) ]; then
        echo "==== linking $rpm to $repo_dir ==="
        ln -s $rpm .
    else
        echo "==== No new RPMs to link ===="
    fi
done

## remove any dead symlinks
for file in $(find . -maxdepth 1); do
    if [ ! -e $file ]; then
        echo "==== Removing dead symlink $file ==="
        rm -fv $file
    fi
done

createrepo .
chmod 755 $repo_dir/repodata
