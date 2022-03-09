" vim-bettergrep
" Maintainer: Qusai Al Shidi
" Email:      me@qalshidi.science
" Website:    https://github.com/qalshidi/vim-bettergrep
" License:    MIT License (c) 2020

" decide on grep program {{{
if !exists('g:bettergrepprg')
  if executable('rg')
    let g:bettergrepprg = "rg --vimgrep"
  elseif executable('ag')
    let g:bettergrepprg = "ag --vimgrep"
  elseif executable('ack')
    let g:bettergrepprg = "ack -s -H --nopager --nocolor --nogroup --column"
  else
    let g:bettergrepprg = &grepprg
  endif
endif
" }}}

" Mappings {{{

let s:qf_mappings = {}
let s:qf_mappings['q'] = "<C-W>c"                         " close qf
let s:qf_mappings['J'] = ':silent call search("^[^\\|]", "z")<CR>'  " goto next match
let s:qf_mappings['K'] = ':silent call search("^[^\\|]", "bz")<CR>'  " goto prev match
let s:qf_mappings['t'] = "<C-W><CR><C-W>T"                " open in new tab
let s:qf_mappings['T'] = s:qf_mappings['t'] . "gT<C-W>j"  " open in new tab keep focus
let s:qf_mappings['o'] = "<CR>"                           " open
let s:qf_mappings['<CR>'] = s:qf_mappings['o']            " open
let s:qf_mappings['O'] = "<CR><C-W>p"                     " open keep focus
let s:qf_mappings['go'] = s:qf_mappings['O'] . s:qf_mappings['q'] " open and close qf
let s:qf_mappings['i'] = "<C-W><CR><C-W>K"                " open horizontal split
let s:qf_mappings['I'] = s:qf_mappings['i'] . "<C-W>b"   " open horiz maintain focus
let s:qf_mappings['gi'] = s:qf_mappings['I'] . s:qf_mappings['q'] " open horiz close qf
let s:qf_mappings['S'] = "<C-W><CR><C-W>H<C-W>b<C-W>J"   " open vert maintain focus
let s:qf_mappings['s'] = s:qf_mappings['S'] . "<C-W>t"  " open vert split
let s:qf_mappings['gs'] = s:qf_mappings['S'] . s:qf_mappings['q']  " open vert close qf
let s:qf_mappings['g?'] = ":help bettergrep-mappings-qf<CR>"   " open help

function! s:apply_mappings() abort
  " Apply mappings only in qf window

  if exists('g:bettergrep_qf_mappings')
    call extend(s:qf_mappings, g:bettergrep_qf_mappings, 'force')
  endif

  for key in keys(s:qf_mappings)
    execute "nnoremap <buffer> <silent> " . key . ' ' . s:qf_mappings[key]
  endfor

endfunction "}}}

"{{{ Functions
function! s:msg(message_str, error) abort
  "{{{ Messaging mechanics
  if a:error == 0      " Message
    echomsg 'bettergrep: ' . a:message_str
  elseif a:error == 1  " Error
    echoerr 'bettergrep: ' . a:message_str
  elseif a:error == 2  " Warning
    echohl WarningMsg
    echomsg 'bettergrep: ' . a:message_str
    echohl None
  endif
endfunction "}}}

function! s:bettergrep_pre(grep_cmd) abort
  " Side effects before grepping like quick fix autocmds {{{

  let s:qf_attrs = {
    \ 'title': 'bettergrep: ' . a:grep_cmd,
    \ 'context': {'name': 'bettergrep'},
    \ }

  augroup s:qfopen
    autocmd!
    autocmd QuickFixCmdPost cgetexpr cwindow
      \ | call setqflist([], 'a', s:qf_attrs)
    autocmd QuickFixCmdPost lgetexpr lwindow
      \ | call setloclist(0, [], 'a', s:qf_attrs)
    autocmd Filetype qf call s:apply_mappings()
    autocmd Filetype qf setlocal foldexpr=getline(v:lnum)=~'^\|\|\ [^--]'?'1':'0'
    autocmd Filetype qf setlocal foldmethod=expr
    autocmd Filetype qf setlocal foldlevel=0
  augroup end

  if exists('s:grep_job')

    if exists ('*jobstop')
      let job_to_kill = s:grep_job
      unlet! s:grep_job  " unlet first just incase
      call jobstop(job_to_kill)
    endif

    if exists('*job_stop')
      let job_to_kill = s:grep_job
      call job_stop(job_to_kill)
      unlet! s:grep_job
    endif

  endif

