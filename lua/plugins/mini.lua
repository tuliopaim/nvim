return {
    {
        'echasnovski/mini.ai',
        version = false,
        config = function()
            require('mini.ai').setup({
                -- Number of lines within which textobject is searched
                n_lines = 500,

                -- Custom text objects configuration
                -- You can add your own custom text objects here
                custom_textobjects = nil,
            })
        end,
    },
}

--[[
mini.ai - Advanced Text Objects
[ 

d]
WHAT IT DOES:
Extends Neovim's built-in text objects (like `iw`, `ap`) with more powerful features:
- Works with various brackets, quotes, and custom patterns
- Supports "next" and "last" variants to select nearby objects
- Allows searching across multiple lines
- Enables dot-repeat for all operations

BUILT-IN TEXT OBJECTS:
- Brackets: `(`, `)`, `[`, `]`, `{`, `}`, `<`, `>`
- Quotes: `'`, `"`, `` ` ``
- Special:
  - `b` - balanced brackets (any type)
  - `q` - balanced quotes (any type)
  - `?` - user prompt (asks you which character)
  - `f` - function call
  - `a` - argument
  - `t` - tag (HTML/XML)

BASIC USAGE EXAMPLES:

1. Delete inside next brackets:
   `din)`  - delete inside next ()
   `din]`  - delete inside next []

2. Change around previous quotes:
   `cal"`  - change around last "

3. Select function call:
   `vif`   - select inside function call
   `vaf`   - select around function call (includes function name)

4. Select argument:
   `via`   - select inside argument (without comma)
   `vaa`   - select around argument (with comma)

5. Any bracket/quote:
   `dib`   - delete inside any bracket type
   `ciq`   - change inside any quote type

COMMON WORKFLOWS:

Delete around next parentheses: `dan)`
Change inside second next bracket: `ci2n]`
Yank around last function call: `yalf`
Visual select inside tag: `vit`

ADVANCED FEATURES:
- `g[` / `g]` - Jump to left/right edge of text object
- Counts work: `2daa` deletes 2 arguments
- Works with operators: d (delete), c (change), y (yank), v (visual)

TIP: The "next" and "last" variants are game-changers!
You don't need to move your cursor to the object first.
--]]
