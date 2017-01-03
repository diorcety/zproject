#!/usr/bin/env bash
set -e

# NOTE: This script is not standalone, it is included from project root
# ci_build.sh script, which sets some envvars (like REPO_DIR below).
[ -n "${REPO_DIR-}" ] || exit 1

# Set this to enable verbose profiling
[ -n "${CI_TIME-}" ] || CI_TIME=""
case "$CI_TIME" in
    [Yy][Ee][Ss]|[Oo][Nn]|[Tt][Rr][Uu][Ee])
        CI_TIME="time -p " ;;
    [Nn][Oo]|[Oo][Ff][Ff]|[Ff][Aa][Ll][Ss][Ee])
        CI_TIME="" ;;
esac

# Set this to enable verbose tracing
[ -n "${CI_TRACE-}" ] || CI_TRACE="no"
case "$CI_TRACE" in
    [Nn][Oo]|[Oo][Ff][Ff]|[Ff][Aa][Ll][Ss][Ee])
        set +x ;;
    [Yy][Ee][Ss]|[Oo][Nn]|[Tt][Rr][Uu][Ee])
        set -x ;;
esac

$CI_TIME docker run -v "$REPO_DIR":/gsl zeromqorg/zproject project.xml

# keep an eye on git version used by CI
git --version
if [[ $(git --no-pager diff -w) ]]; then
    git --no-pager diff -w
    echo "There are diffs between current code and code generated by zproject!"
    exit 1
fi
if [[ $(git status -s) ]]; then
    git status -s
    echo "zproject generated new files!"
    exit 1
fi
