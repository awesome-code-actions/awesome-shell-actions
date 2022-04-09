local _M = {}

function _M.lua_echo(arg)
    print("test lua" .. arg)
end

function _M.lua_len(arg)
    print(#arg)
end

return _M
