# Synchronized - critical sections for Lua

The `synchronized` function ensures that one fiber does not enter
a critical section of code while another fiber is in the critical section.
If another fiber tries to enter a critical section, it will wait, block,
until the key is released.

```lua
... = synchronized(key, fun, ...)
```

 - Param `key` - a key to lock, can be arbitrary Lua object
 - Param `fun` - a function to execute in a critical section
 - Param ... - arguments to `fun`
 - Return value - the original results returned by `fun`

## Example

The example below executes `criticalsection` function as a critical section
by obtaining the mutual-exclusion lock for a `lock` object.

```lua
local fiber = require('fiber')
-- Create a new synchronized primitive
local synchronized = require('synchronized')

-- basic synchronization
local result = {}
local function criticalsection(id)
    print(string.format("%d: enter", id))
    fiber.yield() -- do some work
    print(string.format("%d: leave", id))
end
local lock = "somekey"
local function worker(id)
    synchronized(lock, criticalsection, id)
end
for i=1,3 do fiber.create(worker, i, join) end
```

Output:

    ./example.lua
    entering the event loop
    1: enter
    1: leave
    2: enter
    2: leave
    3: enter
    3: leave

## See also

There is alternative implementation of synchronization primitives [moonlibs/sync](https://github.com/moonlibs/sync#mutex-lock-with-deadlock-detection)
