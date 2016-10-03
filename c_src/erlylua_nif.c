#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <erl_nif.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>


typedef struct _res_t {
    lua_State *lua;
    lua_State *L;
} res_t;

typedef struct _writer_t {
    void *bin;
    size_t cur;
    size_t size;
} writer_t;


static ErlNifResourceType *LUA_RESOURCE;
static const char *RESOURCE_ERROR = "First argument is not a Lua VM instance";
static const char *LUA_ERROR = "Lua VM is not initialized";

void luaopen_erlang(lua_State *L);

#define ATOM(name) (enif_make_atom(env, name))
#define ATOM_OK ATOM("ok")
#define ATOM_ERROR ATOM("error")
#define ATOM_TRUE ATOM("true")
#define ATOM_FALSE ATOM("false")
#define ATOM_NULL ATOM("null")
#define ATOM_YIELD ATOM("null")


#define GET_RESOURCE(env, args, argv) res_t *res; \
    if(!args || !enif_get_resource(env, argv[0], LUA_RESOURCE, (void**)&res)) \
        return nif_niferror(env, RESOURCE_ERROR); \
    if(!res->lua || !res->L) return nif_niferror(env, LUA_ERROR);


static ERL_NIF_TERM
nif_niferror(ErlNifEnv *env, const char *format,...) {
    va_list aptr;
    size_t size;
    char *buf;
    ERL_NIF_TERM term;
    
    va_start(aptr, format);
    size = vsnprintf(NULL, 0, format, aptr) + 1;
    if((buf = malloc(size))) {
        vsnprintf((char*)buf, size, format, aptr); buf[size] = '0';
        term = enif_make_string(env, buf, ERL_NIF_LATIN1);
        free(buf);
    } else {
        term = ATOM_NULL;
    }
    va_end(aptr);
    return enif_make_tuple2(env, ATOM_ERROR, term);
}

static char* 
decode_string(ErlNifEnv *env, ERL_NIF_TERM term, size_t *size) {
    ErlNifBinary bin;
    if(enif_inspect_binary(env, term, &bin)) {
        char *str = malloc(bin.size+1);
        if(str) {
            memcpy((void*)str, bin.data, bin.size);
            str[bin.size] = '\0';
            *size = bin.size;
            return str;
        }
    }
    return 0;
}

static int
nif_load(ErlNifEnv *env, void **priv_data, ERL_NIF_TERM load_info) {
    LUA_RESOURCE = enif_open_resource_type(env, NULL, "erlylua_nif", NULL, ERL_NIF_RT_CREATE, NULL);
    return 0;
}

static ERL_NIF_TERM 
nif_newstate(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    lua_State *L = luaL_newstate();
    if(!L) {
        return nif_niferror(env, "Could not initialize the Lua VM");
    } else {
        luaL_openlibs(L);
        luaopen_erlang(L);
        res_t *res = (res_t*)enif_alloc_resource(LUA_RESOURCE, sizeof(res_t));
        res->lua = L;
        res->L = lua_newthread(L);
        return enif_make_resource(env, res);
    }
}

static ERL_NIF_TERM 
nif_close(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    lua_close(res->lua);
    res->lua = res->L = 0;
    enif_release_resource(res);
    return ATOM_OK;
}

static ERL_NIF_TERM 
nif_version(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    const lua_Number *version = lua_version(res->L);
    return enif_make_tuple2(env, ATOM_OK, enif_make_double(env, *version));
}

static ERL_NIF_TERM 
nif_absindex(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int idx;
    enif_get_int(env, argv[1], &idx);
    return enif_make_tuple2(env, ATOM_OK, enif_make_int(env, lua_absindex(res->L, idx)));
}

static ERL_NIF_TERM 
nif_gettop(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    return enif_make_tuple2(env, ATOM_OK, enif_make_int(env, lua_gettop(res->L)));
}

static ERL_NIF_TERM 
nif_settop(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int idx;
    enif_get_int(env, argv[1], &idx);
    lua_settop(res->L, idx);
    return ATOM_OK;
}

