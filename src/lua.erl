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
%% @doc An Erlang NIF with a complete set of bindings to the Lua 5.3

-module(lua).
-author("Eugene Khrustalev <eugene.khrustalev@gmail.com>").

%% State manipulation functions
-export([newstate/0, close/1, version/1]).
%% Basic stack manipulation functions
-export([absindex/2, gettop/1, settop/2, pop/2, pushvalue/2, rotate/3, copy/3, checkstack/2]).
-export([insert/2, remove/2, replace/2]).
%% Access stack functions
-export([isnumber/2, isstring/2, iscfunction/2, isinteger/2, isuserdata/2, islightuserdata/2, type/2]).
-export([isfunction/2, istable/2, isnil/2, isboolean/2, isthread/2, isnone/2, isnoneornil/2]).
-export([tonumber/2, tointeger/2, toboolean/2, tostring/2, tobinstring/2, touserdata/2]).
%% Comparision functions
-export([rawlen/2, rawequal/3, compare/4]).
%% Push functions
-export([pushnil/1, pushnumber/2, pushinteger/2, pushstring/2, pushboolean/2]).
%% Get functions
-export([getglobal/2, gettable/2, getfield/3, geti/3, rawget/2, rawgeti/3]).
-export([createtable/3, newtable/1, newuserdata/2, getmetatable/2, getuservalue/2]).
%% Set functions
-export([setglobal/2, settable/2, setfield/3, seti/3, rawset/2, rawseti/3]).
-export([setmetatable/2, setuservalue/2]).
%% Call and load functions
-export([pcall/2, pcall/3, loadbuffer/3, loadfile/2, dump/2, dostring/2, dofile/2]).
%% Garbage collection
-export([gc/3]).
%% Miscellaneous functions
-export([error/1, error/2, error/3, next/2, concat/2, len/2]).

%% Useful functions
-export([dumpstack/1]).


-type lua() :: term().
-export_type([lua/0]).


%%====================================================================
%% State manipulation functions
%%====================================================================

-spec newstate() -> L :: lua().
%%
%% @doc Create a new Lua state
%%
newstate() ->
    erlylua_nif:newstate().


%%--------------------------------------------------------------------
-spec close(L :: lua())  -> ok.
%%
%% @doc Close an existing Lua state
%%
close(L) ->
    erlylua_nif:close(L).


%%--------------------------------------------------------------------
-spec version(L :: lua())  -> {ok, float()}.
%%
%% @doc Return the Lua interpreter version
%%
version(L) ->
    erlylua_nif:version(L).


%%====================================================================
%% Basic stack manipulation functions
%%====================================================================

-spec absindex(L :: lua(), Idx :: integer()) -> {ok, integer()}.
%%
%% @doc Convert an acceptable stack index into an absolute index
%%
absindex(L, Idx) when is_integer(Idx) ->
    erlylua_nif:absindex(L, Idx).


%%--------------------------------------------------------------------
-spec gettop(L :: lua()) -> {ok, integer()}.
%%
%% @doc Get the absolute index of the stack top
%%
gettop(L) ->
    erlylua_nif:gettop(L).


%%--------------------------------------------------------------------
-spec settop(L :: lua(), Idx :: integer()) -> ok.
%%
%% @doc Set the absolute index of the stack top
%%
settop(L, Idx) when is_integer(Idx) ->
    erlylua_nif:settop(L, Idx).


%%--------------------------------------------------------------------
-spec pop(L :: lua(), N :: integer()) -> ok.
%%
%% @doc Pop N elements from the stack
%%
pop(L, N) when is_integer(N) ->
    settop(L, -N-1).


%%--------------------------------------------------------------------
-spec pushvalue(L :: lua(), Idx :: integer()) -> ok.
%%
%% @doc Push a value from the given position to the top of the stack
%%
pushvalue(L, Idx) when is_integer(Idx) ->
    erlylua_nif:pushvalue(L, Idx).


%%--------------------------------------------------------------------
-spec rotate(L :: lua(), Idx :: integer(), N :: integer()) -> ok.
%%
%% @doc Rotate the stack elements between the valid index Idx and the top of the stack
%%
rotate(L, Idx, N) when is_integer(Idx), is_integer(N) ->
    erlylua_nif:rotate(L, Idx, N).


