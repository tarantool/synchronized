local fiber = require('fiber')

local function synchronized_call_tail(channel, status, ...)
    channel:put(1)
    if not status then
        error((...)) -- rethrow error
    end
    return ... -- return value
end

local function synchronized_call(locks, key, fun, ...)
    if type(locks) ~= 'table' or key == nil or fun == nil then
        error('Usage: synchronized(key, fun, ...)')
    end
    local channel = locks[key]
    if channel ~= nil then
        channel:get()
    else
        channel = fiber.channel()
        locks[key] = channel
    end
    return synchronized_call_tail(channel, pcall(fun, ...))
end

local synchronized_mt = {
    __call = synchronized_call;
}

local function synchronized_new()
    return setmetatable({}, synchronized_mt)
end

return synchronized_new()
