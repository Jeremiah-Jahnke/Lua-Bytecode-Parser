-- Wrote this in like 5 minutes just minor bitwise operations.
local bit = {}
bit.__index = bit

function bit.new()
    local self = setmetatable({}, bit)

    return self
end

function bit:lshift(a, b)
    return a * 2 ^ b
end

function bit:rshift(a, b)
    return math.floor(a / 2 ^ b)
end

function bit:band(a, b)
    local result = 0
    local bit = 1

    while a > 0 and b > 0 do
        if a % 2 == 1 and b % 2 == 1 then
            result = result + bit
        end

        a = math.floor(a / 2)
        b = math.floor(b / 2)
        bit = bit * 2
    end

    return result
end

return bit