%%--------------------------------------------------------------------
-spec copy(L :: lua(), From :: integer(), To :: integer()) -> ok.
%%
%% @doc Copy the element at index From into the valid index To, replacing the value at that position
%%
copy(L, From, To) when is_integer(From), is_integer(To) ->
    erlylua_nif:copy(L, From, To).


%%--------------------------------------------------------------------
-spec checkstack(L :: lua(), N :: integer()) -> {ok, true} | {ok, false}.
%%
%% @doc Ensure that the stack has space for at least N extra slots
%%
checkstack(L, N) when is_integer(N) ->
    erlylua_nif:checkstack(L, N).


%%--------------------------------------------------------------------
-spec insert(L :: lua(), Idx :: integer()) -> ok.
%%
%% @doc Move the top element into the given valid index,
%% @doc shifting up the elements above this index to open space
%%
insert(L, Idx) when is_integer(Idx) ->
    rotate(L, Idx, 1).


%%--------------------------------------------------------------------
-spec remove(L :: lua(), Idx :: integer()) -> ok.
%%
%% @doc Remove the element at the given valid index,
%% @doc shifting down the elements above this index to fill the gap
%%
remove(L, Idx) when is_integer(Idx) ->
    rotate(L, Idx, -1),
    pop(L, 1).


%%--------------------------------------------------------------------
-spec replace(L :: lua(), Idx :: integer()) -> ok.
%%
%% @doc Move the top element into the given valid index without shifting any element
%% @doc (therefore replacing the value at that given index), and then pop the top element.
%%
replace(L, Idx) when is_integer(Idx) ->
    copy(L, -1, Idx),
    pop(L, 1).



%%====================================================================
%% Access stack functions
%%====================================================================

-spec isnumber(L :: lua(), Idx :: integer()) -> {ok, true} | {ok, false}.
%%
%% @doc Test the value at the given index is a number or a string convertible to a number
%%
isnumber(L, Idx) when is_integer(Idx) ->
    erlylua_nif:isnumber(L, Idx).


%%--------------------------------------------------------------------
-spec isinteger(L :: lua(), Idx :: integer()) -> {ok, true} | {ok, false}.
%%
%% @doc Test the value at the given index is an integer or a string convertible to an integer
%%
isinteger(L, Idx) when is_integer(Idx) ->
    erlylua_nif:isinteger(L, Idx).


%%--------------------------------------------------------------------
-spec isstring(L :: lua(), Idx :: integer()) -> {ok, true} | {ok, false}.
%%
%% @doc Test the value at the given index is a string or a number (which is always convertible to a string)
%%
isstring(L, Idx) when is_integer(Idx) ->
    erlylua_nif:isstring(L, Idx).


%%--------------------------------------------------------------------
-spec iscfunction(L :: lua(), Idx :: integer()) -> {ok, true} | {ok, false}.
%%
%% @doc Test the value at the given index is a C function
%%
iscfunction(L, Idx) when is_integer(Idx) ->
    erlylua_nif:iscfunction(L, Idx).


%%--------------------------------------------------------------------
-spec isuserdata(L :: lua(), Idx :: integer()) -> {ok, true} | {ok, false}.
%%
%% @doc Test the value at the given index is an userdata
%%
isuserdata(L, Idx) when is_integer(Idx) ->
    erlylua_nif:isuserdata(L, Idx).


%%--------------------------------------------------------------------
-spec islightuserdata(L :: lua(), Idx :: integer()) -> {ok, true} | {ok, false}.
%%
%% @doc Test the value at the given index is a light userdata
%%
islightuserdata(L, Idx) when is_integer(Idx) ->
    erlylua_nif:islightuserdata(L, Idx).


%%--------------------------------------------------------------------
-spec type(L :: lua(), Idx :: integer()) -> {ok, atom()}.
%%
%% @doc Return a type name (as atom) of the value at the given index
%%
type(L, Idx) when is_integer(Idx) ->
    erlylua_nif:type(L, Idx).


%%--------------------------------------------------------------------
-spec isfunction(L :: lua(), Idx :: integer()) -> {ok, true} | {ok, false}.
%%
%% @doc Test the value at the given index is a function
%%
isfunction(L, Idx) when is_integer(Idx) ->
    istype(L, Idx, function).