static ERL_NIF_TERM 
nif_pushvalue(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int idx;
    enif_get_int(env, argv[1], &idx);
    lua_pushvalue(res->L, idx);
    return ATOM_OK;
}

static ERL_NIF_TERM 
nif_rotate(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int idx, n;
    enif_get_int(env, argv[1], &idx);
    enif_get_int(env, argv[2], &n);
    lua_rotate(res->L, idx, n);
    return ATOM_OK;
}

static ERL_NIF_TERM 
nif_copy(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int from, to;
    enif_get_int(env, argv[1], &from);
    enif_get_int(env, argv[2], &to);
    lua_copy(res->L, from, to);
    return ATOM_OK;
}

static ERL_NIF_TERM 
nif_checkstack(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int n;
    enif_get_int(env, argv[1], &n);
    n = lua_checkstack(res->L, n);
    return enif_make_tuple2(env, ATOM_OK, n ? ATOM_TRUE : ATOM_FALSE);
}

static ERL_NIF_TERM 
nif_isnumber(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int idx;
    enif_get_int(env, argv[1], &idx);
    idx = lua_isnumber(res->L, idx);
    return enif_make_tuple2(env, ATOM_OK, idx ? ATOM_TRUE : ATOM_FALSE);
}

static ERL_NIF_TERM 
nif_isinteger(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int idx;
    enif_get_int(env, argv[1], &idx);
    idx = lua_isinteger(res->L, idx);
    return enif_make_tuple2(env, ATOM_OK, idx ? ATOM_TRUE : ATOM_FALSE);
}

static ERL_NIF_TERM 
nif_isstring(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int idx;
    enif_get_int(env, argv[1], &idx);
    idx = lua_isstring(res->L, idx);
    return enif_make_tuple2(env, ATOM_OK, idx ? ATOM_TRUE : ATOM_FALSE);
}

static ERL_NIF_TERM 
nif_iscfunction(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int idx;
    enif_get_int(env, argv[1], &idx);
    idx = lua_iscfunction(res->L, idx);
    return enif_make_tuple2(env, ATOM_OK, idx ? ATOM_TRUE : ATOM_FALSE);
}

static ERL_NIF_TERM 
nif_isuserdata(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int idx;
    enif_get_int(env, argv[1], &idx);
    idx = lua_isuserdata(res->L, idx);
    return enif_make_tuple2(env, ATOM_OK, idx ? ATOM_TRUE : ATOM_FALSE);
}

static ERL_NIF_TERM 
nif_islightuserdata(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int idx;
    enif_get_int(env, argv[1], &idx);
    idx = lua_islightuserdata(res->L, idx);
    return enif_make_tuple2(env, ATOM_OK, idx ? ATOM_TRUE : ATOM_FALSE);
}

static const char* typename(lua_State *L, int type) {
    return type == LUA_TNONE ? "none" : lua_typename(L, type);
}

static ERL_NIF_TERM 
ok_type_tuple(ErlNifEnv *env, lua_State *L, int type) {
    return enif_make_tuple2(env, ATOM_OK, ATOM(typename(L, type)));
}

static ERL_NIF_TERM 
nif_type(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int idx;
    enif_get_int(env, argv[1], &idx);
    return ok_type_tuple(env, res->L, lua_type(res->L, idx));
}

static ERL_NIF_TERM 
nif_tonumber(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int idx, isnum;
    lua_Number num;
    enif_get_int(env, argv[1], &idx);
    num = lua_tonumberx(res->L, idx, &isnum);
    if(isnum) {
        return enif_make_tuple2(env, ATOM_OK, enif_make_double(env, num));
    } else {
        return nif_niferror(env, typename(res->L, lua_type(res->L, idx)));
    }
}

