local fiber = require('fiber')

local function synchronized_call_tail(cond, status, ...)
    cond:signal()
    if not status then
        error((...)) -- rethrow error
    end
    return ... -- return value
end

local function synchronized_call(locks, key, fun, ...)
    if type(locks) ~= 'table' or key == nil or fun == nil then
        error('Usage: synchronized(key, fun, ...)')
    end
    local cond = locks[key]
    if cond ~= nil then
        cond:wait()
    else
        cond = fiber.cond()
        locks[key] = cond
    end
    return synchronized_call_tail(cond, pcall(fun, ...))
end

local synchronized_mt = {
    __call = synchronized_call;
    __mode = 'v'; -- weak table by value
}

local function synchronized_new()
    return setmetatable({}, synchronized_mt)
end

return synchronized_new()