%%--------------------------------------------------------------------
-spec istable(L :: lua(), Idx :: integer()) -> {ok, true} | {ok, false}.
%%
%% @doc Test the value at the given index is a table
%%
istable(L, Idx) when is_integer(Idx) ->
    istype(L, Idx, table).


%%--------------------------------------------------------------------
-spec isnil(L :: lua(), Idx :: integer()) -> {ok, true} | {ok, false}.
%%
%% @doc Test the value at the given index is a nil
%%
isnil(L, Idx) when is_integer(Idx) ->
    istype(L, Idx, nil).


%%--------------------------------------------------------------------
-spec isboolean(L :: lua(), Idx :: integer()) -> {ok, true} | {ok, false}.
%%
%% @doc Test the value at the given index is a boolean
%%
isboolean(L, Idx) when is_integer(Idx) ->
    istype(L, Idx, boolean).


%%--------------------------------------------------------------------
-spec isthread(L :: lua(), Idx :: integer()) -> {ok, true} | {ok, false}.
%%
%% @doc Test the value at the given index is a thread
%%
isthread(L, Idx) when is_integer(Idx) ->
    istype(L, Idx, thread).


%%--------------------------------------------------------------------
-spec isnone(L :: lua(), Idx :: integer()) -> {ok, true} | {ok, false}.
%%
%% @doc Test the given index is not valid
%%
isnone(L, Idx) when is_integer(Idx) ->
    istype(L, Idx, none).


%%--------------------------------------------------------------------
-spec isnoneornil(L :: lua(), Idx :: integer()) -> {ok, true} | {ok, false}.
%%
%% @doc Test the given index is not valid or the value at this index is nil
%%
isnoneornil(L, Idx) when is_integer(Idx) ->
    case isnone(L, Idx) of
        {ok, true} -> {ok, true};
        {ok, false} -> isnil(L, Idx);
        Other -> Other
    end.


%%--------------------------------------------------------------------
-spec tonumber(L :: lua(), Idx :: integer()) -> {ok, float()} | {error, atom()}.
%%
%% @doc Convert the Lua value at the given index to the double
%%
tonumber(L, Idx) when is_integer(Idx) ->
    erlylua_nif:tonumber(L, Idx).


%%--------------------------------------------------------------------
-spec tointeger(L :: lua(), Idx :: integer()) -> {ok, integer()} | {error, atom()}.
%%
%% @doc Convert the Lua value at the given index to the integer
%%
tointeger(L, Idx) when is_integer(Idx) ->
    erlylua_nif:tointeger(L, Idx).


%%--------------------------------------------------------------------
-spec toboolean(L :: lua(), Idx :: integer()) -> {ok, true} | {ok, false}.
%%
%% @doc Convert the Lua value at the given index to 'true' or 'false' atom
%%
toboolean(L, Idx) when is_integer(Idx) ->
    erlylua_nif:toboolean(L, Idx).


%%--------------------------------------------------------------------
-spec tostring(L :: lua(), Idx :: integer()) -> {ok, list()} | {error, atom()}.
%%
%% @doc Convert the Lua value at the given index to the string
%%
tostring(L, Idx) when is_integer(Idx) ->
    case tobinstring(L, Idx) of
        {ok, Str} -> {ok, binary_to_list(Str)};
        Other -> Other
    end.


%%--------------------------------------------------------------------
-spec tobinstring(L :: lua(), Idx :: integer()) -> {ok, binary()} | {error, atom()}.
%%
%% @doc Convert the Lua value at the given index to the binary string
%%
tobinstring(L, Idx) when is_integer(Idx) ->
    erlylua_nif:tostring(L, Idx).


%%--------------------------------------------------------------------
-spec touserdata(L :: lua(), Idx :: integer()) -> {ok, binary()}.
%%
%% @doc Convert the Lua userdata at the given index to the binary
%%
touserdata(L, Idx) when is_integer(Idx) ->
    erlylua_nif:touserdata(L, Idx).


%%====================================================================
%% Comparision functions
%%====================================================================

-spec rawlen(L :: lua(), Idx :: integer()) -> {ok, integer()}.
%%
%% @doc Return the raw length of the value at the given index
%%
rawlen(L, Idx) when is_integer(Idx) ->
    erlylua_nif:rawlen(L, Idx).


