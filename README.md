## Lua Bytecode Parser

This is my Lua bytecode parser, written entirely in Lua. It supports the Lua 5.1.5 bytecode format.

### Usage

To use the parser, run the following command:
```
lua index.lua <file>
```

### Example Usage
```
lua index.lua "./temp/luac.out"
```

### Example Output
```
----------------------------------------
Header
----------------------------------------
signature       27Lua
version         81
format          0
endianness      1
intSize         4
size_tSize      4
instructionSize 4
luaNumberSize   8
integralFlag    0
----------------------------------------
Function Block
----------------------------------------
source          @test.lua
lineDefined     0
lastLineDefined 0
numUpvalues     0
numParameters   0
isVararg        2
maxStackSize    2
----------------------------------------
Instructions
----------------------------------------
Opcode    Mnemonic    A    B    C
36        CLOSURE     0    0    0
28        CALL        0    1    1
30        RETURN      0    1    0
5         GETGLOBAL   0    0    0
1         LOADK       1    0    1
28        CALL        0    2    1
30        RETURN      0    1    0
----------------------------------------
Constants
----------------------------------------
Type    Value
4       print
4       Hello, World!
----------------------------------------
Prototypes
----------------------------------------
lineDefined     1
source
maxStackSize    2
numUpvalues     0
lastLineDefined 3
numParameters   0
isVararg        0
```

### References
- [Lua 5.1 Lopcodes Documentation](https://lua.org/source/5.1/lopcodes.h.html)
- [A No-Frills Intro to Lua 5.1 VM Instructions](https://archive.org/details/a-no-frills-intro-to-lua-5.1-vm-instructions)

### License
- [MIT](./LICENSE)