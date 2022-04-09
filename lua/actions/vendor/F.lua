local F = {}
local inspect = require "actions.vendor.inspect"

local load = load
-- print(_VERSION)
if _VERSION == "Lua 5.1" then
    load = function(code, name, _, env)
        local fn, err = loadstring(code, name)
        if fn then
            setfenv(fn, env)
            return fn
        end
        return nil, err
    end
end

if _VERSION == "Lua 5.3" then
    if not setfenv then -- Lua 5.2+
        -- based on http://lua-users.org/lists/lua-l/2010-06/msg00314.html
        -- this assumes f is a function
        local function findenv(f)
            local level = 1
            repeat
                local name, value = debug.getupvalue(f, level)
                if name == '_ENV' then
                    return level, value
                end
                level = level + 1
            until name == nil
            return nil
        end
        getfenv = function(f)
            return (select(2, findenv(f)) or _G)
        end
        setfenv = function(f, t)
            local level = findenv(f)
            if level then
                debug.setupvalue(f, level, t)
            end
            return f
        end
    end

    local oldload = load
    load = function(code, name, _, env)
        local fn, err = oldload(code, name)
        if fn then
            setfenv(fn, env)
            return fn
        end
        return nil, err
    end
end

local function scan_using(scanner, arg, searched)
    local i = 1
    repeat
        local name, value = scanner(arg, i)
        if name == searched then
            return true, value
        end
        i = i + 1
    until name == nil
    return false
end

local function snd(_, b)
    return b
end
function string.starts_with(str, start)
    return str:sub(1, #start) == start
end

function string.ends_with(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end

local function format(_, str)
    local outer_env = _ENV and
                          (snd(scan_using(debug.getlocal, 3, "_ENV")) or
                              snd(scan_using(debug.getupvalue, debug.getinfo(2, "f").func, "_ENV")) or _ENV) or
                          getfenv(2)
    return (str:gsub("%b{}", function(block)
        if block:starts_with("{{") and block:ends_with("}}") then
            local ret = block:sub(2, #block - 1)
            return ret
        end
        local code, fmt = block:match("{(.*):(%%.*)}")
        code = code or block:match("{(.*)}")
        local exp_env = {}
        setmetatable(exp_env, {
            __index = function(_, k)
                local level = 6
                while true do
                    local funcInfo = debug.getinfo(level, "flnS")
                    if not funcInfo then
                        break
                    end
                    local ok, value = scan_using(debug.getupvalue, funcInfo.func, k)
                    -- print("up", ok, value, k, level)
                    if ok then
                        return value
                    end
                    ok, value = scan_using(debug.getlocal, level + 1, k)
                    -- print("local", ok, value, k, level)
                    if ok then
                        return value
                    end
                    level = level + 1
                end
                return rawget(outer_env, k)
            end
        })
        local fn, err = load("return " .. code, "expression `" .. code .. "`", "t", exp_env)
        if fn then
            return fmt and string.format(fmt, fn()) or tostring(fn())
        else
            error(err, 0)
        end
    end))
end

setmetatable(F, {
    __call = format
})

return F
