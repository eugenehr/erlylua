%% Copyright (c) Eugene Khrustalev 2016. All Rights Reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.

%% @author Eugene Khrustalev <eugene.khrustalev@gmail.com>
%% @doc
-module(lua_tests).
-author("Eugene Khrustalev <eugene.khrustalev@gmail.com>").

-compile([export_all]).

-include_lib("eunit/include/eunit.hrl").


newstate_close_test() ->
    L1 = lua:newstate(),
    L2 = lua:newstate(),
    {ok, V} = lua:version(L1),
    {ok, V} = lua:version(L2),
    ok = lua:close(L1),
    {error, _Msg} = lua:version(L1),
    ok = lua:close(L2).

push_access_test() ->
    L = lua:newstate(),
    {ok, 0} = lua:gettop(L),
    {ok, 1} = lua:absindex(L, 0),
    {ok, 0} = lua:absindex(L, -1),
    ok = lua:pushnil(L),
    {ok, true} = lua:isnil(L, -1),
    ok = lua:pushnil(L),
    {ok, true} = lua:rawequal(L, -1, -2),
    ok = lua:settop(L, 0),
    {ok, 0} = lua:gettop(L),
    ok = lua:pushinteger(L, 0),
    {ok, 0} = lua:tointeger(L, -1),
    ok = lua:pushnumber(L, 1),
    {ok, 1} = lua:tointeger(L, -1),
    ok = lua:pushnumber(L, 2.0),
    {ok, 2} = lua:tointeger(L, -1),
    ok = lua:pushnumber(L, 3.14),
    {ok, 3.14} = lua:tonumber(L, -1),
    {error, _} = lua:tointeger(L, -1),
    {ok, true} = lua:toboolean(L, -1),
    {ok, false} = lua:isnil(L, -1),
    {ok, true} = lua:isnumber(L, -2),
    {ok, true} = lua:isinteger(L, -3),
    {ok, true} = lua:isinteger(L, -4),
    {ok, 4} = lua:gettop(L),
    ok = lua:pushvalue(L, -1),
    {ok, true} = lua:compare(L, -1, -2, eq),
    {ok, true} = lua:compare(L, -1, -2, le),
    {ok, false} = lua:compare(L, -2, -3, lt),
    {ok, true} = lua:compare(L, -3, -2, lt),
    ok = lua:pushstring(L, "1"),
    {ok, true} = lua:isnumber(L, -1),
    {ok, true} = lua:isstring(L, -1),
    ok = lua:pushstring(L, <<"1">>),
    {ok, true} = lua:isnumber(L, -1),
    {ok, true} = lua:isstring(L, -1),
    {ok, true} = lua:rawequal(L, -1, -2),
    ok = lua:settop(L, 0),
    ok = lua:pushstring(L, <<"">>),
    {ok, true} = lua:isstring(L, -1),
    ok = lua:pushstring(L, <<"test">>),
    {ok, "test"} = lua:tostring(L, -1),
    {ok, <<"test">>} = lua:tobinstring(L, -1),
    ok = lua:settop(L, 0),
    ok = lua:pushboolean(L, true),
    ok = lua:pushboolean(L, 0.0),
    ok = lua:pushboolean(L, 0.2),
    {ok, true} = lua:isboolean(L, -1),
    {ok, true} = lua:toboolean(L, -1),
    ok = lua:pushboolean(L, false),
    {ok, false} = lua:toboolean(L, -1),
    ok = lua:pushboolean(L, 1),
    {ok, true} = lua:toboolean(L, -1),
    ok = lua:pushboolean(L, 0),
    {ok, false} = lua:toboolean(L, -1),
    ok = lua:pushboolean(L, -1),
    {ok, true} = lua:toboolean(L, -1),
    ok = lua:settop(L, 0),
    {ok, none} = lua:type(L, 100),
    {ok, true} = lua:isnoneornil(L, 100),
    ok = lua:pushnil(L),
    {ok, nil} = lua:type(L, -1),
    ok = lua:pushnumber(L, 1),
    {ok, number} = lua:type(L, -1),
    ok = lua:pushinteger(L, 2),
    {ok, number} = lua:type(L, -1),
    ok = lua:pushstring(L, "12345"),
    {ok, string} = lua:type(L, -1),
    ok = lua:pushboolean(L, true),
    {ok, boolean} = lua:type(L, -1),
    lua:close(L).

