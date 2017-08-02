#!/usr/bin/env tarantool

local fiber = require('fiber')
local synchronized = require('synchronized')

-- basic synchronization
local result = {}
local function work(id)
    print(string.format("%d: enter", id))
    fiber.yield() -- do some work
    print(string.format("%d: leave", id))
end
local lock = "somekey"
local function worker(id)
    synchronized(lock, work, id)
end
for i=1,3 do fiber.create(worker, i, join) end