static ERL_NIF_TERM 
nif_tointeger(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int idx, isnum;
    lua_Integer num;
    enif_get_int(env, argv[1], &idx);
    num = lua_tointegerx(res->L, idx, &isnum);
    if(isnum) {
        return enif_make_tuple2(env, ATOM_OK, enif_make_int(env, num));
    } else {
        return nif_niferror(env, typename(res->L, lua_type(res->L, idx)));
    }
}

static ERL_NIF_TERM 
nif_toboolean(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int idx, ret;
    enif_get_int(env, argv[1], &idx);
    ret = lua_toboolean(res->L, idx);
    return enif_make_tuple2(env, ATOM_OK, ret ? ATOM_TRUE : ATOM_FALSE);
}

static ERL_NIF_TERM 
nif_tostring(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int idx;
    size_t size;
    ErlNifBinary bin;
    enif_get_int(env, argv[1], &idx);
    const char *str = lua_tolstring(res->L, idx, &size);
    if(str && enif_alloc_binary(size, &bin)) {
        //bin.size = size;
        memcpy((void*)bin.data, str, size);
        return enif_make_tuple2(env, ATOM_OK, enif_make_binary(env, &bin));
    } else {
        return nif_niferror(env, typename(res->L, lua_type(res->L, idx)));
    }
}

static ERL_NIF_TERM 
nif_touserdata(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int idx;
    enif_get_int(env, argv[1], &idx);
    if(lua_isuserdata(res->L, idx)) {
        ErlNifBinary bin;
        size_t size = lua_rawlen(res->L, idx);
        if(size) {
            void *userdata = lua_touserdata(res->L, idx);
            if(userdata && enif_alloc_binary(size, &bin)) {
                memcpy(bin.data, userdata, size);
                return enif_make_tuple2(env, ATOM_OK, enif_make_binary(env, &bin));
            }
        }
        return enif_make_tuple2(env, ATOM_ERROR, ATOM_NULL);
    }
    return nif_niferror(env, typename(res->L, lua_type(res->L, idx)));
}

static ERL_NIF_TERM 
nif_rawlen(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int idx;
    enif_get_int(env, argv[1], &idx);
    return enif_make_tuple2(env, ATOM_OK, enif_make_int(env, lua_rawlen(res->L, idx)));
}

static ERL_NIF_TERM 
nif_rawequal(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int idx1, idx2;
    enif_get_int(env, argv[1], &idx1);
    enif_get_int(env, argv[2], &idx2);
    return enif_make_tuple2(env, ATOM_OK, lua_rawequal(res->L, idx1, idx2) ? ATOM_TRUE : ATOM_FALSE);
}

static ERL_NIF_TERM 
nif_compare(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int idx1, idx2, op;
    enif_get_int(env, argv[1], &idx1);
    enif_get_int(env, argv[2], &idx2);
    enif_get_int(env, argv[3], &op);
    return enif_make_tuple2(env, ATOM_OK, lua_compare(res->L, idx1, idx2, op) ? ATOM_TRUE : ATOM_FALSE);
}

static ERL_NIF_TERM 
nif_pushnil(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    lua_pushnil(res->L);
    return ATOM_OK;
}

static ERL_NIF_TERM 
nif_pushinteger(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int num;
    enif_get_int(env, argv[1], &num);
    lua_pushinteger(res->L, num);
    return ATOM_OK;
}

static ERL_NIF_TERM 
nif_pushnumber(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    double num;
    enif_get_double(env, argv[1], &num);
    lua_pushnumber(res->L, num);
    return ATOM_OK;
}

static ERL_NIF_TERM 
nif_pushstring(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    size_t size;
    char *str = decode_string(env, argv[1], &size);
    if(str) {
        lua_pushlstring(res->L, str, size);
        free(str);
        return ATOM_OK;
    } else {
        return enif_make_tuple2(env, ATOM_ERROR, ATOM_NULL);
    }
}

static ERL_NIF_TERM 
nif_pushboolean(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int num;
    enif_get_int(env, argv[1], &num);
    lua_pushboolean(res->L, num);
    return ATOM_OK;
}