get_set_test() ->
    L = lua:newstate(),
    {ok, table} = lua:getglobal(L, table),
    {ok, table} = lua:getglobal(L, "table"),
    {ok, function} = lua:getfield(L, -1, insert),
    {ok, function} = lua:getfield(L, -2, "insert"),
    {ok, function} = lua:getfield(L, -3, <<"insert">>),
    {ok, true} = lua:isfunction(L, -1),
    {ok, true} = lua:iscfunction(L, -1),
    ok = lua:pushstring(L, remove),
    _S1 = lua:dumpstack(L),
    {ok, function} = lua:gettable(L, -5),
    _S2 = lua:dumpstack(L),
    lua:settop(L, 0),
    [] = lua:dumpstack(L),
    lua:close(L).

table_test() ->
    L = lua:newstate(),
    ok = lua:createtable(L, 0, 0),
    ok = lua:pushinteger(L, 1),
    ok = lua:setfield(L, -2, "a"),
    ok = lua:pushnumber(L, 3.1415),
    ok = lua:setfield(L, -2, "pi"),
    ok = lua:pushnil(L),
    ok = lua:seti(L, -2, 1),
    ok = lua:pushinteger(L, 2),
    ok = lua:pushboolean(L, true),
    ok = lua:settable(L, -3),
    ok = lua:newuserdata(L, <<"userdata">>),
    ok = lua:newuserdata(L, <<"uservalue">>),
    ok = lua:setuservalue(L, -2),
    {ok, 8} = lua:rawlen(L, -1),
    ok = lua:rawseti(L, -2, 3),
    ok = lua:pushstring(L, "string"),
    ok = lua:pushinteger(L, 4),
    ok = lua:rawset(L, -3),
    ok = lua:pushinteger(L, 5),
    ok = lua:setfield(L, -2, five),
    ok = lua:setglobal(L, "test"),

    {ok, table} = lua:getglobal(L, "test"),
    {ok, true} = lua:istable(L, -1),
    {ok, number} = lua:getfield(L, -1, "a"),
    {ok, 1} = lua:tointeger(L, -1),
    lua:settop(L, 1),
    {ok, number} = lua:getfield(L, -1, "pi"),
    {ok, 3.1415} = lua:tonumber(L, -1),
    lua:settop(L, 1),
    {ok, nil} = lua:geti(L, -1, 1),
    lua:settop(L, 1),
    ok = lua:pushinteger(L, 2),
    {ok, boolean} = lua:gettable(L, -2),
    {ok, true} = lua:toboolean(L, -1),
    lua:settop(L, 1),
    {ok, userdata} = lua:rawgeti(L, -1, 3),
    {ok, true} = lua:isuserdata(L, -1),
    {ok, <<"userdata">>} = lua:touserdata(L, -1),
    {ok, userdata} = lua:getuservalue(L, -1),
    {ok, <<"uservalue">>} = lua:touserdata(L, -1),
    lua:settop(L, 1),
    ok = lua:pushinteger(L, 3),
    {ok, userdata} = lua:rawget(L, -2),
    {ok, number} = lua:getfield(L, -2, "string"),
    lua:settop(L, 1),
    {ok, number} = lua:getfield(L, -1, <<"five">>),
    {ok, 5} = lua:tointeger(L, -1),
    lua:settop(L, 0),

    Dir = code:lib_dir(erlylua, test),
    Filename = filename:join(Dir, "test.lua"),
    ok = lua:loadfile(L, Filename),
    lua:pcall(L, 0, 0),

    {ok, function} = lua:getglobal(L, "ret_array"),
    ok = lua:pcall(L, 0),
    {ok, true} = lua:istable(L, -1),
    ok = lua:pushnil(L),
    {ok, true} = lua:next(L, -2),
    {ok, 1} = lua:tointeger(L, -2),
    {ok, 1.0} = lua:tonumber(L, -1),
    lua:settop(L, 2),
    {ok, true} = lua:next(L, -2),
    {ok, 2} = lua:tointeger(L, -2),
    {ok, 2.0} = lua:tonumber(L, -1),
    lua:settop(L, 2),
    {ok, true} = lua:next(L, -2),
    {ok, 3} = lua:tointeger(L, -2),
    {ok, 3.0} = lua:tonumber(L, -1),
    lua:settop(L, 2),
    {ok, false} = lua:next(L, -2),

    lua:settop(L, 0),
    {ok, function} = lua:getglobal(L, "ret_table"),
    ok = lua:pcall(L, 0),
    {ok, true} = lua:istable(L, -1),
    ok = lua:pushnil(L),
    {ok, true} = lua:next(L, -2),
    {ok, 1} = lua:tointeger(L, -2),
    {ok, 1.0} = lua:tonumber(L, -1),
    lua:settop(L, 2),
    {ok, true} = lua:next(L, -2),
    {ok, 2} = lua:tointeger(L, -2),
    {ok, 2.0} = lua:tonumber(L, -1),
    lua:settop(L, 2),
    {ok, true} = lua:next(L, -2),
    {ok, 3} = lua:tointeger(L, -2),
    {ok, 3.0} = lua:tonumber(L, -1),
    lua:settop(L, 2),
    {ok, true} = lua:next(L, -2),
    {ok, 4} = lua:tointeger(L, -2),
    {ok, 4.0} = lua:tonumber(L, -1),
    lua:settop(L, 2),
    {ok, true} = lua:next(L, -2),
    {ok, 5} = lua:tointeger(L, -2),
    {ok, 5.0} = lua:tonumber(L, -1),
    lua:settop(L, 2),
    {ok, true} = lua:next(L, -2),
    _S = lua:dumpstack(L),
    {ok, "bool"} = lua:tostring(L, -2),
    {ok, true} = lua:toboolean(L, -1),
    lua:settop(L, 2),
    {ok, true} = lua:next(L, -2),
    {ok, "str"} = lua:tostring(L, -2),
    {ok, "value"} = lua:tostring(L, -1),
    lua:settop(L, 2),
    {ok, false} = lua:next(L, -2),

    lua:close(L).