%%--------------------------------------------------------------------
-spec rawequal(L :: lua(), Idx1 :: integer(), Idx2 :: integer()) -> {ok, true} | {ok, false}.
%%
%% @doc Compare two values in indices Idx1 and Idx2 without calling __eq metamethod
%%
rawequal(L, Idx1, Idx2) when is_integer(Idx1), is_integer(Idx2) ->
    erlylua_nif:rawequal(L, Idx1, Idx2).


%%--------------------------------------------------------------------
-spec compare(L :: lua(), Idx1 :: integer(), Idx2 :: integer(), eq | lt | le) -> {ok, true} | {ok, false}.
%%
%% @doc Compare two values in indices Idx1 and Idx2 for equality 'eq', for less than 'lt' or for less or equal that 'le'
%%
compare(L, Idx1, Idx2, eq) when is_integer(Idx1), is_integer(Idx2) ->
    erlylua_nif:compare(L, Idx1, Idx2, 0);

compare(L, Idx1, Idx2, lt) when is_integer(Idx1), is_integer(Idx2) ->
    erlylua_nif:compare(L, Idx1, Idx2, 1);

compare(L, Idx1, Idx2, le) when is_integer(Idx1), is_integer(Idx2) ->
    erlylua_nif:compare(L, Idx1, Idx2, 2).


%%====================================================================
%% Push functions
%%====================================================================

-spec pushnil(L :: lua()) -> ok.
%%
%% @doc Push a nil value onto the stack
%%
pushnil(L)  ->
    erlylua_nif:pushnil(L).


%%--------------------------------------------------------------------
-spec pushnumber(L :: lua(), Num :: float() | integer()) -> ok.
%%
%% @doc Push a float value onto the stack
%%
pushnumber(L, Num) when is_integer(Num) ->
    pushinteger(L, Num);

pushnumber(L, Num) when is_number(Num) ->
    erlylua_nif:pushnumber(L, Num).


%%--------------------------------------------------------------------
-spec pushinteger(L :: lua(), Num :: integer()) -> ok.
%%
%% @doc Push an integer value onto the stack
%%
pushinteger(L, Num) when is_integer(Num) ->
    erlylua_nif:pushinteger(L, Num).


%%--------------------------------------------------------------------
-spec pushstring(L :: lua(), Str :: string() | binary()) -> ok.
%%
%% @doc Push a string value onto the stack
%%
pushstring(L, Str) when is_list(Str) ->
    pushstring(L, list_to_binary(Str));

pushstring(L, Str) when is_atom(Str) ->
    pushstring(L, atom_to_binary(Str, utf8));

pushstring(L, Str) when is_binary(Str) ->
    erlylua_nif:pushstring(L, Str).


%%--------------------------------------------------------------------
-spec pushboolean(L :: lua(), B :: true | false | number()) -> ok.
%%
%% @doc Push a boolean value onto the stack
%%
pushboolean(L, true)  ->
    pushboolean(L, 1);

pushboolean(L, false)  ->
    pushboolean(L, 0);

pushboolean(L, B) when is_integer(B) ->
    erlylua_nif:pushboolean(L, B);

pushboolean(L, B) when is_number(B), (B > 0 orelse B < 0) ->
    pushboolean(L, 1);

pushboolean(L, B) when is_number(B) ->
    pushboolean(L, 0).


%%====================================================================
%% Get functions
%%====================================================================

-spec getglobal(L :: lua(), Name :: atom() | binary() | string()) -> {ok, atom()}.
%%
%% @doc Push onto the stack the value of the global name. Return type of that value
%%
getglobal(L, Name) when is_list(Name) ->
    getglobal(L, list_to_binary(Name));

getglobal(L, Name) when is_atom(Name) ->
    getglobal(L, atom_to_binary(Name, utf8));

getglobal(L, Name) when is_binary(Name) ->
    erlylua_nif:getglobal(L, Name).


%%--------------------------------------------------------------------
-spec gettable(L :: lua(), Idx :: integer()) -> {ok, atom()}.
%%
%% @doc Push onto the stack the value t[k], where t is the value at the given index
%% @doc and k is the value at the top of the stack. Return type of that value
%%
gettable(L, Idx) when is_integer(Idx) ->
    erlylua_nif:gettable(L, Idx).


