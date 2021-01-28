# How to write in TruePython

The functionality of each hiss code is dependent on the current mode of the parser.
## Basic mode
Basic mode is the only mode in which Python keywords are generated, and is the state the parser begins in.

The whitespace at the beginning of each line is passed through directly, so it must be indented the same as regular Python.

## Embed mode
Embed mode is delimited on each end by the hiss code `hiS`. The first whitespace after the opening `hiS` and before the closing `hiS` are consumed. Everything between the delimiters is passed through directly, including newlines, quotes, special characters, etc. The hiss code `his` can be used to escape the closing delimiter, as well as itself.

## Identifier mode
This allows for hiss code aliases of Python code identifiers (including library functions like `print`) to be created. When a hiss code that isn't associated with anything in Basic Mode is seen, this declares an alias to the identifier specified by the following hiss codes or UTF-8 embedding. Any time the alias is used in the program after declaration, it will be translated to the appropriate identifier. If no identifier or alias is specified, the identifier will have the same name in the Python code.

## String Mode
Starting with `hiSS`, the characters in String Mode are ASCII-ordered, with no gaps. The Shift and Caps Lock codes modify the behaviour only of the lowercase ASCII characters, which will be printed as uppercase if exactly one of Shift and Caps Lock are active.

## Integer Mode
Radix 2, 8, and 16 should only be included once at most, and only at the beginning of the constant. In any given radix, only the appropriate characters should be used (i.e. 0-9 in radix 10). While negative constants in Python use the unary minus, these constants may be specified as negative for convenience.

## Float Mode
Each of `.`, `-`, `e`, and `j` should be included at most once, and only in the appropriate locations within the constant. While negative constants in Python use the unary minus, these constants may be specified as negative for convenience.

## Comment Mode
The listed hiss codes will be translated, allowing for the entire source code to be written in hiss codes, while still having readable comments in Python. Characters that do not match a listed hiss code are passed through directly.

## Hiss Code Table