static ERL_NIF_TERM 
nif_getglobal(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    size_t size;
    char *str = decode_string(env, argv[1], &size);
    if(str) {
        int type = lua_getglobal(res->L, str);
        free(str);
        return ok_type_tuple(env, res->L, type);
    } else {
        return enif_make_tuple2(env, ATOM_ERROR, ATOM_NULL);
    }
}

static ERL_NIF_TERM 
nif_gettable(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int idx;
    enif_get_int(env, argv[1], &idx);
    if(lua_istable(res->L, idx)) {
        int type = lua_gettable(res->L, idx);
        return ok_type_tuple(env, res->L, type);
    } else {
        return nif_niferror(env, typename(res->L, lua_type(res->L, idx)));
    }
}

static ERL_NIF_TERM 
nif_getfield(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int idx;
    enif_get_int(env, argv[1], &idx);
    if(lua_istable(res->L, idx)) {
        size_t size;
        char *str = decode_string(env, argv[2], &size);
        if(str) {
            int type = lua_getfield(res->L, idx, str);
            free(str);
            return ok_type_tuple(env, res->L, type);
        } else {
            return nif_niferror(env, "Could not get binary from the third argument");
        }
    } else {
        return nif_niferror(env, typename(res->L, lua_type(res->L, idx)));
    }
}

static ERL_NIF_TERM 
nif_geti(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int idx, i;
    enif_get_int(env, argv[1], &idx);
    if(lua_istable(res->L, idx)) {
        enif_get_int(env, argv[2], &i);
        int type = lua_geti(res->L, idx, i);
        return ok_type_tuple(env, res->L, type);
    } else {
        return nif_niferror(env, typename(res->L, lua_type(res->L, idx)));
    }
}

static ERL_NIF_TERM 
nif_rawget(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int idx;
    enif_get_int(env, argv[1], &idx);
    if(lua_istable(res->L, idx)) {
        int type = lua_rawget(res->L, idx);
        return ok_type_tuple(env, res->L, type);
    } else {
        return nif_niferror(env, typename(res->L, lua_type(res->L, idx)));
    }
}

static ERL_NIF_TERM 
nif_rawgeti(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int idx, i;
    enif_get_int(env, argv[1], &idx);
    if(lua_istable(res->L, idx)) {
        enif_get_int(env, argv[2], &i);
        int type = lua_rawgeti(res->L, idx, i);
        return ok_type_tuple(env, res->L, type);
    } else {
        return nif_niferror(env, typename(res->L, lua_type(res->L, idx)));
    }
}

static ERL_NIF_TERM 
nif_createtable(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int narr, nrec;
    enif_get_int(env, argv[1], &narr);
    enif_get_int(env, argv[2], &nrec);
    lua_createtable(res->L, narr, nrec);
    return ATOM_OK;
}

static ERL_NIF_TERM 
nif_newuserdata(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    ErlNifBinary bin;
    if(enif_inspect_binary(env, argv[1], &bin)) {
        void *p = lua_newuserdata(res->L, bin.size);
        if(p) {
            memcpy(p, bin.data, bin.size);
            return ATOM_OK;
        } else {
            return nif_niferror(env, "Not enough memory");
        }
        //enif_release_binary(&bin);
    } else {
        return nif_niferror(env, "Could not get binary");
    }
}

static ERL_NIF_TERM 
nif_getmetatable(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int idx, ret;
    enif_get_int(env, argv[1], &idx);
    ret = lua_getmetatable(res->L, idx);
    return enif_make_tuple2(env, ATOM_OK, ret ? ATOM_TRUE : ATOM_FALSE);
}

static ERL_NIF_TERM 
nif_getuservalue(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int idx;
    enif_get_int(env, argv[1], &idx);
    if(lua_isuserdata(res->L, idx)) {
        int type = lua_getuservalue(res->L, idx);
        return ok_type_tuple(env, res->L, type);
    } else {
        return nif_niferror(env, typename(res->L, lua_type(res->L, idx)));
    }
}