%%--------------------------------------------------------------------
-spec getfield(L :: lua(), Idx :: integer(), Name :: atom() | string() | binary()) -> {ok, atom()}.
%%
%% @doc Push onto the stack the value t[Name], where t is the value at the given index.
%% @doc This function may trigger a metamethod "index" event in Lua.
%% @doc Return type of that value
%%
getfield(L, Idx, Name) when is_integer(Idx), is_atom(Name) ->
    getfield(L, Idx, atom_to_binary(Name, utf8));

getfield(L, Idx, Name) when is_integer(Idx), is_list(Name) ->
    getfield(L, Idx, list_to_binary(Name));

getfield(L, Idx, Name) when is_integer(Idx), is_binary(Name) ->
    erlylua_nif:getfield(L, Idx, Name).


%%--------------------------------------------------------------------
-spec geti(L :: lua(), Idx :: integer(), I :: integer()) -> {ok, atom()}.
%%
%% @doc Push onto the stack the value t[I], where t is the value at the given index.
%% @doc This function may trigger a metamethod "index" event in Lua.
%% @doc Return type of that value
%%
geti(L, Idx, I) when is_integer(Idx), is_integer(I) ->
    erlylua_nif:geti(L, Idx, I).


%%--------------------------------------------------------------------
-spec rawget(L :: lua(), Idx :: integer()) -> {ok, atom()}.
%%
%% @doc Similar to gettable/2 without triggering metamethods.
%%
rawget(L, Idx) when is_integer(Idx) ->
    erlylua_nif:rawget(L, Idx).


%%--------------------------------------------------------------------
-spec rawgeti(L :: lua(), Idx :: integer(), I :: integer()) -> {ok, atom()}.
%%
%% @doc Push onto the stack the value t[I], where t is the value at the given index.
%% @doc This function does not trigger a metamethod "index" event in Lua.
%% @doc Return type of that value
%%
rawgeti(L, Idx, I) when is_integer(Idx), is_integer(I) ->
    erlylua_nif:rawgeti(L, Idx, I).


%%--------------------------------------------------------------------
-spec createtable(L :: lua(), Idx :: integer(), I :: integer()) -> ok.
%%
%% @doc Create a new table and push it onto the stack.
%% @doc Parameter NArr is a hint for how many elements the table will have as a sequence
%% @doc Parameter NRec is a hint for how many other elements the table will have
%%
createtable(L, NArr, NRec) when is_integer(NArr), is_integer(NRec) ->
    erlylua_nif:createtable(L, NArr, NRec).


%%--------------------------------------------------------------------
-spec newtable(L :: lua()) -> ok.
%%
%% @doc Create a new table and push it onto the stack.
%%
newtable(L) ->
    createtable(L, 0, 0).


%%--------------------------------------------------------------------
-spec newuserdata(L :: lua(), Bin :: binary()) -> ok | {error, Reason :: term()}.
%%
%% @doc Create a new userdata from the given binary and push it onto the stack.
%%
newuserdata(L, Bin) when is_binary(Bin) ->
    erlylua_nif:newuserdata(L, Bin).


%%--------------------------------------------------------------------
-spec getmetatable(L :: lua(), Idx :: integer()) -> {ok, true} | {ok, false}.
%%
%% @doc If the value at given index has a metatable, this function pushes it onto the stack
%% @doc and returns {ok, true}. Returns {ok, false} otherwise.
%%
getmetatable(L, Idx) when is_integer(Idx) ->
    erlylua_nif:getmetatable(L, Idx).


%%--------------------------------------------------------------------
-spec getuservalue(L :: lua(), Idx :: integer()) -> {ok, atom()}.
%%
%% @doc Push onto the stack the Lua value associated with the userdata at the given index.
%% @doc Returns the type of the pushed value.
%%
getuservalue(L, Idx) when is_integer(Idx) ->
    erlylua_nif:getuservalue(L, Idx).


%%====================================================================
%% Set functions
%%====================================================================

-spec setglobal(L :: lua(), Name :: atom() | binary() | string()) -> ok.
%%
%% @doc Pop a value from the stack and sets it as the new value of global name
%%
setglobal(L, Name) when is_list(Name) ->
    setglobal(L, list_to_binary(Name));

setglobal(L, Name) when is_atom(Name) ->
    setglobal(L, atom_to_binary(Name, utf8));

setglobal(L, Name) when is_binary(Name) ->
    erlylua_nif:setglobal(L, Name).


