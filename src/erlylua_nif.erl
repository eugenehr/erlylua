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
%% @doc A NIFs stub module

-module(erlylua_nif).
-author("Eugene Khrustalev <eugene.khrustalev@gmail.com>").

-compile([export_all]).
-on_load(load_nif/0).


load_nif() ->
    Dir = code:priv_dir(erlylua),
    Nif = filename:join(Dir, "erlylua_nif"),
    erlang:load_nif(Nif, 0).


newstate() -> erlang:nif_error(nif_not_loaded).
close(_L) -> erlang:nif_error(nif_not_loaded).
version(_L) -> erlang:nif_error(nif_not_loaded).
absindex(_L, _Idx) -> erlang:nif_error(nif_not_loaded).
gettop(_L) -> erlang:nif_error(nif_not_loaded).
settop(_L, _Idx) -> erlang:nif_error(nif_not_loaded).
pushvalue(_L, _Idx) -> erlang:nif_error(nif_not_loaded).
rotate(_L, _Idx, _N) -> erlang:nif_error(nif_not_loaded).
copy(_L, _From, _N) -> erlang:nif_error(nif_not_loaded).
checkstack(_L, _N) -> erlang:nif_error(nif_not_loaded).
isnumber(_L, _Idx) -> erlang:nif_error(nif_not_loaded).
isinteger(_L, _Idx) -> erlang:nif_error(nif_not_loaded).
isstring(_L, _Idx) -> erlang:nif_error(nif_not_loaded).
iscfunction(_L, _Idx) -> erlang:nif_error(nif_not_loaded).
isuserdata(_L, _Idx) -> erlang:nif_error(nif_not_loaded).
islightuserdata(_L, _Idx) -> erlang:nif_error(nif_not_loaded).
type(_L, _Idx) -> erlang:nif_error(nif_not_loaded).
tonumber(_L, _Idx) -> erlang:nif_error(nif_not_loaded).
tointeger(_L, _Idx) -> erlang:nif_error(nif_not_loaded).
toboolean(_L, _Idx) -> erlang:nif_error(nif_not_loaded).
tostring(_L, _Idx) -> erlang:nif_error(nif_not_loaded).
touserdata(_L, _Idx) -> erlang:nif_error(nif_not_loaded).
rawlen(_L, _Idx) -> erlang:nif_error(nif_not_loaded).
rawequal(_L, _Idx1, _Idx2) -> erlang:nif_error(nif_not_loaded).
compare(_L, _Idx1, _Idx2, _Op) -> erlang:nif_error(nif_not_loaded).
pushnil(_L) -> erlang:nif_error(nif_not_loaded).
pushinteger(_L, _Num) -> erlang:nif_error(nif_not_loaded).
pushnumber(_L, _Num) -> erlang:nif_error(nif_not_loaded).
pushstring(_L, _Str) -> erlang:nif_error(nif_not_loaded).
pushboolean(_L, _Num) -> erlang:nif_error(nif_not_loaded).
getglobal(_L, _Name) -> erlang:nif_error(nif_not_loaded).
gettable(_L, _Idx) -> erlang:nif_error(nif_not_loaded).
getfield(_L, _Idx, _Name) -> erlang:nif_error(nif_not_loaded).
geti(_L, _Idx, _I) -> erlang:nif_error(nif_not_loaded).
rawget(_L, _Idx) -> erlang:nif_error(nif_not_loaded).
rawgeti(_L, _Idx, _I) -> erlang:nif_error(nif_not_loaded).
createtable(_L, _NArr, _NRec) -> erlang:nif_error(nif_not_loaded).
newuserdata(_L, _Bin) -> erlang:nif_error(nif_not_loaded).
getmetatable(_L, _Idx) -> erlang:nif_error(nif_not_loaded).
getuservalue(_L, _Idx) -> erlang:nif_error(nif_not_loaded).
setglobal(_L, _Name) -> erlang:nif_error(nif_not_loaded).
settable(_L, _Idx) -> erlang:nif_error(nif_not_loaded).
setfield(_L, _Idx, _Name) -> erlang:nif_error(nif_not_loaded).
seti(_L, _Idx, _I) -> erlang:nif_error(nif_not_loaded).
rawset(_L, _Idx) -> erlang:nif_error(nif_not_loaded).
rawseti(_L, _Idx, _I) -> erlang:nif_error(nif_not_loaded).
setmetatable(_L, _Idx) -> erlang:nif_error(nif_not_loaded).
setuservalue(_L, _Idx) -> erlang:nif_error(nif_not_loaded).
pcall(_L, _NArgs, _NRes) -> erlang:nif_error(nif_not_loaded).
loadbuffer(_L, _Chunk, _Name) -> erlang:nif_error(nif_not_loaded).
loadfile(_L, _Filename) -> erlang:nif_error(nif_not_loaded).
dump(_L, _Strip) -> erlang:nif_error(nif_not_loaded).
gc(_L, _What, _Data) -> erlang:nif_error(nif_not_loaded).
error(_L) -> erlang:nif_error(nif_not_loaded).
next(_L, _Idx) -> erlang:nif_error(nif_not_loaded).
concat(_L, _N) -> erlang:nif_error(nif_not_loaded).
len(_L, _Idx) -> erlang:nif_error(nif_not_loaded).
