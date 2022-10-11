#!/bin/bash

if test "$#" -ne 1; then
    echo "$0 software-stack | data | compute | io | app-interact" 1>&2
    exit 1
fi

git stash
git checkout master

case "$1" in
    "software-stack")
        # Clean branches and everything.
        set -x
        git remote rm razvand > /dev/null 2>&1
        git branch -D software-stack-lab-readme > /dev/null 2>&1

        git remote add razvand https://github.com/razvand/operating-systems-oer
        git fetch razvand
        git checkout -b software-stack-lab-readme razvand/software-stack-lab-readme
        ;;

    "data")
        # Clean branches and everything.
        git remote rm RazvanN7 > /dev/null 2>&1
        git branch -D Data_lab > /dev/null 2>&1

        git remote add RazvanN7 https://github.com/RazvanN7/operating-systems-oer
        git fetch RazvanN7
        git checkout -b Data_lab RazvanN7/Data_lab
        ;;

    "compute")
        ;;

    "io")
        ;;

    "app-interact")
        ;;

esac