%%--------------------------------------------------------------------
-spec settable(L :: lua(), Idx :: integer()) -> ok.
%%
%% @doc t[k] = v, where t is the value at the given index,
%% @doc v is the value at the top of the stack,
%% @doc and k is the value just below the top.
%% @doc This function pops both the key and the value from the stack.
%% @doc As in Lua, this function may trigger a metamethod for the "newindex" event
%%
settable(L, Idx) when is_integer(Idx) ->
    erlylua_nif:settable(L, Idx).


%%--------------------------------------------------------------------
-spec setfield(L :: lua(), Idx :: integer(), Name :: atom() | list() | binary()) -> ok.
%%
%% @doc t[k] = v, where t is the value at the given index,
%% @doc This function pops both the key and the value from the stack.
%% @doc As in Lua, this function may trigger a metamethod for the "newindex" event
%%
setfield(L, Idx, Name) when is_integer(Idx), is_atom(Name) ->
    setfield(L, Idx, atom_to_binary(Name, utf8));

setfield(L, Idx, Name) when is_integer(Idx), is_list(Name) ->
    setfield(L, Idx, list_to_binary(Name));

setfield(L, Idx, Name) when is_integer(Idx), is_binary(Name) ->
    erlylua_nif:setfield(L, Idx, Name).


%%--------------------------------------------------------------------
-spec seti(L :: lua(), Idx :: integer(), I :: integer()) -> ok.
%%
%% @doc t[I] = v, where t is the value at the given index and v is the value at the top of the stack
%% @doc This function pops both the key and the value from the stack.
%% @doc As in Lua, this function may trigger a metamethod for the "newindex" event
%%
seti(L, Idx, I) when is_integer(Idx), is_integer(I) ->
    erlylua_nif:seti(L, Idx, I).


%%--------------------------------------------------------------------
-spec rawset(L :: lua(), Idx :: integer()) -> ok.
%%
%% @doc Similar to settable/2 without triggering metamethods.
%%
rawset(L, Idx) when is_integer(Idx) ->
    erlylua_nif:rawset(L, Idx).


%%--------------------------------------------------------------------
-spec rawseti(L :: lua(), Idx :: integer(), I :: integer()) -> ok.
%%
%% @doc t[I] = v, where t is the table at the given index and v is the value at the top of the stack.
%% @doc This function pops the value from the stack.
%% @doc The assignment is raw, that is, it does not invoke the __newindex metamethod.
%%
rawseti(L, Idx, I) when is_integer(Idx), is_integer(I) ->
    erlylua_nif:rawseti(L, Idx, I).


%%--------------------------------------------------------------------
-spec setmetatable(L :: lua(), Idx :: integer()) -> {ok, true} | {ok, false}.
%%
%% @doc Pop a table from the stack and sets it as the new metatable
%% @doc for the value at the given index.
%%
setmetatable(L, Idx) when is_integer(Idx) ->
    erlylua_nif:setmetatable(L, Idx).


%%--------------------------------------------------------------------
-spec setuservalue(L :: lua(), Idx :: integer()) -> ok.
%%
%% @doc Pop a value from the stack and sets it as the new value
%% @doc associated to the userdata at the given index.
%%
setuservalue(L, Idx) when is_integer(Idx) ->
    erlylua_nif:setuservalue(L, Idx).


%%====================================================================
%% Call and load functions
%%====================================================================

-spec pcall(L :: lua(), NArgs :: integer()) ->
    ok | {error, Reason :: term()}.
%%
%% @doc Call a function in protected mode.
%% @doc NArgs is the number of arguments that pushed onto the stack
%%
pcall(L, NArgs) when is_integer(NArgs) ->
    pcall(L, NArgs, -1).


%%--------------------------------------------------------------------
-spec pcall(L :: lua(), NArgs :: integer(), NResults :: integer()) ->
    ok | {error, Reason :: term()}.
%%
%% @doc Call a function in protected mode.
%% @doc NResults is the number of function results will be adjusted to.
%%
pcall(L, NArgs, NRes) when is_integer(NArgs), is_integer(NRes) ->
    erlylua_nif:pcall(L, NArgs, NRes).


%%--------------------------------------------------------------------
-spec loadbuffer(L :: lua(), Chunk :: string() | binary(), Name :: string() | binary()) ->
    ok | {error, Reason :: term()}.
