
--- @module 'utilities' This module provides a bytecode parser for reading and extracting data from binary files.
local bit = require("modules.cbit")

local parser = {}
parser.__index = parser

--- Creates a new parser object.
--- @param file string The path to the binary file to be parsed.
--- @return table self The newly created parser object.
function parser.new(file)
    local self = setmetatable({}, parser)

    self.bytecode = io.open(file, "rb"):read("*a")
    self.pos = 0

    return self
end

--- Reads a single byte from the bytecode.
--- @return string byte The byte read from the bytecode.
function parser:ReadByte()
    local byte = string.sub(self.bytecode, self.pos + 1, self.pos + 1)
    self.pos = self.pos + 1
    
    return byte
end

--- Reads a specified number of bytes from the bytecode.
--- @param count number The number of bytes to read.
--- @return string bytes The bytes read from the bytecode.
function parser:ReadBytes(count)
    local bytes = string.sub(self.bytecode, self.pos + 1, self.pos + count)
    self.pos = self.pos + count

    return bytes
end

--- Reads a 32-bit integer from the bytecode.
--- @return number int The integer read from the bytecode.
function parser:ReadInt()
    local bytes = {string.byte(self:ReadBytes(4), 1, 4)}
    local int = 0

    for i = 1, 4 do
        int = int + bit:lshift(bytes[i], 8 * (i - 1))
    end

    return int
end

--- Reads a 64-bit double from the bytecode. | Used for finding the number constant.
--- @return number double The double read from the bytecode.
function parser:ReadDouble()
    local lowInt = self:ReadInt()
    local highInt = self:ReadInt()

    local sign = bit:band(highInt, 0x80000000) ~= 0 and -1 or 1
    local exponent = bit:band(bit:rshift(highInt, 20), 0x7FF)
    local fraction = (bit:band(highInt, 0xFFFFF) * 4294967296.0 + lowInt) / (2 ^ 52)
    local double = sign * (2^(exponent - 1023)) * (1 + fraction)

    return double
end

--- Reads a string from the bytecode.
--- @return string str The string read from the bytecode.
function parser:ReadString()
    local length = self:ReadInt()
    local str = self:ReadBytes(length)

    return str
end

return parser