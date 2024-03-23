package.path = package.path .. ";./modules/?.lua"

local bit = require("modules.cbit")
local parser;

local function printHeaderInfo()
    local signature = parser:ReadByte():byte() .. parser:ReadBytes(3)

    print("-----------------------------------------")
    print("Header:")
    print("  Signature: " .. signature)
    print("  Version: " .. parser:ReadByte():byte())
    print("  Format: " .. parser:ReadByte():byte())
    print("  Endianness: " .. parser:ReadByte():byte())
    print("  Int Size: " .. parser:ReadByte():byte())
    print("  Size_t Size: " .. parser:ReadByte():byte())
    print("  Instruction Size: " .. parser:ReadByte():byte())
    print("  Lua Number Size: " .. parser:ReadByte():byte())
    print("  Integral Flag: " .. parser:ReadByte():byte())
    print("-----------------------------------------")
end

local function printFunctionBlockInfo()
    print("-----------------------------------------")
    print("Function Block:")
    print("  Source: " .. parser:ReadString())
    print("  Line Defined: " .. parser:ReadInt())
    print("  Last Line Defined: " .. parser:ReadInt())
    print("  Number of Upvalues: " .. parser:ReadByte():byte())
    print("  Number of Parameters: " .. parser:ReadByte():byte())
    print("  Is Vararg: " .. parser:ReadByte():byte())
    print("  Max Stack Size: " .. parser:ReadByte():byte())
    print("-----------------------------------------")
end

local function getMnemonic(opcode)
    local mnemonics = {
        [0] = "MOVE", "LOADK", "LOADBOOL", "LOADNIL", "GETUPVAL", "GETGLOBAL", "GETTABLE", "SETGLOBAL",
        "SETUPVAL", "SETTABLE", "NEWTABLE", "SELF", "ADD", "SUB", "MUL", "DIV",
        "MOD", "POW", "UNM", "NOT", "LEN", "CONCAT", "JMP", "EQ",
        "LT", "LE", "TEST", "TESTSET", "CALL", "TAILCALL", "RETURN", "FORLOOP",
        "FORPREP", "TFORLOOP", "SETLIST", "CLOSE", "CLOSURE", "VARARG"
    }

    return mnemonics[opcode]
end

local function printInstructionsInfo()
    local numInstructions = parser:ReadInt()

    print("-----------------------------------------")
    print("Instructions:")
    print("  Number of Instructions: " .. numInstructions)

    for i = 1, numInstructions do
        local instruction = parser:ReadInt()
        local opcode = instruction % 64
        local a = bit:band(bit:rshift(instruction, 6), 0xff)
        local b = bit:band(bit:rshift(instruction, 23), 0x1ff)
        local c = bit:band(bit:rshift(instruction, 14), 0x1ff)
        local mnemonic = getMnemonic(opcode)

        print("  Instruction " .. i .. ":")
        print("    Opcode: " .. opcode)
        print("    Mnemonic: " .. mnemonic)
        print("    A: " .. a)
        print("    B: " .. b)
        print("    C: " .. c)
    end
    print("-----------------------------------------")
end

local function printConstantsInfo()
    local constants = {
        [0] = "nil", [2] ="boolean", [3] = "number", [4] = "string"
    }

    local numConstants = parser:ReadInt()

    print("-----------------------------------------")
    print("Constants:")
    print("  Number of Constants: " .. numConstants)

    for i = 1, numConstants do
        local type = parser:ReadByte():byte()

        print("  Constant " .. i .. ":")
        print("    Type: " .. type)
        print("    Name: " .. constants[type])

        if type == 3 then
            local value = parser:ReadDouble()
            print("    Value: " .. value)
        elseif type == 4 then
            local value = parser:ReadString()
            print("    Value: " .. value)
        end
    end
    print("-----------------------------------------")
end

local function parseFunctionPrototype()
    print("-----------------------------------------")
    print("Function Prototype:")

    printFunctionBlockInfo()
    printInstructionsInfo()
    printConstantsInfo()

    local numNestedPrototypes = parser:ReadInt()
    print("  Number of Nested Function Prototypes: " .. numNestedPrototypes)
    for i = 1, numNestedPrototypes do
        parseFunctionPrototype()
    end
    print("-----------------------------------------")
end

local function parseFunctionPrototypes()
    local numPrototypes = parser:ReadInt()
    print("-----------------------------------------")
    print("Function Prototypes:")
    print("  Number of Function Prototypes: " .. numPrototypes)
    for i = 1, numPrototypes do
        parseFunctionPrototype()
    end
    print("-----------------------------------------")
end

if arg[1] then
    parser = require("modules.bcUtils").new(arg[1])

    printHeaderInfo()
    printFunctionBlockInfo()
    printInstructionsInfo()
    printConstantsInfo()
    parseFunctionPrototypes()
else
    print("Usage: lua index.lua <file>")
end