%%
%% @doc Load a Lua chunk with the given name without running it.
%%
loadbuffer(L, Chunk, Name) when is_binary(Chunk), is_binary(Name) ->
    erlylua_nif:loadbuffer(L, Chunk, Name);

loadbuffer(L, Chunk, Name) when is_list(Chunk) ->
    loadbuffer(L, list_to_binary(Chunk), Name);

loadbuffer(L, Chunk, Name) when is_list(Name) ->
    loadbuffer(L, Chunk, list_to_binary(Name)).


%%--------------------------------------------------------------------
-spec loadfile(L :: lua(), Filename :: string() | binary()) ->
    ok | {error, Reason :: term()}.
%%
%% @doc Load a Lua chunk from the given file without running it.
%%
loadfile(L, Filename) when is_list(Filename) ->
    loadfile(L, list_to_binary(Filename));

loadfile(L, Filename) when is_binary(Filename) ->
    erlylua_nif:loadfile(L, Filename).


%%--------------------------------------------------------------------
-spec dump(L :: lua(), Strip :: true | false) ->
    {ok, binary()} | {error, Reason :: term()}.
%%
%% @doc Dump a compiled Lua function as a binary chunk
%% @doc If parameter Strip is 'true' the binary may not include debug information
%%
dump(L, true)  ->
    erlylua_nif:dump(L, 1);

dump(L, false)  ->
    erlylua_nif:dump(L, 0).


%%--------------------------------------------------------------------
-spec dostring(L :: lua(), Chunk :: string() | binary()) ->
    ok | {error, Reason :: term()}.
%%
%% @doc Load and run the given string.
%%
dostring(L, Chunk) ->
    case loadbuffer(L, Chunk, <<"">>) of
        ok -> pcall(L, 0);
        Other -> Other
    end.


%%--------------------------------------------------------------------
-spec dofile(L :: lua(), Filename :: string() | binary()) ->
    ok | {error, Reason :: term()}.
%%
%% @doc Load and run the given file.
%%
dofile(L, Filename) ->
    case loadfile(L, Filename) of
        ok -> pcall(L, 0);
        Other -> Other
    end.


%%====================================================================
%% Garbage collection functions
%%====================================================================

-spec gc(L :: lua(), What, Data :: integer()) -> Result when
    What :: stop | restart | collect | count | countb | step | setpause | setstepmul | isrunning | 0..7 | 9,
    Result :: ok | {ok, integer()} | {ok, boolean()}.
%% @doc Stop the garbage collector
gc(L, stop, Data)  ->
    gc(L, 0, Data);
%% @doc Restart the garbage collector
gc(L, restart, Data)  ->
    gc(L, 1, Data);
%% @doc Perform a full garbage-collection cycle
gc(L, collect, Data)  ->
    gc(L, 2, Data);
%% @doc Return the current amount of memory (in Kbytes) in use by Lua
gc(L, count, Data)  ->
    gc(L, 3, Data);
%% @doc Return the remainder of dividing the current amount of bytes of memory in use by Lua by 1024
gc(L, countb, Data)  ->
    gc(L, 4, Data);
%% @doc Perform an incremental step of garbage collection
gc(L, step, Data)  ->
    gc(L, 5, Data);
%% @doc Set Data as the new value for the pause of the collector and returns the previous value of the pause
gc(L, setpause, Data) when is_integer(Data) ->
    gc(L, 6, Data);
%% @doc Sets Data as the new value for the step multiplier of the collector and returns the previous value of the step multiplier
gc(L, setstepmul, Data) when is_integer(Data) ->
    gc(L, 7, Data);
%% @doc Return a boolean that tells whether the collector is running (i.e., not stopped)
gc(L, isrunning, Data)  ->
    gc(L, 9, Data);
gc(L, What, Data) when ((What >= 0 andalso What =< 7) orelse What =:= 9), is_integer(Data) ->
    erlylua_nif:gc(L, What, Data).


%%====================================================================
%% Miscellaneous functions
%%====================================================================

-spec error(L :: lua()) -> ok.
%%
%% @doc Generate a Lua error, using the value at the top of the stack as the error object
%%
error(L)  ->
    erlylua_nif:error(L).