static ERL_NIF_TERM 
nif_setglobal(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    size_t size;
    char *str = decode_string(env, argv[1], &size);
    if(str) {
        lua_setglobal(res->L, str);
        free(str);
        return ATOM_OK;
    } else {
        return enif_make_tuple2(env, ATOM_ERROR, ATOM_NULL);
    }
}

static ERL_NIF_TERM 
nif_settable(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int idx;
    enif_get_int(env, argv[1], &idx);
    if(lua_istable(res->L, idx)) {
        lua_settable(res->L, idx);
        return ATOM_OK;
    } else {
        return nif_niferror(env, typename(res->L, lua_type(res->L, idx)));
    }
}

static ERL_NIF_TERM 
nif_setfield(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int idx;
    enif_get_int(env, argv[1], &idx);
    if(lua_istable(res->L, idx)) {
        size_t size;
        char *str = decode_string(env, argv[2], &size);
        if(str) {
            lua_setfield(res->L, idx, str);
            free(str);
            return ATOM_OK;
        } else {
            return enif_make_tuple2(env, ATOM_ERROR, ATOM_NULL);
        }
    } else {
        return nif_niferror(env, typename(res->L, lua_type(res->L, idx)));
    }
}

static ERL_NIF_TERM 
nif_seti(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int idx, i;
    enif_get_int(env, argv[1], &idx);
    if(lua_istable(res->L, idx)) {
        enif_get_int(env, argv[2], &i);
        lua_seti(res->L, idx, i);
        return ATOM_OK;
    } else {
        return nif_niferror(env, typename(res->L, lua_type(res->L, idx)));
    }
}

static ERL_NIF_TERM 
nif_rawset(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int idx;
    enif_get_int(env, argv[1], &idx);
    if(lua_istable(res->L, idx)) {
        lua_rawset(res->L, idx);
        return ATOM_OK;
    } else {
        return nif_niferror(env, typename(res->L, lua_type(res->L, idx)));
    }
}

static ERL_NIF_TERM 
nif_rawseti(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int idx, i;
    enif_get_int(env, argv[1], &idx);
    if(lua_istable(res->L, idx)) {
        enif_get_int(env, argv[2], &i);
        lua_rawseti(res->L, idx, i);
        return ATOM_OK;
    } else {
        return nif_niferror(env, typename(res->L, lua_type(res->L, idx)));
    }
}

static ERL_NIF_TERM 
nif_setmetatable(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int idx, ret;
    enif_get_int(env, argv[1], &idx);
    ret = lua_setmetatable(res->L, idx);
    return enif_make_tuple2(env, ATOM_OK, ret ? ATOM_TRUE : ATOM_FALSE);
}

static ERL_NIF_TERM 
nif_setuservalue(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int idx;
    enif_get_int(env, argv[1], &idx);
    if(lua_isuserdata(res->L, idx)) {
        lua_setuservalue(res->L, idx);
        return ATOM_OK;
    } else {
        return nif_niferror(env, typename(res->L, lua_type(res->L, idx)));
    }
}

static ERL_NIF_TERM 
nif_pcall(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    ERL_NIF_TERM nif_ret;
    int nargs, nres, ret;
    enif_get_int(env, argv[1], &nargs);
    enif_get_int(env, argv[2], &nres);
    //ret = lua_resume(res->L, 0, nargs);
    ret = lua_pcall(res->L, nargs, nres, 0);
    if(ret == LUA_OK) {
        nif_ret = ATOM_OK;
    } else if(LUA_YIELD) {
        nif_ret = ATOM_YIELD;
    } else if(lua_isstring(res->L, -1)) {
        nif_ret = nif_niferror(env, lua_tostring(res->L, -1));
        lua_pop(res->L, 1);
    } else {
        nif_ret = enif_make_tuple2(env, ATOM_ERROR, enif_make_int(env, ret));
    }
    return nif_ret;
}

