#!/bin/bash

if [ -z "${PLATFORM:-}" ]; then
    PLATFORM=$TRAVIS_OS_NAME;
fi

if [ "$PLATFORM" == "osx" ]; then
    PLATFORM="macosx";
fi

if [ -z "$PLATFORM" ]; then
    if [ "$(uname)" == "Linux" ]; then
        PLATFORM="linux";
    else
        PLATFORM="macosx";
    fi;
fi


if [ "$PLATFORM" == "linux" ]; then
  - sudo add-apt-repository -y ppa:grilo-team/travis
  - sudo apt-get update -qq
  - sudo apt-get install -y liblua5.3-dev
elif [ "$PLATFORM" == "macosx" ]; then
    brew update
    brew tap homebrew/versions
    brew install homebrew/versions/lua53
fi