endfunction
" }}}

function! s:bettergrep_post() abort
  " Side effects after grepping like quick fix autocmd removal {{{

  augroup s:qfopen  " remove autocommands from user configuration after open
    autocmd!
  augroup end

  if exists('s:grep_job')
    unlet! s:grep_job
  endif

endfunction
" }}}

function! s:makecmd(args) abort
  " Make the command line to send to shell {{{
  let grep_cmd  = [g:bettergrepprg]
  let grep_cmd += map(copy(a:args), 'expand(v:val)')   " Substitute wildcards
  return substitute(join(grep_cmd, ' '), "\n", ' ', '') " Remove newlines
endfunction
" }}}

" NeoVim async method {{{
if exists('*jobstart')

  function! bettergrep#Grep(cmd, ...) abort

    let grep_cmd = s:makecmd(a:000)
    call s:bettergrep_pre(grep_cmd)

    let s:cmd = a:cmd
    let s:is_error = 0

    function! s:on_out(job_id, data, event) dict
      if len(a:data) == 1 && s:is_error == 0
        call s:msg('No results found.', 2)
      elseif s:is_error == 0
        execute s:cmd . ' join(a:data, "\n")'
        let l:results_count = len(filter(getqflist(), 'v:val.valid'))
        call s:msg(l:results_count .. ' results found', 0)
      endif
    endfunction

    function! s:on_error(job_id, data, event) dict
      let s:is_error = 1
      if len(a:data) > 1
        call s:msg(join(a:data, "\n"), 1) " Show error
      endif
    endfunction

    function! s:on_exit(job_id, data, event) dict
      call s:bettergrep_post()
    endfunction

    let s:callbacks = {
    \ 'stdout_buffered': 1,
    \ 'on_stdout': function('s:on_out'),
    \ 'on_stderr': function('s:on_error'),
    \ 'on_exit':   function('s:on_exit')
    \ }
    if has('nvim-0.5.1')
      " (see https://github.com/mhinz/vim-grepper/issues/244 for more info)
      let s:callbacks.stdin = 'null'
    endif

    call s:msg(grep_cmd, 0)
    let s:grep_job = jobstart(grep_cmd, s:callbacks)

  endfunction

" }}}
" Vim async method {{{
elseif exists('*job_start')

  function! bettergrep#Grep(cmd, ...) abort

    let grep_cmd = s:makecmd(a:000)
    call s:bettergrep_pre(grep_cmd)

    let s:cmd = a:cmd
    let s:data = ''
    let s:is_error = 0

    function! s:on_out(job_id, data)
      let s:data .= a:data . "\n"
    endfunction

    function! s:on_error(job_id, data)
      let s:is_error = 1
      if len(a:data) > 1
        call s:msg(join([a:data], "\n"), 1)
      endif
    endfunction

    function! s:on_exit(job_id, status)
      let job_to_kill = s:grep_job
      if len(s:data) > 1
        execute s:cmd . ' join([s:data], "\n")'
      elseif s:is_error == 0
        call s:msg("No results found.", 2)
      endif
      call s:bettergrep_post()
      call job_stop(job_to_kill)
    endfunction

    let s:callbacks = {
    \ 'callback': function('s:on_out'),
    \ 'err_cb':   function('s:on_error'),
    \ 'exit_cb':  function('s:on_exit'),
    \ 'in_io':    'null'
    \ }

    let shell_cmd = split(&shell) + split(&shellcmdflag) + [grep_cmd]
    call s:msg(join(shell_cmd, ' '), 0)
    let s:grep_job = job_start(shell_cmd, s:callbacks)

  endfunction

" }}}
" regular blocking method {{{
else

  " Thanks to RomainL's gist
  " https://gist.github.com/romainl/56f0c28ef953ffc157f36cc495947ab3

  function! bettergrep#Grep(cmd, ...) abort
    let grep_cmd = s:makecmd(a:000)
    call s:bettergrep_pre(grep_cmd)
    call s:msg(grep_cmd, 0)
    execute a:cmd . " " . "system(grep_cmd)"
    call s:bettergrep_post()
  endfunction

endif
" }}}

"}}} Functions

" vim: et sts=2 sw=2 foldmethod=marker
