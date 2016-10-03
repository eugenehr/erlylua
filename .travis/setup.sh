#!/bin/bash

source .travis/platform.sh

LUA_DIR="$TRAVIS_BUILD_DIR/lua$LUA"

if [ $LUA == "5.3" ]
then
    curl http://www.lua.org/ftp/lua-5.3.3.tar.gz | tar xz
    cd lua-5.3.3;
fi

make MYCFLAGS="-fPIC" MYLDFLAGS="-fPIC" TO_LIB="liblua$LUA.a" $PLATFORM
make INSTALL_TOP="$LUA_DIR" install

export LIBRARY_PATH="$LIBRARY_PATH:$LUA_DIR/lib"
export LUA_INCLUDE_DIR=$LUA_DIR/include
cd $TRAVIS_BUILD_DIR



