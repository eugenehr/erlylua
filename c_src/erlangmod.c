#include <stdarg.h>
#include <stdlib.h>
#include <erl_nif.h>
#include <lua.h>
#include <lauxlib.h>


void luaopen_erlang(lua_State *L) {
    printf("luaopen_erlang() called\n");
}