load_test() ->
    L = lua:newstate(),
    {error, _} = lua:loadbuffer(L, "qwerty", "chunk"),
    Foo = "return function(a)
        local b = a or 0
        return b-1, b, b+1
    end",
    ok = lua:loadbuffer(L, Foo, "foo"),
    {ok, true} = lua:isfunction(L, -1),
    {ok, Dumped} = lua:dump(L, false),
    ok = lua:loadbuffer(L, Dumped, "dumped"),
    {ok, true} = lua:isfunction(L, -1),
    [function, function] = lua:dumpstack(L),
    ok = lua:pcall(L, 0),
    ok = lua:setglobal(L, foo),
    lua:settop(L, 0),
    {ok, function} = lua:getglobal(L, "foo"),
    ok = lua:pushinteger(L, 2),
    ok = lua:pcall(L, 1),
    [3, 2, 1] = lua:dumpstack(L),
    lua:settop(L, 0),
    ok = lua:dostring(L, "return 1+2"),
    [3] = lua:dumpstack(L),
    lua:settop(L, 0),

    Dir = code:lib_dir(erlylua, test),
    Filename = filename:join(Dir, "test.lua"),
    ok = lua:loadfile(L, Filename),
    lua:pcall(L, 0, 0),

    {ok, function} = lua:getglobal(L, "ret_none"),
    ok = lua:pcall(L, 0),
    [] = lua:dumpstack(L),

    lua:settop(L, 0),
    {ok, function} = lua:getglobal(L, "ret_1"),
    ok = lua:pcall(L, 0),
    [1] = lua:dumpstack(L),

    lua:settop(L, 0),
    {ok, function} = lua:getglobal(L, "ret_1_2"),
    ok = lua:pcall(L, 0),
    [2, 1] = lua:dumpstack(L),

    lua:settop(L, 0),
    {ok, function} = lua:getglobal(L, "sum"),
    ok = lua:pushinteger(L, 1),
    ok = lua:pushnumber(L, 3.1),
    ok = lua:pcall(L, 2),
    [4.1] = lua:dumpstack(L),

    lua:settop(L, 0),
    ok = lua:dofile(L, Filename),
    ["test"] = lua:dumpstack(L),

    lua:close(L).

gc_test() ->
    L = lua:newstate(),
    [ok, ok, ok, ok] =
        [lua:gc(L, A, 0) || A <- [stop, restart, collect, step]],
    [{ok,_N1},{ok,_N2},{ok,_N3},{ok,_N5}] =
        [lua:gc(L, A, 0) || A <-[count, countb, setpause, setstepmul]],
    case lua:gc(L, isrunning, 0) of
        {ok, true} -> ok;
        {ok, false} -> false
    end,
    lua:close(L).
