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

### References
- [Lua 5.1 Lopcodes Documentation](https://lua.org/source/5.1/lopcodes.h.html)
- [A No-Frills Intro to Lua 5.1 VM Instructions](https://archive.org/details/a-no-frills-intro-to-lua-5.1-vm-instructions)

### License
- [MIT](./LICENSE)