%%--------------------------------------------------------------------
-spec error(L :: lua(), Msg :: atom() | string() | binary()) -> ok.
%%
%% @doc Generate a Lua error, using the Msg parameter as the error object
%%
error(L, Msg)  ->
    lua:pushstring(L, Msg),
    ?MODULE:error(L).


%%--------------------------------------------------------------------
-spec error(L :: lua(), Msg :: atom() | string() | binary(), Args :: [term()]) -> ok.
%%
%% @doc Format a message using Fmt and Args parameters and generate a Lua error
%%
error(L, Fmt, Args)  ->
    Msg = io_lib:format(Fmt, Args),
    ?MODULE:error(L, Msg).


%%--------------------------------------------------------------------
-spec next(L :: lua(), Idx :: integer()) -> {ok, true} | {ok, false}.
%%
%% @doc Pop a key from the stack, and push a key–value pair from the table at the given index
%% @doc (the "next" pair after the given key).
%% @doc Return {ok, true} or {ok, false} if there are no more elements in the table
%%
next(L, Idx) when is_integer(Idx) ->
    erlylua_nif:next(L, Idx).


%%--------------------------------------------------------------------
-spec concat(L :: lua(), N :: integer()) -> ok.
%%
%% @doc Concatenate the N values at the top of the stack,
%% @doc pop them, and leave the result at the top.
%% @doc If N is 1, the result is the single value on the stack (that is, the function does nothing);
%% @doc if N is 0, the result is the empty string.
%% @doc Concatenation is performed following the usual semantics of Lua
%%
concat(L, N) when is_integer(N) ->
    erlylua_nif:concat(L, N).


%%--------------------------------------------------------------------
-spec len(L :: lua(), Idx :: integer()) -> {ok, integer()}.
%%
%% @doc Return the length of the value at the given index.
%% @doc May trigger a metamethod for the "length" event.
%% @doc The result is pushed on the stack
%%
len(L, Idx) when is_integer(Idx) ->
    erlylua_nif:len(L, Idx).


%%====================================================================
%% Useful functions
%%====================================================================

-spec dumpstack(L :: lua()) -> list().
%%
%% @doc Dump the Lua stack into the list
%%
dumpstack(L)  ->
    {ok, Top} = lua:gettop(L),
    dumpstack(L, Top, []).


%%====================================================================
%% Private functions
%%====================================================================

%%
%% @private
%% @doc Test the value at the given index for a given type
%%
istype(L, Idx, Type) ->
    case type(L, Idx) of
        {ok, Type} -> {ok, true};
        {ok, _Other} -> {ok, false};
        Other -> Other
    end.


%%--------------------------------------------------------------------
%%
%% @private
%% @doc Dump the Lua stack into the list
%%
dumpstack(_, 0, Acc) ->
    lists:reverse(Acc);

dumpstack(L, Idx, Acc) ->
    {ok, Type} = type(L, Idx),
    Acc2 = dumpstack(L, Idx, Type, Acc),
    dumpstack(L, Idx-1, Acc2).

dumpstack(_, _, none, Acc) ->
    Acc;

dumpstack(L, Idx, integer, Acc) ->
    {ok, Val} = tointeger(L, Idx),
    [Val | Acc];

dumpstack(L, Idx, number, Acc) ->
    case isinteger(L, Idx) of
        {ok, true} ->
            dumpstack(L, Idx, integer, Acc);
        {ok, false} ->
            {ok, Val} = tonumber(L, Idx),
            [Val | Acc]
    end;

dumpstack(L, Idx, boolean, Acc) ->
    {ok, Val} = toboolean(L, Idx),
    [Val | Acc];

dumpstack(L, Idx, string, Acc) ->
    {ok, Val} = tostring(L, Idx),
    [Val | Acc];

dumpstack(L, Idx, userdata, Acc) ->
    case lua:islightuserdata(L, Idx) of
        {ok, true} ->
            dumpstack(L, Idx, lightuserdata, Acc);
        {ok, false} ->
            {ok, Val} = lua:touserdata(L, Idx),
            [{userdata, Val} | Acc]
    end;

dumpstack(L, Idx, function, Acc) ->
    case lua:iscfunction(L, Idx) of
        {ok, true} ->
            [cfunction | Acc];
        {ok, false} ->
            [function | Acc]
    end;

dumpstack(_, _, Type, Acc) ->
    [Type | Acc].
