vim-bettergrep
==============

A better way to grep in vim.

The purpose of this plugin is to provide a *lightweight* and enhanced version
of the original `:grep` family of Vim commands.

This plugin implements
[RomainL's Instant grep + quickfix](https://gist.github.com/romainl/56f0c28ef953ffc157f36cc495947ab3)
with a few of my own additions.

- Abbreviates `:grep` with `:Grep`, as well as the rest: `:lgrep`, `:grepadd`,
  `lgrepadd`
- In general faster than regular `:grep`
- Autoconfigures the grep program based on what you have in your `PATH` in the following order:
    - Whatever `g:bettergrepprg` is set to.
    - [ripgrep](https://github.com/BurntSushi/ripgrep)
    - [ag (The Silver Seacher)](https://github.com/ggreer/the_silver_searcher)
    - [ack](https://beyondgrep.com/)
    - Whatever `grepprg` is set to.
- Asynchronous grepping.
- `<C-g>` in normal mode mapping to `:Grep` in command mode.

Installation
------------

With [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'qalshidi/vim-bettergrep'
```

Configuration
-------------

Don't map my CTRL-G!

```vim
let g:bettergrep_no_mapping = 1
```

I want to use `some_grepper`!

```vim
let g:bettergrepprg = "<some_grepper>"
```

I want to use `git grep`!

```vim
let g:bettergrepprg = "git grep --column -n"
" or using tpope/vim-fugitive plugin's :Ggrep
```

I want to use `git grep` when my current directory is a git repository!

```vim
autocmd VimEnter * if isdirectory('./.git') | let g:bettergrepprg = 'git grep -n --column' | endif
if exists('##DirChanged')
  autocmd DirChanged * if isdirectory('./.git') | let g:bettergrepprg = 'git grep -n --column' | endif
endif
```

Don't abbreviate my `:grep`!

```vim
let g:bettergrep_no_abbrev = 1
```

It is not ignoring my hidden files/`.gitignore` files!

- Use [ripgrep](https://github.com/BurntSushi/ripgrep)

Frequently Asked Questions
--------------------------

How do I grep a pattern with spaces?

- Try enclosing your pattern in single quotes like this:
```vim
:Grep 'my pattern' my/file/path
```

How is this different from [vim-grepper](https://github.com/mhinz/vim-grepper)?

- *vim-bettergrep* is a lightweight enhancement to `:grep` and tries to imitate
  the original Vim commands. To me, it seems *vim-grepper* is beefier and its
  own beast, allowing multiple grep commands and loading everything at start up
  as opposed to using Vim's `autoload` feature. They both have their own use
  cases. I am happy with original Vim's grep and don't necessarily need more
  than that.

How is this different from [ack.vim](https://github.com/mileszs/ack.vim)?

- *bettergrep* is mostly like *ack.vim* with a bit more opinionated defaults,
  quickfix window mappings that are more like
  [NERDTree](https://github.com/preservim/nerdtree) mappings. Asynchronous 
  execution baked in by default. *bettergrep* also is more agnostic than
  *ack.vim* albeit *ack.vim* is still configurable, so the command functions are
  `:Grep` instead of `:Ack`.