| Hiss code | Basic mode | Embed mode | Identifier mode | String mode | Integer mode | Float mode | Comment mode |
| :-------: | :--------: | :--------------: | :-------------: | :---------: | :----------: | :--------: | :----------: |
| his | | Escape | End mode | End mode | End mode | End mode | |
| hiS | Begin Embed mode | End mode | Begin Embed mode | Begin Embed mode | Begin Embed mode | Begin Embed mode | |
| hIs | Begin Identifier mode | | `0`  | `BEL` | `-` | `-` | `BEL` |
| hIS | Begin String mode | | `1`  | `BS` | Radix 2 | `0` | `BS`
| His | Begin Integer mode | | `2`  | `TAB` | Radix 8 | `1` | `TAB`
| HiS | Begin Float mode | | `3`  | `LF` | Radix 16 | `2` | `LF`
| HIs | Reserved for future use | | `4`  | `VT` | `0` | `3` | `VT`
| HIS | Begin comment | | `5`  | `FF` | `1` | `4` | `FF`
| hiss | `def` | | `6`  | `CR` | `2` | `5` | `CR`
| hisS | `if` | | `7`  | Shift | `3` | `6` | Shift
| hiSs | `elif` | | `8`  | Caps Lock | `4` | `7` | Caps Lock
| hiSS | `else` | | `9`  | ` ` | `5` | `8` | ` `
| hIss | `and` | | `a`  | `!` | `6` | `9` | `!`
| hIsS | `or` | | `b`  | `"` | `7` | `.` | `"`
| hISs | `not` | | `c`  | `#` | `8` | `e` | `#`
| hISS | `,` | | `d`  | `$` | `9` | `j` | `$`
| Hiss | `(` | | `e`  | `%` | `a` |  | `%`
| HisS | `)` | | `f`  | `&` | `b` |  | `&`
| HiSs | `:` | | `g`  | `'` | `c` |  | `'`
| HiSS | `for` | | `h`  | `(` | `d` |  | `(`
| HIss | `in` | | `i`  | `)` | `e` |  | `)`
| HIsS | `while` | | `j`  | `*` | `f` |  | `*`
| HISs | `break` | | `k`  | `+` |  |  | `+`
| HISS | `continue` | | `l`  | `,` |  |  | `,`
| hiis | `from` | | `m`  | `-` |  |  | `-`
| hiiS | `import` | | `n`  | `.` |  |  | `.`
| hiIs | `.` | | `o`  | `/` |  |  | `/`
| hiIS | `as` | | `p`  | `0` |  |  | `0`
| hIis | `False` | | `q`  | `1` |  |  | `1`
| hIiS | `None` | | `r`  | `2` |  |  | `2`
| hIIs | `True` | | `s`  | `3` |  |  | `3`
| hIIS | `assert` | | `t`  | `4` |  |  | `4`
| Hiis | `class` | | `u`  | `5` |  |  | `5`
| HiiS | `del` | | `v`  | `6` |  |  | `6`
| HiIs | `except` | | `w`  | `7` |  |  | `7`
| HiIS | `finally` | | `x`  | `8` |  |  | `8`
| HIis | `is` | | `y`  | `9` |  |  | `9`
| HIiS | `pass` | | `z`  | `:` |  |  | `:`
| HIIs | `raise` | | `_`  | `;` |  |  | `;`
| HIIS | `return` | | `A`  | `<` |  |  | `<`
| hhis | `try` | | `B`  | `=` |  |  | `=`
| hhiS | `with` | | `C`  | `>` |  |  | `>`
| hhIs | `+` | | `D`  | `?` |  |  | `?`
| hhIS | `-` | | `E`  | `@` |  |  | `@`
| hHis | `*` | | `F`  | `A` |  |  | `A`
| hHiS | `**` | | `G`  | `B` |  |  | `B`
| hHIs | `/` | | `H`  | `C` |  |  | `C`
| hHIS | `//` | | `I`  | `D` |  |  | `D`
| Hhis | `%` | | `J`  | `E` |  |  | `E`
| HhiS | `<` | | `K`  | `F` |  |  | `F`
| HhIs | `>` | | `L`  | `G` |  |  | `G`
| HhIS | `<=` | | `M`  | `H` |  |  | `H`
| HHis | `>=` | | `N`  | `I` |  |  | `I`
| HHiS | `==` | | `O`  | `J` |  |  | `J`
| HHIs | `!=` | | `P`  | `K` |  |  | `K`
| HHIS | `=` | | `Q`  | `L` |  |  | `L`
| hisss | `@` | | `R`  | `M` |  |  | `M`
| hissS | `<<` | | `S`  | `N` |  |  | `N`
| hisSs | `>>` | | `T`  | `O` |  |  | `O`
| hisSS | `&` | | `U`  | `P` |  |  | `P`
| hiSss | `\|` | | `V`  | `Q` |  |  | `Q`
| hiSsS | `^` | | `W`  | `R` |  |  | `R`
| hiSSs | `~` | | `X`  | `S` |  |  | `S`
| hiSSS | `async` | | `Y`  | `T` |  |  | `T`
| hIsss | `await` | | `Z`  | `U` |  |  | `U`
| hIssS | `global` | |  | `V` |  |  | `V`
| hIsSs | `lambda` | |  | `W` |  |  | `W`
| hIsSS | `nonlocal` | |  | `X` |  |  | `X`
| hISss | `yield` | |  | `Y` |  |  | `Y`
| hISsS | `;` | |  | `Z` |  |  | `Z`
| hISSs | `[` | |  | `[` |  |  | `[`
| hISSS | `]` | |  | `\` |  |  | `\`
| Hisss | `{` | |  | `]` |  |  | `]`
| HissS | `}` | |  | `^` |  |  | `^`
| HisSs | `->` | |  | `_` |  |  | `_`
| HisSS | `+=` | |  | `` ` `` |  |  | `` ` ``
| HiSss | `-=` | |  | `a` |  |  | `a`
| HiSsS | `*=` | |  | `b` |  |  | `b`
| HiSSs | `/=` | |  | `c` |  |  | `c`
| HiSSS | `//=` | |  | `d` |  |  | `d`
| HIsss | `%=` | |  | `e` |  |  | `e`
| HIssS | `@=` | |  | `f` |  |  | `f`
| HIsSs | `&=` | |  | `g` |  |  | `g`
| HIsSS | `\|=` | |  | `h` |  |  | `h`
| HISss | `^=` | |  | `i` |  |  | `i`
| HISsS | `>>=` | |  | `j` |  |  | `j`
| HISSs | `<<=` | |  | `k` |  |  | `k`
| HISSS | `**=` | |  | `l` |  |  | `l`
| hiiss | `\\` | |  | `m` |  |  | `m`
| hiisS | | |  | `n` |  |  | `n`
| hiiSs | | |  | `o` |  |  | `o`
| hiiSS | | |  | `p` |  |  | `p`
| hiIss | | |  | `q` |  |  | `q`
| hiIsS | | |  | `r` |  |  | `r`
| hiISs | | |  | `s` |  |  | `s`
| hiISS | | |  | `t` |  |  | `t`
| hIiss | | |  | `u` |  |  | `u`
| hIisS | | |  | `v` |  |  | `v`
| hIiSs | | |  | `w` |  |  | `w`
| hIiSS | | |  | `x` |  |  | `x`
| hIIss | | |  | `y` |  |  | `y`
| hIIsS | | |  | `z` |  |  | `z`
| hIISs | | |  | `{` |  |  | `{`
| hIISS | | |  | `\|` | | | `\|` |
| Hiiss | | |  | `}` |  |  | `}`
| HiisS | | |  | `~` |  |  | `~`
| HiiSs | | |  | `DEL` |  |  | `DEL`
