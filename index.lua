package.path = package.path .. ";./modules/?.lua"

local bit = require("modules.cbit")
local parser;

local parsedData = {
    header = {},
    functionBlock = {},
    instructions = {},
    constants = {},
    prototypes = {}

}

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

local function parserHeader()
    parsedData.header.signature = parser:ReadByte():byte() .. parser:ReadBytes(3)
    parsedData.header.version = parser:ReadByte():byte()
    parsedData.header.format = parser:ReadByte():byte()
    parsedData.header.endianness = parser:ReadByte():byte()
    parsedData.header.intSize = parser:ReadByte():byte()
    parsedData.header.size_tSize = parser:ReadByte():byte()
    parsedData.header.instructionSize = parser:ReadByte():byte()
    parsedData.header.luaNumberSize = parser:ReadByte():byte()
    parsedData.header.integralFlag = parser:ReadByte():byte()
end

local function parserFunctionBlock()
    parsedData.functionBlock.source = parser:ReadString()
    parsedData.functionBlock.lineDefined = parser:ReadInt()
    parsedData.functionBlock.lastLineDefined = parser:ReadInt()
    parsedData.functionBlock.numUpvalues = parser:ReadByte():byte()
    parsedData.functionBlock.numParameters = parser:ReadByte():byte()
    parsedData.functionBlock.isVararg = parser:ReadByte():byte()
    parsedData.functionBlock.maxStackSize = parser:ReadByte():byte()
end

local function parseInstructions()
    local numInstructions = parser:ReadInt()

    for i = 1, numInstructions do
        local instruction = parser:ReadInt()
        local opcode = instruction % 64
        local a = bit:band(bit:rshift(instruction, 6), 0xff)
        local b = bit:band(bit:rshift(instruction, 23), 0x1ff)
        local c = bit:band(bit:rshift(instruction, 14), 0x1ff)
        local mnemonic = getMnemonic(opcode)

        table.insert(parsedData.instructions, {
            opcode = opcode,
            mnemonic = mnemonic,
            a = a,
            b = b,
            c = c
        })
    end
end

local function parseConstants()
    local constants = {
        [0] = "nil", [1] ="boolean", [3] = "number", [4] = "string"
    }

    local numConstants = parser:ReadInt()

    for i = 1, numConstants do
        local type = parser:ReadByte():byte()

        if type == 3 then
            table.insert(parsedData.constants, {
                type = type,
                typename = constants[type],
                value = parser:ReadDouble()
            })
        elseif type == 4 then
            table.insert(parsedData.constants, {
                type = type,
                typename = constants[type],
                value = parser:ReadString()
            })
        end
    end
end

local function parsePrototypes()
    local numPrototypes = parser:ReadInt()

    for i = 1, numPrototypes do
        local prototype = {}

        prototype.source = parser:ReadString()
        prototype.lineDefined = parser:ReadInt()
        prototype.lastLineDefined = parser:ReadInt()
        prototype.numUpvalues = parser:ReadByte():byte()
        prototype.numParameters = parser:ReadByte():byte()
        prototype.isVararg = parser:ReadByte():byte()
        prototype.maxStackSize = parser:ReadByte():byte()

        parseInstructions()
        parseConstants()
        parsePrototypes()

        table.insert(parsedData.prototypes, prototype)
    end
end

local function printSeparator(title)
    print(string.rep("-", 40))
    print("\27[35m" .. title .. "\27[0m")
    print(string.rep("-", 40))
end

local function prettyPrint()
    printSeparator("Header")
    local headerOrder = {"signature", "version", "format", "endianness", "intSize", "size_tSize", "instructionSize", "luaNumberSize", "integralFlag"}
    for _, key in ipairs(headerOrder) do
        print("\27[34m" .. string.format("%-16s%s", key, parsedData.header[key]) .. "\27[0m")
    end

    printSeparator("Function Block")
    local functionBlockOrder = {"source", "lineDefined", "lastLineDefined", "numUpvalues", "numParameters", "isVararg", "maxStackSize"}
    for _, key in ipairs(functionBlockOrder) do
        print("\27[34m" .. string.format("%-16s%s", key, parsedData.functionBlock[key]) .. "\27[0m")
    end

    printSeparator("Instructions")
    print("\27[34mOpcode    Mnemonic    A    B    C\27[0m")
    for _, entry in ipairs(parsedData.instructions) do
        print("\27[33m" .. string.format("%-10s%-12s%-5s%-5s%-6s", entry.opcode, entry.mnemonic, entry.a, entry.b, entry.c) .. "\27[0m")
    end

    printSeparator("Constants")
    print("\27[34mType   Name    Value\27[0m")
    for _, entry in ipairs(parsedData.constants) do
        print("\27[33m" .. string.format("%-7s%-8s%-6s", entry.type, entry.typename, entry.value) .. "\27[0m")
    end

    printSeparator("Prototypes")
    for _, entry in ipairs(parsedData.prototypes) do
        for key, value in pairs(entry) do
            print("\27[34m" .. key .. "\t" .. value .. "\27[0m")
        end
    end
end

if arg[1] then
    parser = require("modules.bcUtils").new(arg[1])

    parserHeader()
    parserFunctionBlock()
    parseInstructions()
    parseConstants()
    parsePrototypes()
    prettyPrint()
else
    print("Usage: lua index.lua <file>")
end
