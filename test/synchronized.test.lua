#!/usr/bin/env tarantool

local fiber = require('fiber')
local synchronized = require('synchronized')

local test = require('tap').test('synchronized')
test:plan(7)

local status, reason

-- test basic locking
local function checklock(name) return synchronized[name] ~= nil end
status = synchronized('test', checklock, 'test')
test:ok(status, "lock added")
collectgarbage('collect')
test:isnil(next(synchronized), "lock removed")

-- test arguments
local function echo(a, b, c) return a + 1, b + 2, c + 3 end
local a, b, c, d = synchronized("test", echo, 1, 2, 3)
collectgarbage('collect')
test:isnil(synchronized.test, 'echo lock')
test:is(a + b + c, 12, 'echo value')

-- test errors
status, reason = pcall(synchronized, 'test', error, 'omg')
collectgarbage('collect')
test:isnil(synchronized.test, 'error lock')
test:ok(not status and reason:match('omg'), 'error value')

-- basic synchronization
local result = {}
local function work(id)
    table.insert(result, string.format("%d: enter", id))
    fiber.yield() -- do some work
    table.insert(result, string.format("%d: leave", id))
end
local join = fiber.channel(3)
local function worker(id, join)
    synchronized('key', work, id)
    join:put(true)
end
for i=1,3 do fiber.create(worker, i, join) end
for i=1,3 do join:get() end

-- check execution log
local check = true
for i=1,3 do
    check = check and result[2 * i - 1] == string.format("%d: enter", i)
    check = check and result[2 * i] == string.format("%d: leave", i)
end
test:ok(check, 'basic synchronization', result)

os.exit(test:check() == true and 0 or -1)
