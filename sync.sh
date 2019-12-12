#!/usr/bin/bash


# Set paths
export PATH="$PATH:$PWD"


cleandir() {
	rm -rfv /tmp/work
}


paths() {
    ls -d "$1"/*
}

sources() {
    if [ -d "/tmp/sources" ]; then
    echo "directory already exist"
    else
    mkdir -pv /tmp/sources
    fi
    cd /tmp/work/chromium
    sed '/chromium/d' -i sources
    fedpkg sources --outdir=/tmp/sources
    cd /tmp/work/chromium-libs-media-freeworld
    downloadsource.py /tmp/sources --stable 
    rfpkg new-sources $(paths /tmp/sources)
    git add .
    git commit -m "Upload: New freeworld sources"
}
    

squash_merge() {
    git pull https://src.fedoraproject.org/rpms/chromium.git $1
    sleep 10s
    git mergetool
    git clean -f
    git commit
    echo "Now review and commit the changes"
    sleep 5s
}

push() {
    read -p "Are you sure to push changes to repository? " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
    # do dangerous stuff
        rfpkg push
    else
        echo "Okay! Review again for any errors."
    fi
}


# Main functions
#
echo "Usage: "
echo "Syntax: ./sync.sh merge <branch>"
echo "Set your default mergetool before using the script by running ``git config --global merge.tool <youfavmergetool>``"
echo "Make sure you have fedora-packager installed!"
if [ "$1" == "merge" ]; then
cleandir
cd /tmp/
if [ -d  "/tmp/work" ]; then
echo "Directory already exists!"
else
mkdir -v work
fi
cd  work

rfpkg clone free/chromium-libs-media-freeworld
fedpkg clone -a chromium
cd chromium-libs-media-freeworld
ls -al
squash_merge $2
sources
push
fi
