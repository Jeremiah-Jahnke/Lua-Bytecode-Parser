--[[
    References:
        - https://lua.org/source/5.1/lopcodes.h.html
        - https://archive.org/details/a-no-frills-intro-to-lua-5.1-vm-instructions

    Bytecode Structure:
        - Header:
            - Signature: 4C 75 61
            - Version: 54
            - Format: 0
            - Endianness: 1
            - Int Size: 4
            - Size_t Size: 4
            - Instruction Size: 4
            - Lua Number Size: 8
            - Integral Flag: 0
        - Function Block:
            - Source: String
            - Line Defined: Int
            - Last Line Defined: Int
            - Number of Upvalues: Byte
            - Number of Parameters: Byte
            - Is Vararg: Byte
            - Max Stack Size: Byte
        - Strings
            - Size_T
            - Bytes (nul at end)

    
    [ 1B 4C 75 61 51 00 01 04 04 04 08 00 ] 3E 00 00 00 40 43 3A 5C 55 73 65 72 73 
      ^ Header
    5C 4A 65 72 65 6D 69 61 68 5C 44 65 73 6B 74 6F 70 5C 42 79 74 65 63 6F 64 
    65 2D 50 61 72 73 65 72 5C 74 65 73 74 73 5C 62 79 74 65 63 6F 64 65 2E 6C 
    75 61 00 31 00 00 00 33 00 00 00 00 00 00 02 04 00 00 00 05 00 00 00 41 40 
    00 00 1C 40 00 01 1E 00 80 00 02 00 00 00 04 06 00 00 00 70 72 69 6E 74 00 
    04 0C 00 00 00 4D 72 2E 20 4C 6F 6C 65 67 69 63 00 00 00 00 00 04 00 00 00 
    32 00 00 00 32 00 00 00 32 00 00 00 33 00 00 00 00 00 00 00 00 00 00 00
]]--

local chunk = string.dump(function()
	print("Mr. Lolegic")
end)

local function loadBytes(Byte)
	local loadedBytes = string.sub(chunk, 1, Byte)
	chunk = string.sub(chunk, Byte + 1)

	return loadedBytes
end

local esc = loadBytes(1):byte() -- 1B
local signature = loadBytes(3) -- 4C 75 61
local version = loadBytes(1):byte() -- 54

print(esc .. signature)
print(version)


-- local chunk = string.dump(function()
--     print("Mr. Lolegic")
-- end):gsub(".", function(c)
--     return string.format("%02X ", string.byte(c))
-- end)

-- print(chunk)