static ERL_NIF_TERM 
nif_loadbuffer(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    size_t size1, size2;
    ERL_NIF_TERM nif_ret;
    char *chunk = decode_string(env, argv[1], &size1);
    char *name = decode_string(env, argv[2], &size2);
    if(chunk && name) {
        int ret = luaL_loadbuffer(res->L, chunk, size1, size2 > 0 ? name : NULL);
        if(ret == LUA_OK) {
            nif_ret = ATOM_OK;
        } else if(lua_isstring(res->L, -1)) {
            nif_ret = nif_niferror(env, lua_tostring(res->L, -1));
            lua_pop(res->L, 1);
        } else {
            nif_ret = enif_make_tuple2(env, ATOM_ERROR, enif_make_int(env, ret));
        }
    } else {
        nif_ret = enif_make_tuple2(env, ATOM_ERROR, ATOM_NULL);
    }
    if(chunk) free(chunk);
    if(name) free(name);
    return nif_ret;
}

static ERL_NIF_TERM 
nif_loadfile(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    size_t size;
    ERL_NIF_TERM nif_ret;
    char *filename = decode_string(env, argv[1], &size);
    if(filename) {
        int ret = luaL_loadfile(res->L, filename);
        free(filename);
        if(ret == LUA_OK) {
            nif_ret = ATOM_OK;
        } else if(lua_isstring(res->L, -1)) {
            nif_ret = nif_niferror(env, lua_tostring(res->L, -1));
            lua_pop(res->L, 1);
        } else {
            nif_ret = enif_make_tuple2(env, ATOM_ERROR, enif_make_int(env, ret));
        }
    } else {
        nif_ret = enif_make_tuple2(env, ATOM_ERROR, ATOM_NULL);
    }
    return nif_ret;
}

static int lua_writer(lua_State *L, const void *p, size_t size, void *ud) {
    writer_t *w = (writer_t*)ud;
    int block_size = 512, avail;
    if(!w->bin) {
        w->size = size > block_size ? size : block_size;
        w->bin = malloc(w->size);
        if(!w->bin) return 1;
    } else {
        avail = w->size - w->cur;
        if(size > avail) {
            w->size += size-avail > block_size ? size-avail : block_size;
            w->bin = realloc(w->bin, w->size);
            if(!w->bin) return 1;
        }
    }
    memcpy((void*)(w->bin + w->cur), p, size);
    w->cur += size;
    return 0;
}

static ERL_NIF_TERM 
nif_dump(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    writer_t wrt = { NULL, 0, 0 };
    ERL_NIF_TERM nif_ret;
    ErlNifBinary bin;
    int strip;
    enif_get_int(env, argv[1], &strip);
    int ret = lua_dump(res->L, &lua_writer, &wrt, strip);
    if(!ret) {
        if(enif_alloc_binary(wrt.cur, &bin)) {
            memcpy(bin.data, wrt.bin, wrt.cur);
            nif_ret = enif_make_tuple2(env, ATOM_OK, enif_make_binary(env, &bin));
        } else {
            nif_ret = enif_make_tuple2(env, ATOM_ERROR, ATOM_NULL);
        }
    } else if(lua_isstring(res->L, -1)) {
        nif_ret = nif_niferror(env, lua_tostring(res->L, -1));
        lua_pop(res->L, 1);
    } else {
        nif_ret = enif_make_tuple2(env, ATOM_ERROR, enif_make_int(env, ret));
    }
    if(wrt.bin) free(wrt.bin);
    return nif_ret;
}

static ERL_NIF_TERM 
nif_gc(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int what, data, ret;
    enif_get_int(env, argv[1], &what);
    enif_get_int(env, argv[2], &data);
    ret = lua_gc(res->L, what, data);
    switch(what) {
        case LUA_GCSTOP:
        case LUA_GCRESTART:
        case LUA_GCCOLLECT:
        case LUA_GCSTEP:
            return ATOM_OK;
            
        case LUA_GCISRUNNING:
            return enif_make_tuple2(env, ATOM_OK, ret ? ATOM_TRUE : ATOM_FALSE);
            
        default:    
            return enif_make_tuple2(env, ATOM_OK, enif_make_int(env, ret));
    }
}

static ERL_NIF_TERM 
nif_error(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    lua_error(res->L);
    return ATOM_OK;
}

static ERL_NIF_TERM 
nif_next(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int idx, ret;
    enif_get_int(env, argv[1], &idx);
    ret = lua_next(res->L, idx);
    return enif_make_tuple2(env, ATOM_OK, ret ? ATOM_TRUE : ATOM_FALSE);
}

static ERL_NIF_TERM 
nif_concat(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int n;
    enif_get_int(env, argv[1], &n);
    lua_concat(res->L, n);
    return ATOM_OK;
}

static ERL_NIF_TERM 
nif_len(ErlNifEnv *env, int args, const ERL_NIF_TERM argv[]) {
    GET_RESOURCE(env, args, argv);
    int idx;
    enif_get_int(env, argv[1], &idx);
    lua_len(res->L, idx);
    return ATOM_OK;
}


static ErlNifFunc nif_funcs[] = {
    {"newstate",        0, nif_newstate},
    {"close",           1, nif_close},
    {"version",         1, nif_version},
    {"absindex",        2, nif_absindex},
    {"gettop",          1, nif_gettop},
    {"settop",          2, nif_settop},
    {"pushvalue",       2, nif_pushvalue},
    {"rotate",          3, nif_rotate},
    {"copy",            3, nif_copy},
    {"checkstack",      2, nif_checkstack},
    {"isnumber",        2, nif_isnumber},
    {"isinteger",       2, nif_isinteger},
    {"isstring",        2, nif_isstring},
    {"iscfunction",     2, nif_iscfunction},
    {"isuserdata",      2, nif_isuserdata},
    {"islightuserdata", 2, nif_islightuserdata},
    {"type",            2, nif_type},
    {"tonumber",        2, nif_tonumber},
    {"tointeger",       2, nif_tointeger},
    {"toboolean",       2, nif_toboolean},
    {"tostring",        2, nif_tostring},
    {"touserdata",      2, nif_touserdata},
    {"rawlen",          2, nif_rawlen},
    {"rawequal",        3, nif_rawequal},
    {"compare",         4, nif_compare},
    {"pushnil",         1, nif_pushnil},
    {"pushinteger",     2, nif_pushinteger},
    {"pushnumber",      2, nif_pushnumber},
    {"pushstring",      2, nif_pushstring},
    {"pushboolean",     2, nif_pushboolean},
    {"getglobal",       2, nif_getglobal},
    {"gettable",        2, nif_gettable},
    {"getfield",        3, nif_getfield},
    {"geti",            3, nif_geti},
    {"rawget",          2, nif_rawget},
    {"rawgeti",         3, nif_rawgeti},
    {"createtable",     3, nif_createtable},
    {"newuserdata",     2, nif_newuserdata},
    {"getmetatable",    2, nif_getmetatable},
    {"getuservalue",    2, nif_getuservalue},
    {"setglobal",       2, nif_setglobal},
    {"settable",        2, nif_settable},
    {"setfield",        3, nif_setfield},
    {"seti",            3, nif_seti},
    {"rawset",          2, nif_rawset},
    {"rawseti",         3, nif_rawseti},
    {"setmetatable",    2, nif_setmetatable},
    {"setuservalue",    2, nif_setuservalue},
    {"pcall",           3, nif_pcall},
    {"loadbuffer",      3, nif_loadbuffer},
    {"loadfile",        2, nif_loadfile},
    {"dump",            2, nif_dump},
    {"gc",              3, nif_gc},
    {"error",           1, nif_error},
    {"next",            2, nif_next},
    {"concat",          2, nif_concat},
    {"len",             2, nif_len},
};

ERL_NIF_INIT(erlylua_nif, nif_funcs, nif_load, NULL, NULL, NULL);



